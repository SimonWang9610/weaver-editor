import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weaver_editor/controller/block_editing_controller.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'package:weaver_editor/toolbar/widgets/add_link_button.dart';
import '../models/types.dart';

mixin ToolbarStyleDelegate {
  StreamController<ToolbarEvent> get notifier;

  late TextStyle historyStyle;
  late TextStyle style;

  bool get synchronized => historyStyle == style;

  void updateStyle(TextStyle value) {
    if (style != value) {
      historyStyle = style;
      style = value;
      notifier.add(ToolbarEvent.formatting);
    }
  }

  void synchronize(TextStyle? value) {
    if (value == null || synchronized && style == value) return;

    historyStyle = value;
    style = value;
    notifier.add(ToolbarEvent.synchronizing);
  }

  void boldText() {
    late final TextStyle newStyle;
    if (style.fontWeight == FontWeight.w900) {
      newStyle = style.copyWith(
        fontWeight: FontWeight.normal,
      );
    } else {
      newStyle = style.copyWith(fontWeight: FontWeight.w900);
    }
    updateStyle(newStyle);
  }

  void italicText() {
    late final TextStyle newStyle;

    if (style.fontStyle == FontStyle.italic) {
      newStyle = style.copyWith(fontStyle: FontStyle.normal);
    } else {
      newStyle = style.copyWith(fontStyle: FontStyle.italic);
    }
    updateStyle(newStyle);
  }

  void underlineText() {
    late final TextStyle newStyle;

    if (style.decoration == TextDecoration.underline) {
      newStyle = style.copyWith(decoration: TextDecoration.none);
    } else {
      newStyle = style.copyWith(decoration: TextDecoration.underline);
    }
    updateStyle(newStyle);
  }
}

mixin ToolbarHeaderDelegate {
  StreamController<ToolbarEvent> get notifier;

  late TextAlign align;
  late HeaderLine level;

  void updateAlign(TextAlign value) {
    if (align != value) {
      align = value;
      notifier.add(ToolbarEvent.align);
    }
  }

  void updateLevel(HeaderLine value) {
    if (level != value) {
      level = value;
      notifier.add(ToolbarEvent.header);
    }
  }
}

mixin InlineHyperLinkCreator {
  BlockEditingController? get attachedController;

  HyperLinkData? linkData;

  void clearLinkData() {
    linkData = null;
    print('remove link Data');
  }

  Future<void> addLinkInFocusedBlock(BuildContext context) async {
    final int? cursorOffset = attachedController?.selection.baseOffset;
    final data = await showDialog<HyperLinkData>(
      context: context,
      builder: (_) => HyperLinkForm(
        cursorOffset: cursorOffset,
      ),
    );
    // once receive data return from dialog
    // the focus will restore
    // at here, no block controller is attached
    linkData = data;
  }
}

mixin AttachedBlockDelegate {
  StreamController<ToolbarEvent> get notifier;

  BlockEditingController? get attachedController;
  set attachedController(BlockEditingController? value);

  String? get blockType => attachedController?.blockType;

  void attach(BlockEditingController controller) {
    if (attachedController == controller) return;

    if (controller.blockType != blockType) {
      handleBlockTypeChange();
    }

    detach();

    attachedController = controller;
  }

  /// switch the toolbar buttons for different block types
  void handleBlockTypeChange() {
    notifier.add(ToolbarEvent.blockType);
  }

  void detach() {
    attachedController?.detach();
    attachedController = null;
  }
}
