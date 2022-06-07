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
    final block = EditorController.of(context).getBlockByIndex(index);

    return DragTarget<String>(
      builder: (_, __, ___) => block as Widget,
      onAcceptWithDetails: (details) {
        final blockId = EditorController.of(context).getBlockId(index);

        // final box = context.findRenderObject() as RenderBox;

        // final contains = box.paintBounds.contains(details.offset);
        if (details.data != blockId) {
          EditorController.of(context).moveBlockTo(details.data, index);
        }
      },
    );
  }
}
