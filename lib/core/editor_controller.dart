import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/blocks/block_factory.dart';

import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'package:weaver_editor/core/delegates/delegates.dart';
import 'package:weaver_editor/core/controller/block_editing_controller.dart';
import 'package:weaver_editor/components/overlays/overlay_manager.dart';
import 'package:weaver_editor/models/editor_metadata.dart';
import 'package:weaver_editor/models/types.dart';

import 'package:weaver_editor/screens/preview.dart';
import 'package:weaver_editor/components/draggble_block_wrapper.dart';

class EditorController with BlockManageDelegate, EditorScrollDelegate {
  final EditorToolbar toolbar;
  final TextStyle defaultStyle;
  final BlockFactory factory;
  final StreamController<BlockOperationEvent> _notifier =
      StreamController.broadcast();

  final BlockManager manager;
  late final List<BlockBase> _blocks;
  late final EditorMetadata data;

  EditorController(
    this.toolbar, {
    required this.defaultStyle,
    required EditorMetadata metadata,
  })  : manager = BlockManager(),
        factory = BlockFactory(defaultStyle) {
    if (metadata.id == null) {
      data = metadata.copyWith(id: nanoid(36));
    } else {
      data = metadata;
    }
    _blocks = factory.createBlockFromMetadata(data.blocks);
  }

  @override
  List<BlockBase> get blocks => _blocks;

  @override
  StreamController get notifier => _notifier;

  /// the lifetime of [BlockBase] should be same as [EditorController], instead of handing it out to its block widgets
  /// when disposing [BlockBase], its [BlockData] will also be disposed
  /// otherwise [StatefulBlock] cannot re-construct [FormatNode] correctly when rebuilding its block widgets after being disposed during list scrolling
  void dispose() {
    detachBlock();
    _notifier.close();
    manager.dispose();

    for (final block in blocks) {
      block.dispose();
    }
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
    final BlockBase block = factory.create(blockType: type, embedData: data);

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

  Widget buildBlock(
      BuildContext context, int index, Animation<double> animation) {
    return FadeTransition(
      key: ValueKey(blocks[index].id),
      opacity: animation,
      child: DragTargetWrapper(
        index: index,
      ),
    );
  }
}
