import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';

class BlockSelectionControl extends MaterialTextSelectionControls {
  EditorToolbar? toolbar;
  final bool hideHandles;
  late TextSelectionDelegate _delegate;

  bool _hasSelectionToolbar = false;

  BlockSelectionControl({
    this.toolbar,
    this.hideHandles = true,
  }) : super() {}

  void _willHideSelectionToolbar() {
    if (_hasSelectionToolbar) {
      _delegate.hideToolbar(hideHandles);
      _hasSelectionToolbar = false;
    }
  }

  void disUpdateToolbar(EditorToolbar newToolbar) {
    toolbar = newToolbar;
  }

  void removeToolbar() {
    toolbar = null;
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    _hasSelectionToolbar = true;

    _delegate = delegate;

    return super.buildToolbar(
      context,
      globalEditableRegion,
      textLineHeight,
      selectionMidpoint,
      endpoints,
      delegate,
      clipboardStatus,
      lastSecondaryTapDownPosition,
    );
  }

  TextSelectionDelegate? get delegate {
    if (_hasSelectionToolbar) {
      return _delegate;
    } else {
      return null;
    }
  }
}
