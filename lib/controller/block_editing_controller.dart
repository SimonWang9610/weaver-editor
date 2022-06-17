import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/head_block.dart';
import 'package:weaver_editor/delegates/text_operation_delegate.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';

import 'editing_compare.dart';
import 'toolbar_change_delegate.dart';

class BlockEditingController<T extends TextBlockData>
    extends TextEditingController
    with ToolbarChangeDelegate, BlockEditingCompare {
  final TextOperationDelegate _delegate;
  final FocusNode? focus;

  BlockEditingController({
    String? text,
    required TextOperationDelegate delegate,
    this.focus,
  })  : _delegate = delegate,
        super(text: text);

  BlockEditingController.fromValue({
    TextEditingValue? value,
    required TextOperationDelegate delegate,
    this.focus,
  })  : _delegate = delegate,
        super.fromValue(value);

  String get blockType => _delegate.data.type;
  bool get isHeaderBlock => _delegate.data is HeaderBlockData;

  @override
  TextOperationDelegate get delegate => _delegate;

  HeaderLine? get headerLevel {
    if (isHeaderBlock) {
      return (_delegate.data as HeaderBlockData).level;
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // avoid throw exception when first focusing on the new created block
    if (!delegate.headNode.range.isValid) {
      return TextSpan(style: delegate.defaultStyle, text: text);
    }

    if (isHeaderBlock) {
      //forcedStyle = _block.widget.style;
      delegate.mergeStyle();
    }

    // print('headNode: ${delegate.headNode}');
    return delegate.build(value.text);
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
    final styleMerged = delegate.transform(editingSelection);

    if (value != newValue || styleMerged) {
      super.value = newValue;
    }
  }

  void detach() {
    if (focus != null && focus!.hasFocus) {
      focus?.unfocus();
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
