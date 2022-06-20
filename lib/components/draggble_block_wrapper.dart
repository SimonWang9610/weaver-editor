import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

class DragTargetWrapper extends StatelessWidget {
  final int index;
  const DragTargetWrapper({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (_, __, ___) {
        final block = WeaverEditorProvider.of(context).getBlockByIndex(index);
        return block.build();
      },
      onAcceptWithDetails: (details) {
        final blockId = WeaverEditorProvider.of(context).getBlockId(index);

        // final box = context.findRenderObject() as RenderBox;

        // final contains = box.paintBounds.contains(details.offset);
        if (details.data != blockId) {
          WeaverEditorProvider.of(context).moveBlockTo(details.data, index);
        }
      },
    );
  }
}
