import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weaver_editor/toolbar/toolbar_delegates.dart';
import 'package:weaver_editor/models/types.dart';
import '../controller/block_editing_controller.dart';

enum ToolbarEvent {
  formatting,
  synchronizing,
  align,
  header,
  blockType,
}

abstract class BaseToolbar
    with AttachedBlockDelegate, ToolbarStyleDelegate, ToolbarHeaderDelegate {
  @override
  final StreamController<ToolbarEvent> notifier = StreamController.broadcast();
  late StreamSubscription _subscription;

  BlockEditingController? _attachedController;

  @override
  BlockEditingController? get attachedController => _attachedController;

  @override
  set attachedController(BlockEditingController? value) =>
      _attachedController = value;

  BaseToolbar({required TextStyle defaultStyle, TextAlign? defaultAlign}) {
    style = defaultStyle;
    historyStyle = defaultStyle;
    align = defaultAlign ?? TextAlign.start;
    level = HeaderLine.level1;

    _subscription = notifier.stream.listen(
      (event) {
        if (event == ToolbarEvent.formatting) {
          _attachedController?.mayApplyStyle();
        }

        switch (event) {
          case ToolbarEvent.formatting:
            _attachedController?.mayApplyStyle();
            break;
          case ToolbarEvent.align:
            _attachedController?.applyAlign(align);
            break;
          case ToolbarEvent.header:
            _attachedController?.applyHeaderLevel(level);
            break;
          default:
            break;
        }
      },
    );
  }

  void dispose() {
    notifier.close();
    _subscription.cancel();
  }

  StreamSubscription listen(void Function(ToolbarEvent) handler) {
    return notifier.stream.listen(handler);
  }
}

class EditorToolbar extends BaseToolbar with InlineHyperLinkCreator {
  EditorToolbar(TextStyle style, {TextAlign? align})
      : super(defaultStyle: style, defaultAlign: align);

  @override
  EditorToolbar attach(BlockEditingController controller) {
    // TODO: synchronize the align of blocks

    if (controller.headerLevel != null) {
      level = controller.headerLevel!;
    }

    // ! must force to synchronize the block style to default
    // ! otherwise, the toolbar style will pollute the new created text block
    if (controller.text.isEmpty && controller.selection.start <= 0) {
      synchronize(controller.blockDefaultStyle);
    }

    super.attach(controller);

    return this;
  }

  void executeTaskAfterAttached() {
    _attachedController?.insertLinkNode(linkData);
  }

  @override
  Future<void> addLinkInFocusedBlock(BuildContext context) async {
    await super.addLinkInFocusedBlock(context);
  }
}
