import 'package:flutter/material.dart';
import 'package:weaver_editor/models/editing_selection.dart';
import 'package:weaver_editor/models/types.dart';

mixin BlockEditingCompare on TextEditingController {
  BlockEditingSelection compare(TextEditingValue newValue) {
    final textOffset =
        newValue.text.characters.length - value.text.characters.length;

    // final selectionOffset = newValue.selection - value.selection;

    late final BlockEditingStatus status;
    if (textOffset > 0) {
      status = BlockEditingStatus.insert;
    } else if (textOffset < 0) {
      status = BlockEditingStatus.delete;
    } else if (!value.selection.isValid &&
        newValue.selection.isCollapsed &&
        newValue.selection.baseOffset == 0) {
      status = BlockEditingStatus.init;
    } else {
      status = BlockEditingStatus.select;
    }

    return BlockEditingSelection(
      old: value.selection,
      latest: newValue.selection,
      delta: textOffset,
      status: status,
    );
  }
}
