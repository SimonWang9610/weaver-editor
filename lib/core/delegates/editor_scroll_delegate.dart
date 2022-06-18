import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_base.dart';

mixin EditorScrollDelegate {
  List<BlockBase> get blocks;

  void scrollToIndexIfNeeded(ScrollController controller, int index) {
    if (blocks.length <= index) return;
    // scroll to the target index when the list re-build completely
    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) {
    //     final scrollExt = controller.position.maxScrollExtent;
    //     final offset = calculateScrollPosition(index);

    //     print('scroll extend: $scrollExt');

    //     if (offset > scrollExt) {
    //       controller.animateTo(
    //         offset,
    //         duration: const Duration(
    //           milliseconds: 200,
    //         ),
    //         curve: Curves.easeIn,
    //       );
    //     }
    //   },
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // scroll the end of the block list
      final scrollExt = controller.position.maxScrollExtent;

      if (index == blocks.length - 1) {
        final offset = blocks[index].size?.height ?? 0;
        controller.animateTo(
          scrollExt + offset,
          duration: const Duration(
            milliseconds: 200,
          ),
          curve: Curves.easeIn,
        );
      }
    });
  }

  double calculateScrollPosition(int index) {
    // used to calculate the new scroll offset
    // after the blocks have some changes
    double offset = 0;

    for (int i = 0; i <= index; i++) {
      final blockBottom = blocks[i].offset;
      offset += blockBottom?.dy ?? 0 + 24;
    }

    return offset;
  }
}
