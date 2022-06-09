import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weaver_editor/components/toolbar/block_align_widget.dart';
import 'package:weaver_editor/components/overlays/widgets/block_manage_widget.dart';
import 'package:weaver_editor/components/overlays/widgets/block_option_widget.dart';
import 'package:weaver_editor/editor.dart';

import 'package:weaver_editor/models/types.dart';

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

    final RenderBox box = context.findRenderObject() as RenderBox;

    final size = box.size;

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
    Alignment globalAnchor = Alignment.topLeft,
    Offset offset = Offset.zero,
  }) {
    _overlay = OverlayEntry(
      builder: (_) => Align(
        child: CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: targetAnchor,
          followerAnchor: followedAnchor,
          offset: offset,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.linearToEaseOut,
            ),
            child: child,
          ),
        ),
        alignment: globalAnchor,
      ),
    );
  }

  void removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }
}
