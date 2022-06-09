import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/head_block.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';

import 'editing_compare.dart';
import 'toolbar_change_delegate.dart';

class BlockEditingController extends TextEditingController
    with ToolbarChangeDelegate, BlockEditingCompare {
  final LeafTextBlockState _block;

  BlockEditingController({
    String? text,
    required LeafTextBlockState block,
  })  : _block = block,
        super(text: text);

  @override
  LeafTextBlockState get block => _block;

  String get blockType => _block.widget.type;
  HeaderLine? get headerLevel {
    if (isHeaderBlock) {
      return (block as HeaderBlockState).level;
    } else {
      return null;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // avoid throw exception when first focusing on the new created block
    if (!_block.headNode.range.isValid) {
      return TextSpan(style: _block.widget.style, text: text);
    }

    TextStyle? forcedStyle;

    if (isHeaderBlock) {
      //forcedStyle = _block.widget.style;
      _block.headNode.synchronize(_block.headNode.style);
    }

    return _block.headNode.build(
      value.text,
      forcedStyle: forcedStyle,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    // compare the old value and new value to determine [BlockEditingStatus]
    final editingSelection = compare(newValue);

    // print('old value selection: ${value.selection}');
    // print('new value selection: ${newValue.selection}');
    // print('status: ${editingSelection.status}');
    // print('delta: ${editingSelection.delta}');

    // transform the operation of [BlockEditingStatus] to create/update [FormatNode]
    final styleMerged = _block.transform(editingSelection);

    if (value != newValue || styleMerged) {
      super.value = newValue;
    }
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

    value = value.copyWith(
      text: newText,
      selection: newSelection,
    );
  }
}
