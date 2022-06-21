import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

/// TODO: understand how dragAnchorStrategy locates the position of the feedback
class BlockDraggableButton extends StatelessWidget {
  final String blockId;
  final Widget child;
  final VoidCallback? onDragStart;
  final BuildContext? globalContext;
  final double size;
  const BlockDraggableButton({
    Key? key,
    required this.child,
    required this.blockId,
    this.globalContext,
    this.onDragStart,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: blockId,
      child: child,
      feedback: _buildFeedback(),
      onDragStarted: onDragStart,
      dragAnchorStrategy: _customDragStrategy,
    );
  }

  Offset _customDragStrategy(
      Draggable draggable, BuildContext context, Offset position) {
    final block = WeaverEditorProvider.of(globalContext!).getBlockById(blockId);

    final width = block.size?.width ?? size;
    final height = block.size?.height ?? size;

    final box = context.findRenderObject() as RenderBox;
    final pointer = box.globalToLocal(position);
    return pointer.translate(width / 2, height / 2);
  }

  Widget _buildFeedback() {
    final block = WeaverEditorProvider.of(globalContext!).getBlockById(blockId);

    final width = block.size?.width ?? size;
    final height = block.size?.height ?? size;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(),
      ),
      child: block.preview,
    );
  }
}
