import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weaver_editor/components/outlined_text_button.dart';
import 'package:weaver_editor/editor.dart';

import 'package:weaver_editor/models/types.dart';

import '../widgets/buttons/block_creator_button.dart';

class BlockManager extends TickerProvider {
  BlockManager() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  late final AnimationController _controller;
  OverlayEntry? _overlay;

  @override
  Ticker createTicker(onTick) {
    return Ticker(onTick);
  }

  void dispose() {
    _removeOverlay();
    _controller.dispose();
  }

  OverlayEntry createOptionOverlay(
    BuildContext context, {
    required LayerLink link,
    required int index,
    required OverlayDirection direction,
  }) {
    EditorBlockProvider.of(context).detachContentBlock();

    _removeOverlay();

    final RenderBox box = context.findRenderObject() as RenderBox;

    final size = box.size;

    // final padding = MediaQuery.of(context).padding;
    // viewPadding vs viewInset
    // [https://medium.com/flutter-community/a-flutter-guide-to-visual-overlap-padding-viewpadding-and-viewinsets-a63e214be6e8]

    late final Offset followedOffset;

    late final Alignment targetAnchor;
    late final Alignment followerAnchor;
    late final Widget child;

    switch (direction) {
      case OverlayDirection.left:
        targetAnchor = Alignment.topLeft;
        followerAnchor = Alignment.topLeft;
        followedOffset = Offset(size.width, 0.0);
        child = _blockOptions(context, index);
        break;
      case OverlayDirection.right:
        targetAnchor = Alignment.topRight;
        followerAnchor = Alignment.topRight;
        followedOffset = Offset(-size.width, 0);
        child = _manageOptions(context, index);
        break;
    }

    // targetAnchor: target origin which the follower show follow;
    // followerAnchor: follower origin which the follower should compare with the target origin
    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: size.width,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: targetAnchor,
          followerAnchor: followerAnchor,
          offset: followedOffset,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.bounceInOut,
            ),
            child: child,
          ),
        ),
      ),
    );

    _controller.reset();
    _controller.forward();

    return _overlay!;
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _blockOptions(BuildContext context, int index) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlockCreatorButton(
            globalContext: context,
            index: index,
            child: const Icon(Icons.text_fields),
            type: BlockType.paragraph,
            beforePressed: _removeOverlay,
          ),
          BlockCreatorButton(
            globalContext: context,
            index: index,
            type: BlockType.image,
            child: const Icon(Icons.image),
            beforePressed: _removeOverlay,
          ),
          BlockCreatorButton(
            globalContext: context,
            index: index,
            type: BlockType.video,
            child: const Icon(Icons.video_camera_back),
            beforePressed: _removeOverlay,
          ),
        ],
      );

  Widget _manageOptions(BuildContext context, int index) {
    final blockProvider = EditorBlockProvider.of(context);

    final canMoveUp = blockProvider.canMoveUp(index);
    final canMoveDown = blockProvider.canMoveDown(index);
    final canDelete = blockProvider.canDelete(index);

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedTextButton(
          child: deleteIcon,
          onPressed: () {
            if (canDelete) {
              _removeOverlay();
              blockProvider.removeBlock(index);
            }
          },
        ),
        OutlinedTextButton(
          child: moveUpIcon,
          onPressed: () {
            if (canMoveUp) {
              _removeOverlay();
              blockProvider.moveBlock(index, -1);
            }
          },
        ),
        OutlinedTextButton(
          child: moveDownIcon,
          onPressed: () {
            if (canMoveDown) {
              _removeOverlay();
              blockProvider.moveBlock(index, 1);
            }
          },
        )
      ],
    );
  }
}
