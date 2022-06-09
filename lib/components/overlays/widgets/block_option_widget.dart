import 'package:flutter/material.dart';
import 'block_creator_button.dart';
import '../../../models/types.dart';
import '../../../editor.dart' show EditorController;

class BlockOptionWidget extends StatelessWidget {
  final OverlayDirection direction;
  final BuildContext globalContext;
  final int index;
  final VoidCallback? overlayRemoveCallback;
  const BlockOptionWidget({
    Key? key,
    required this.globalContext,
    required this.index,
    this.overlayRemoveCallback,
    this.direction = OverlayDirection.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BlockCreatorButton(
          globalContext: globalContext,
          index: index,
          child: const Icon(Icons.filter_list),
          type: BlockType.header,
          beforePressed: overlayRemoveCallback,
        ),
        BlockCreatorButton(
          globalContext: globalContext,
          index: index,
          child: const Icon(Icons.text_fields),
          type: BlockType.paragraph,
          beforePressed: overlayRemoveCallback,
        ),
        BlockCreatorButton(
          globalContext: globalContext,
          index: index,
          type: BlockType.image,
          child: const Icon(Icons.image),
          beforePressed: () {
            EditorController.of(globalContext).detachBlock();
            overlayRemoveCallback?.call();
          },
        ),
        BlockCreatorButton(
          globalContext: globalContext,
          index: index,
          type: BlockType.video,
          child: const Icon(Icons.video_camera_back),
          beforePressed: () {
            EditorController.of(globalContext).detachBlock();
            overlayRemoveCallback?.call();
          },
        ),
      ],
    );
  }
}
