import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/components/animated_block_list.dart';
import 'package:weaver_editor/components/draggble_block_wrapper.dart';
import 'package:weaver_editor/delegates/block_manage_delegate.dart';
import 'package:weaver_editor/delegates/editor_scroll_delegate.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'package:weaver_editor/delegates/block_creator_delegate.dart';
import 'package:weaver_editor/components/overlays/overlay_manager.dart';
import 'package:weaver_editor/models/editor_metadata.dart';
import 'package:weaver_editor/screens/preview.dart';
import 'package:weaver_editor/widgets/editor_appbar.dart';
import 'toolbar/widgets/toolbar_widget.dart';
import 'controller/block_editing_controller.dart';
import 'models/types.dart';
import 'widgets/block_control_widget.dart';

class WeaverEditor extends StatefulWidget {
  final EditorMetadata metadata;
  final EditorToolbar toolbar;
  final TextStyle defaultStyle;
  const WeaverEditor({
    Key? key,
    required this.toolbar,
    required this.defaultStyle,
    required this.metadata,
  }) : super(key: key);

  @override
  State<WeaverEditor> createState() => _WeaverEditorState();
}

class _WeaverEditorState extends State<WeaverEditor> {
  late final EditorController controller;
  late final StreamSubscription<BlockOperationEvent> _sub;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedBlockListState> _listKey =
      GlobalKey<AnimatedBlockListState>();

  @override
  void initState() {
    super.initState();
    controller = EditorController(
      widget.toolbar,
      metadata: widget.metadata,
      defaultStyle: widget.defaultStyle,
    );

    _sub = controller.listen(_handleBlockChange);
  }

  void _handleBlockChange(BlockOperationEvent event) {
    _listKey.currentState?.animateTo(event.index, event.operation);

    controller.scrollToIndexIfNeeded(_scrollController, event.index);
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
    print('create editor: title: ${widget.metadata.title}');

    return WillPopScope(
      child: GestureDetector(
        child: Scaffold(
          appBar: EditorAppBar(
            title: Text(
              widget.metadata.title,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
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
                    child: AnimatedBlockList(
                      key: _listKey,
                      scrollController: _scrollController,
                      initItemCount: controller.blocks.length,
                      separatedBuilder: (_, index) => BlockControlWidget(
                        index: index,
                      ),
                      itemBuilder: (_, index, animation) {
                        return FadeTransition(
                          key: ValueKey(controller.blocks[index].id),
                          opacity: animation,
                          child: DragTargetWrapper(
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                  EditorToolbarWidget(
                    toolbar: controller.toolbar,
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          controller.manager.removeOverlay(
            playReverseAnimation: true,
          );
        },
      ),
      onWillPop: () async {
        return true;
      },
    );
  }
}

class EditorController
    with BlockManageDelegate, BlockCreationDelegate, EditorScrollDelegate {
  final EditorToolbar toolbar;
  final TextStyle defaultStyle;
  final StreamController<BlockOperationEvent> _notifier =
      StreamController.broadcast();

  final BlockManager manager;
  late final List<BaseBlock> _blocks;
  late final EditorMetadata data;

  EditorController(
    this.toolbar, {
    required this.defaultStyle,
    required EditorMetadata metadata,
  })  : manager = BlockManager(),
        data = metadata.copyWith(id: nanoid(36)) {
    _blocks = data.getBlocks(defaultStyle);
  }

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

  void startPreview(BuildContext context) {
    if (_blocks.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlockPreview(
          id: data.id!,
          title: data.title,
          blocks: _blocks,
        ),
      ),
    );
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
        block = createParagraphBlock(defaultStyle);
        break;
      case BlockType.header:
        block = createHeaderBlock();
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
}
