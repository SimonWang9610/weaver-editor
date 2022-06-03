import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:weaver_editor/widgets/buttons/add_link_button.dart';
import 'controller/block_editing_controller.dart';

enum ToolbarEvent {
  formatting,
  synchronizing,
  align,
}

abstract class BaseToolbar {
  final StreamController<ToolbarEvent> notifier = StreamController.broadcast();
  late StreamSubscription _subscription;

  TextStyle _historyStyle;
  TextStyle _style;
  TextAlign _align;

  BlockEditingController? _attachedController;

  BaseToolbar({required TextStyle style, TextAlign? align})
      : _style = style,
        _historyStyle = style,
        _align = align ?? TextAlign.start {
    _subscription = notifier.stream.listen((event) {
      if (event == ToolbarEvent.formatting) {
        _attachedController?.mayApplyStyle();
      }
    });
  }

  TextStyle get style => _style;
  set style(TextStyle value) {
    if (_style != value) {
      print('@@@@formatting text by toolbar');
      _historyStyle = _style;
      _style = value;

      notifier.add(ToolbarEvent.formatting);
    }
  }

  TextAlign get align => _align;
  set align(TextAlign value) {
    if (_align != value) {
      _align = value;
    }
  }

  bool get synchronized => _historyStyle == _style;

  void synchronize(TextStyle? value) {
    print('synchronizing tool bal style..........');

    if (value == null || synchronized && _style == value) return;

    _historyStyle = value;
    _style = value;
    // will re-build EditorToolbarWidget
    // to follow the style of the focused FormatNode

    notifier.add(ToolbarEvent.synchronizing);
  }

  void dispose() {
    notifier.close();
    _subscription.cancel();
  }

  StreamSubscription listen(void Function(ToolbarEvent) handler) {
    return notifier.stream.listen(handler);
  }
}

class EditorToolbar extends BaseToolbar
    with FormatStyleDelegate, InlineHyperLinkCreator {
  EditorToolbar(TextStyle style, {TextAlign? align})
      : super(style: style, align: align);

  EditorToolbar attach(BlockEditingController controller) {
    if (_attachedController == controller) return this;

    detach();
    _attachedController = controller;

    // executeTaskAfterAttached();
    return this;
  }

  void detach() {
    _attachedController?.unfocus();
    _attachedController = null;
  }

  void executeTaskAfterAttached() {
    _attachedController?.insertLinkNode(linkData);
  }

  @override
  Future<void> addLinkInFocusedBlock(BuildContext context) async {
    await super.addLinkInFocusedBlock(context);
  }
}

mixin FormatStyleDelegate on BaseToolbar {
  void boldText() {
    if (style.fontWeight == FontWeight.w900) {
      style = style.copyWith(
        fontWeight: FontWeight.normal,
      );
    } else {
      style = style.copyWith(fontWeight: FontWeight.w900);
    }
  }

  void italicText() {
    if (style.fontStyle == FontStyle.italic) {
      style = style.copyWith(fontStyle: FontStyle.normal);
    } else {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
  }

  void underlineText() {
    if (style.decoration == TextDecoration.underline) {
      style = style.copyWith(decoration: TextDecoration.none);
    } else {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
  }

  void setBlockAlign(TextAlign newAlign) {
    _attachedController?.setAlign(newAlign);
  }
}

mixin InlineHyperLinkCreator on BaseToolbar {
  HyperLinkData? linkData;

  void clearLinkData() {
    linkData = null;
    print('remove link Data');
  }

  Future<void> addLinkInFocusedBlock(BuildContext context) async {
    final int? cursorOffset = _attachedController?.selection.baseOffset;
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
