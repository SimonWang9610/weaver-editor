import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

import 'package:weaver_editor/models/types.dart';

import '../widgets/buttons/block_creator_button.dart';

class BlockOptionOverlay {
  BlockOptionOverlay();

  OverlayEntry? _overlay;

  OverlayEntry createOptionOverlay(
    BuildContext context, {
    required LayerLink link,
    required int index,
  }) {
    EditorBlockProvider.of(context).detachContentBlock();

    _removeOverlay();

    final RenderBox box = context.findRenderObject() as RenderBox;

    final size = box.size;

    // final padding = MediaQuery.of(context).padding;
    // viewPadding vs viewInset
    // [https://medium.com/flutter-community/a-flutter-guide-to-visual-overlap-padding-viewpadding-and-viewinsets-a63e214be6e8]

    final followedOffset = Offset(size.width + 5, 0.0);

    // targetAnchor: target origin which the follower show follow;
    // followerAnchor: follower origin which the follower should compare with the target origin
    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: size.width,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.topLeft,
          offset: followedOffset,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlockCreatorButton(
                globalContext: context,
                index: index,
                child: const Icon(Icons.text_fields),
                type: BlockType.paragraph,
                onPressed: _removeOverlay,
              ),
              BlockCreatorButton(
                globalContext: context,
                index: index,
                type: BlockType.image,
                child: const Icon(Icons.image),
                onPressed: _removeOverlay,
              ),
              BlockCreatorButton(
                globalContext: context,
                index: index,
                type: BlockType.video,
                child: const Icon(Icons.video_camera_back),
                onPressed: _removeOverlay,
              ),
            ],
          ),
        ),
      ),
    );

    return _overlay!;
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }
}
