import 'package:flutter/material.dart';
import '../../../editor.dart' show EditorController;
import '../../outlined_text_button.dart';
import '../../block_draggable_button.dart';

class BlockManageWidget extends StatelessWidget {
  final BuildContext globalContext;
  final int index;
  final VoidCallback? overlayRemoveCallBack;
  const BlockManageWidget({
    Key? key,
    required this.globalContext,
    required this.index,
    this.overlayRemoveCallBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorController = EditorController.of(globalContext);

    final canMoveUp = editorController.canMoveUp(index);
    final canMoveDown = editorController.canMoveDown(index);
    final canDelete = editorController.canDelete(index);

    final deleteIcon = Icon(
      Icons.delete_forever_outlined,
      color: canDelete ? Colors.redAccent : Colors.grey,
    );

    final moveUpIcon = Icon(
      Icons.arrow_upward_outlined,
      color: canMoveUp ? Colors.black : Colors.grey,
    );

    final moveDownIcon = Icon(
      Icons.arrow_downward_outlined,
      color: canMoveDown ? Colors.black : Colors.grey,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedTextButton(
          child: deleteIcon,
          onPressed: () {
            if (canDelete) {
              overlayRemoveCallBack?.call();
              editorController.removeBlock(index);
            }
          },
        ),
        OutlinedTextButton(
          child: moveUpIcon,
          onPressed: () {
            if (canMoveUp) {
              overlayRemoveCallBack?.call();

              editorController.moveBlock(index, -1);
            }
          },
        ),
        OutlinedTextButton(
          child: moveDownIcon,
          onPressed: () {
            if (canMoveDown) {
              overlayRemoveCallBack?.call();

              editorController.moveBlock(index, 1);
            }
          },
        ),
        if (index < editorController.blocks.length)
          BlockDraggableButton(
            child: const Icon(Icons.swap_vert_outlined),
            blockId: editorController.getBlockId(index),
            onDragStart: overlayRemoveCallBack,
            globalContext: globalContext,
          ),
      ],
    );
  }
}
