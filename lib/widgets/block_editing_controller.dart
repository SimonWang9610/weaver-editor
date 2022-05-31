import 'package:flutter/material.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';

class BlockEditingController extends TextEditingController
    with BlockEditingCompare {
  final LeafTextBlockState _block;
  EditorToolbar? attachedBar;

  BlockEditingController({
    String? text,
    required LeafTextBlockState block,
  })  : _block = block,
        super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    print('building custom text span');

    // if (!value.isComposingRangeValid || !withComposing) {
    //   final defaultStyle = _block.headNode.style;
    //   return TextSpan(style: defaultStyle, text: text);
    // }

    if (!_block.headNode.range.isValid) {
      return TextSpan(style: _block.headNode.style, text: text);
    }

    return _block.headNode.build(value.text);
  }

  @override
  set value(TextEditingValue newValue) {
    final editingSelection = compare(newValue);

    final styleMerged = _block.transform(editingSelection);

    print('old value selection: ${value.selection}');
    print('new value selection: ${newValue.selection}');
    print('selection offset: ${editingSelection.delta}');
    print('style merged: $styleMerged');

    if (value != newValue || styleMerged) {
      super.value = newValue;
    }
  }

  // will update value or style by EditorToolbar state
  void mayApplyStyle() {
    if (!selection.isCollapsed) {
      value = value.copyWith();
    }
  }

  void unfocus() {
    if (_block.focus.hasFocus) {
      _block.focus.unfocus();
    }
  }
}

enum BlockEditingStatus {
  init,
  insert,
  select,
  delete,
}

class BlockEditingSelection {
  final TextSelection old;
  final TextSelection latest;
  final BlockEditingStatus status;
  final int delta;

  BlockEditingSelection({
    required this.old,
    required this.latest,
    required this.delta,
    required this.status,
  });
}

mixin BlockEditingCompare on TextEditingController {
  BlockEditingSelection compare(TextEditingValue newValue) {
    final textOffset =
        newValue.text.characters.length - value.text.characters.length;

    final selectionOffset = newValue.selection - value.selection;

    late final BlockEditingStatus status;
    if (textOffset > 0 && selectionOffset.isCollapsed) {
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

extension TextSelectionCompare on TextSelection {
  TextSelection operator -(TextSelection other) {
    final start = this.start - other.start;
    final end = this.end - other.end;

    return TextSelection(
        baseOffset: start >= -1 ? start : -1,
        extentOffset: end >= -1 ? end : -1);
  }
}
