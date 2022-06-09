import 'package:flutter/material.dart';

import '../blocks/base_block.dart';

mixin EditorScrollDelegate {
  List<BaseBlock> get blocks;

  void scrollToIndexIfNeeded(ScrollController controller, int index) {
    if (blocks.length <= index) return;
    // scroll to the target index when the list re-build completely
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final scrollExt = controller.position.maxScrollExtent;
        final offset = calculateScrollPosition(index);

        if (offset < scrollExt) {
          controller.animateTo(
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

  double calculateScrollPosition(int index) {
    // used to calculate the new scroll offset
    // after the blocks have some changes
    double offset = 0;

    for (int i = 0; i <= index; i++) {
      final box = blocks[i].element.renderObject as RenderBox?;
      offset += box?.size.height ?? 0 + 24;
    }

    return offset;
  }

  RenderObject? findBlockRenderObject(int index) {
    return blocks[index].element.renderObject;
  }
}
