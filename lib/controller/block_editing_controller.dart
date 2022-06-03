import 'package:flutter/material.dart';
import 'package:weaver_editor/widgets/buttons/add_link_button.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';

import 'controller_delegates.dart';

class BlockEditingController extends TextEditingController
    with BlockEditingCompare {
  final LeafTextBlockState _block;

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
    if (!_block.headNode.range.isValid) {
      return TextSpan(style: _block.headNode.style, text: text);
    }

    return _block.headNode.build(value.text);
  }

  @override
  set value(TextEditingValue newValue) {
    final editingSelection = compare(newValue);

    print('old value selection: ${value.selection}');
    print('new value selection: ${newValue.selection}');
    print('status: ${editingSelection.status}');
    print('delta: ${editingSelection.delta}');

    final styleMerged = _block.transform(editingSelection);

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

  void setAlign(TextAlign newAlign) {
    _block.setAlign(newAlign);
  }

  void insertLinkNode(HyperLinkData? data) {
    if (data == null) return;

    final newText = data.pos != null
        ? value.text.substring(0, data.pos) +
            data.caption +
            value.text.substring(data.pos!)
        : value.text + data.caption;

    final baseOffset =
        value.selection.baseOffset + data.caption.characters.length;
    final newSelection = TextSelection.collapsed(
      offset: baseOffset,
    );

    print('link node: $newText');
    value = value.copyWith(
      text: newText,
      selection: newSelection,
    );
  }
}
