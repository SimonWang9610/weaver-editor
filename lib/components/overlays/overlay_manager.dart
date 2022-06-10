import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weaver_editor/components/toolbar/block_align_widget.dart';
import 'package:weaver_editor/components/overlays/widgets/block_manage_widget.dart';
import 'package:weaver_editor/components/overlays/widgets/block_option_widget.dart';
import 'package:weaver_editor/editor.dart';

import 'package:weaver_editor/models/types.dart';

/// We need to align [_overlay] to the global origin
/// this is why we need to use [Align] or [Positioned] to wrap [CompositedTransformFollower]
/// so that the [targetAnchor] and [followedAnchor] of [CompositedTransformFollower] can work correctly
/// [offset] of [CompositedTransformFollower] will work with [followedAnchor]
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
    removeOverlay();
    _controller.dispose();
  }

  OverlayEntry createOptionOverlay(
    BuildContext context, {
    required LayerLink link,
    required int index,
    required OverlayDirection direction,
  }) {
    if (_overlay != null) {
      removeOverlay();
    }

    final RenderBox box = context.findRenderObject() as RenderBox;

    final size = box.size;

    // final padding = MediaQuery.of(context).padding;
    // viewPadding vs viewInset
    // [https://medium.com/flutter-community/a-flutter-guide-to-visual-overlap-padding-viewpadding-and-viewinsets-a63e214be6e8]

    late final Alignment targetAnchor;
    late final Alignment followerAnchor;
    late final Widget child;

    switch (direction) {
      case OverlayDirection.left:
        targetAnchor = Alignment.topRight;
        followerAnchor = Alignment.topLeft;
        child = BlockOptionWidget(
          globalContext: context,
          index: index,
          overlayRemoveCallback: removeOverlay,
        );
        break;
      case OverlayDirection.right:
        targetAnchor = Alignment.topLeft;
        followerAnchor = Alignment.topRight;
        child = BlockManageWidget(
          globalContext: context,
          index: index,
          overlayRemoveCallBack: removeOverlay,
        );
        break;
    }

    _createOverlay(
      child,
      link,
      targetAnchor: targetAnchor,
      followedAnchor: followerAnchor,
    );

    _controller.reset();
    _controller.forward();

    return _overlay!;
  }

  OverlayEntry createAlignOverlay(
    BuildContext context, {
    required LayerLink link,
  }) {
    if (_overlay != null) {
      removeOverlay();
    }

    final toolbar = EditorController.of(context).toolbar;

    _createOverlay(
      BlockAlignWidget(
        align: toolbar.align,
        toolbar: toolbar,
        overlayRemoveCallback: removeOverlay,
      ),
      link,
      targetAnchor: Alignment.topCenter,
      followedAnchor: Alignment.bottomCenter,
      axis: Axis.vertical,
    );

    _controller.reset();
    _controller.forward();
    return _overlay!;
  }

  void _createOverlay(
    Widget child,
    LayerLink link, {
    Alignment targetAnchor = Alignment.topLeft,
    Alignment followedAnchor = Alignment.topLeft,
    Offset offset = Offset.zero,
    Axis axis = Axis.horizontal,
  }) {
    // _overlay = OverlayEntry(
    //   builder: (_) => Align(
    //     child: CompositedTransformFollower(
    //       link: link,
    //       showWhenUnlinked: false,
    //       targetAnchor: targetAnchor,
    //       followerAnchor: followedAnchor,
    //       offset: offset,
    //       child: SizeTransition(
    //         sizeFactor: CurvedAnimation(
    //           parent: _controller,
    //           curve: Curves.linearToEaseOut,
    //         ),
    //         child: child,
    //       ),
    //     ),
    //     alignment: globalAnchor,
    //   ),
    // );

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        top: 0,
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: targetAnchor,
          followerAnchor: followedAnchor,
          offset: offset,
          child: SizeTransition(
            axis: axis,
            sizeFactor: CurvedAnimation(
              parent: _controller,
              curve: Curves.linearToEaseOut,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  void removeOverlay({bool playReverseAnimation = false}) {
    if (playReverseAnimation) {
      _controller.reverse();
    }
    _overlay?.remove();
    _overlay = null;
  }
}
