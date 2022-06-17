import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

/// TODO: understand how dragAnchorStrategy locates the position of the feedback
class BlockDraggableButton extends StatelessWidget {
  final String blockId;
  final Widget child;
  final VoidCallback? onDragStart;
  final BuildContext? globalContext;
  const BlockDraggableButton({
    Key? key,
    required this.child,
    required this.blockId,
    this.globalContext,
    this.onDragStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feedback =
        EditorController.of(globalContext ?? context).getBlockById(blockId);

    // final feedbackSize =
    //     (feedback.element.findRenderObject() as RenderBox).size;

    return Draggable<String>(
      data: blockId,
      child: child,
      feedback: feedback.preview,
      onDragStarted: onDragStart,
      dragAnchor: DragAnchor.pointer,
      // dragAnchorStrategy: (draggable, __, position) {
      //   // print('feedback size: $feedbackSize');
      //   // print('position: $position');
      //   // final horizontalShift = position.dx - feedbackSize.width;
      //   // return draggable.feedbackOffset +
      //   //     Offset(horizontalShift > 0 ? horizontalShift : 0, position.dy);
      //   return Offset(-feedbackSize.width, 0);
      // },
    );
  }
}
