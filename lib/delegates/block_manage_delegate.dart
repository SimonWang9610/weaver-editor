import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:weaver_editor/blocks/base_block.dart';

import '../models/types.dart';

mixin BlockManageDelegate {
  List<BaseBlock> get blocks;
  StreamController get notifier;

  void removeBlock(int index) {
    if (blocks.length <= index) return;
    blocks.removeAt(index);
    notifier.add(
      BlockOperationEvent(
        BlockOperation.remove,
        index: index,
      ),
    );
  }

  bool canMoveUp(int index) {
    return index > 0 && index < blocks.length;
  }

  bool canMoveDown(int index) {
    return index + 1 < blocks.length;
  }

  bool canDelete(int index) {
    return index < blocks.length;
  }

  void moveBlock(int srcIndex, int step) {
    final block = blocks.removeAt(srcIndex);
    blocks.insert(srcIndex + step, block);
    notifier.add(
      BlockOperationEvent(
        BlockOperation.reorder,
        index: srcIndex + step,
      ),
    );
  }

  BaseBlock getBlockById(String id) {
    final block = blocks.singleWhere((element) => element.id == id);
    return block;
  }

  Widget getBlockPreview(String id) {
    final block = getBlockById(id);
    return block.buildForPreview();
  }

  String getBlockId(int index) {
    return blocks[index].id;
  }

  BaseBlock getBlockByIndex(int index) {
    return blocks[index];
  }

  void moveBlockTo(String blockId, int dst) {
    final src = blocks.indexWhere((element) => element.id == blockId);

    if (src > -1) {
      final block = blocks.removeAt(src);
      blocks.insert(dst, block);
      notifier.add(
        BlockOperationEvent(
          BlockOperation.reorder,
          index: dst,
        ),
      );
    }
  }
}
