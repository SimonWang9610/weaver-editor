import 'dart:async';

import 'package:flutter/material.dart';

import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/components/draggble_block_wrapper.dart';
import 'package:weaver_editor/delegates/block_manage_delegate.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import 'package:weaver_editor/delegates/block_creator_delegate.dart';
import 'package:weaver_editor/components/block_manager_overlay.dart';
import 'package:weaver_editor/preview.dart';
import 'widgets/toolbar_widget.dart';
import 'controller/block_editing_controller.dart';
import 'models/types.dart';
import 'widgets/block_control_widget.dart';

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
  late final EditorController controller;
  late final StreamSubscription<BlockOperationEvent> _sub;
  final ScrollController _scrollController = ScrollController();

  List<BaseBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    controller = EditorController(widget.toolbar);
    _blocks = controller.blocks;

    _sub = controller.listen(_handleBlockChange);
  }

  void _handleBlockChange(BlockOperationEvent event) {
    setState(() {});
    _scrollToIndexIfNeeded(event.index);
  }

  void _scrollToIndexIfNeeded(int index) {
    if (_blocks.length <= index) return;
    // scroll to the target index when the list re-build completely
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final oldOffset = _scrollController.offset;
        final offset = controller.calculateScrollPosition(index);

        if (offset >= oldOffset) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(
              milliseconds: 200,
            ),
            curve: Curves.easeIn,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    widget.toolbar.dispose();
    _scrollController.dispose();
    _sub.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weaver Editor'),
        actions: [
          TextButton(
            onPressed: _startPreview,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 2,
              ),
              child: Text('Preview'),
            ),
            style: TextButton.styleFrom(
              elevation: 5.0,
              backgroundColor: Colors.white,
            ),
          ),
        ],
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
                  controller: _scrollController,
                  children: _interleaveBlock(),
                ),
              ),
              EditorToolbarWidget(
                toolbar: controller.toolbar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List<Widget> _interleaveBlock() {
  //   final List<Widget> widgets = [const BlockControlWidget(index: 0)];

  //   if (_blocks.isEmpty) return widgets;

  //   for (int i = 0; i < _blocks.length; i++) {
  //     widgets.addAll([_blocks[i] as Widget, BlockControlWidget(index: i + 1)]);
  //   }

  //   return widgets;
  // }

  List<Widget> _interleaveBlock() {
    final List<Widget> widgets = [const BlockControlWidget(index: 0)];

    if (_blocks.isEmpty) return widgets;

    for (int i = 0; i < _blocks.length; i++) {
      widgets.addAll([
        DragTargetWrapper(
          key: ValueKey(_blocks[i].id),
          index: i,
        ),
        BlockControlWidget(index: i + 1),
      ]);
    }
    return widgets;
  }

  void _startPreview() {
    if (_blocks.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlockPreview(
          blocks: _blocks,
        ),
      ),
    );
  }
}

class EditorController with BlockManageDelegate, BlockCreationDelegate {
  final List<BaseBlock> _blocks;
  final EditorToolbar toolbar;
  final StreamController<BlockOperationEvent> _notifier =
      StreamController.broadcast();

  late final BlockManager manager;

  EditorController(
    this.toolbar, {
    List<BaseBlock>? initBlocks,
  })  : _blocks = initBlocks ?? [],
        manager = BlockManager();

  static EditorController of(BuildContext context) {
    final editor = context.findAncestorStateOfType<_WeaverEditorState>();

    if (editor == null) {
      throw ErrorDescription('No Editor Found');
    }

    return editor.controller;
  }

  @override
  List<BaseBlock> get blocks => _blocks;

  @override
  StreamController get notifier => _notifier;

  void dispose() {
    detachBlock();
    manager.dispose();
    _notifier.close();
  }

  StreamSubscription<BlockOperationEvent> listen(
      void Function(BlockOperationEvent event) handler) {
    return _notifier.stream.listen(handler);
  }

  EditorToolbar attachBlock(BlockEditingController controller) {
    return toolbar.attach(controller);
  }

  void detachBlock() {
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

    detachBlock();

    if (pos != null && pos >= 0) {
      blocks.insert(pos, block);
    } else {
      blocks.add(block);
    }

    notifier.add(
      BlockOperationEvent(
        BlockOperation.insert,
        index: pos ?? blocks.length - 1,
      ),
    );
  }

  double calculateScrollPosition(int index) {
    // used to calculate the new scroll offset
    // after the blocks have some changes
    double offset = 0;

    for (int i = 0; i <= index; i++) {
      final box = blocks[i].element.renderObject as RenderBox?;
      offset += box?.size.height ?? 0 + 20;
    }

    return offset;
  }
}
