import 'dart:async';

import 'package:flutter/material.dart';

import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import 'package:weaver_editor/delegates/block_creator_delegate.dart';
import 'package:weaver_editor/components/block_option_overlay.dart';
import 'widgets/toolbar_widget.dart';
import 'controller/block_editing_controller.dart';
import 'models/types.dart';
import 'widgets/block_creator.dart';

class WeaverEditor extends StatefulWidget {
  final EditorToolbar toolbar;
  const WeaverEditor({
    Key? key,
    required this.toolbar,
  }) : super(key: key);

  @override
  State<WeaverEditor> createState() => _WeaverEditorState();
}

class _WeaverEditorState extends State<WeaverEditor> {
  late final EditorBlockProvider provider;
  late final StreamSubscription<BlockListEvent> _sub;

  List<BaseBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    provider = EditorBlockProvider(widget.toolbar);
    _blocks = provider.blocks;

    _sub = provider.listen(_handleBlockChange);
  }

  void _handleBlockChange(BlockListEvent event) {
    if (event == BlockListEvent.insert) {
      _blocks = provider.blocks;

      setState(() {});
    }

    switch (event) {
      case BlockListEvent.insert:
      case BlockListEvent.remove:
        _blocks = provider.blocks;
        break;
      default:
        return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.toolbar.dispose();
    _sub.cancel();
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weaver Editor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: _interleaveBlock(),
                ),
              ),
              EditorToolbarWidget(
                toolbar: provider.toolbar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _interleaveBlock() {
    final List<Widget> widgets = [const BlockControlWidget(index: 0)];

    if (_blocks.isEmpty) return widgets;

    for (int i = 0; i < _blocks.length; i++) {
      widgets.addAll([_blocks[i] as Widget, BlockControlWidget(index: i + 1)]);
    }

    return widgets;
  }
}

class EditorBlockProvider with BlockCreationDelegate {
  final List<BaseBlock> blocks;
  final EditorToolbar toolbar;
  final StreamController<BlockListEvent> notifier =
      StreamController.broadcast();

  late final BlockOptionOverlay overlayController;

  EditorBlockProvider(
    this.toolbar, {
    List<BaseBlock>? initBlocks,
  })  : blocks = initBlocks ?? [],
        overlayController = BlockOptionOverlay();

  static EditorBlockProvider of(BuildContext context) {
    final editor = context.findAncestorStateOfType<_WeaverEditorState>();

    if (editor == null) {
      throw ErrorDescription('No Editor Found');
    }

    return editor.provider;
  }

  void dispose() {
    detachContentBlock();
    notifier.close();
  }

  StreamSubscription<BlockListEvent> listen(
      void Function(BlockListEvent event) handler) {
    return notifier.stream.listen(handler);
  }

  EditorToolbar attachContentBlock(BlockEditingController controller) {
    return toolbar.attach(controller);
  }

  void detachContentBlock() {
    toolbar.detach();
  }

  void insertBlock(
    BlockType type, {
    int? pos,
    EmbedData? data,
  }) {
    BaseBlock? block;

    switch (type) {
      case BlockType.paragraph:
        block = createParagraphBlock(toolbar.style);
        break;
      case BlockType.image:
        block = createImageBlock(data!);
        break;
      case BlockType.video:
        block = createVideoBlock(data!);
        break;
      default:
        throw UnimplementedError('Unsupported $type block');
    }

    detachContentBlock();

    if (pos != null && pos >= 0) {
      blocks.insert(pos, block);
    } else {
      blocks.add(block);
    }

    notifier.add(BlockListEvent.insert);
  }

  void removeBlock(int index) {
    if (blocks.length <= index) return;
    blocks.removeAt(index);
    notifier.add(BlockListEvent.remove);
  }

  void reorder(String srcId, int dstIndex) {
    final block = findBlockById(srcId);
    blocks.remove(block);
    blocks.insert(dstIndex, block);
    notifier.add(BlockListEvent.reorder);
  }

  BaseBlock findBlockById(String id) {
    final found = blocks.singleWhere((block) {
      final key = (block as Widget).key as ValueKey<String>;

      return key.value == id;
    });

    return found;
  }

  String getBlockIdByIndex(int index) {
    final block = blocks[index] as Widget;

    return (block.key as ValueKey<String>).value;
  }

  BaseBlock findBlockByIndex(int index) => blocks[index];
}
