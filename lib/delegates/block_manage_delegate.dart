import 'dart:async';

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
}
