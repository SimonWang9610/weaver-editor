import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/block_editing_controller.dart';
import 'package:weaver_editor/interfaces/editor_toolbar.dart';
import 'package:weaver_editor/interfaces/format_node.dart';
import 'package:weaver_editor/interfaces/leaf_text_block_mixin.dart';
import 'package:weaver_editor/interfaces/toolbar_attach_delegate.dart';
import 'content_block.dart';

class LeafTextBlock extends ContentBlock {
  final TextStyle style;

  const LeafTextBlock({
    Key? key,
    required this.style,
    String type = 'paragraph',
  }) : super(key: key);

  @override
  ContentBlockState<LeafTextBlock> createState() => LeafTextBlockState();
}

class LeafTextBlockState extends ContentBlockState<LeafTextBlock>
    with LeafTextBlockOperationDelegate, EditorToolbarDelegate {
  late final BlockEditingController controller;
  final FocusNode focus = FocusNode();
  late FormatNode _node;

  EditorToolbar? attachedToolbar;

  @override
  FormatNode get headNode => _node;

  @override
  set headNode(FormatNode newNode) => _node = newNode;

  StrutStyle get strut => StrutStyle.fromTextStyle(widget.style);
  set strut(StrutStyle newStrut) => strut = newStrut;

  @override
  void initState() {
    super.initState();

    controller = BlockEditingController(
      block: this,
    );

    _node = FormatNode(
      selection: controller.selection,
      style: widget.style,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    _node.dispose();
    super.dispose();
  }

  @override
  bool mayUpdateNodes(
    BlockEditingSelection selection, {
    TextStyle? composedStyle,
  }) {
    // TODO: get EditorToolBar style
    final toolBarStyle = attachedToolbar?.style;

    return super.mayUpdateNodes(selection, composedStyle: toolBarStyle);
  }

  @override
  void attach() {
    // TODO: use context to attach the parent EditorToobar
    // TODO: should listen
    // TODO: when focus is not focusing, should detach EditorToolbar
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // selectionControls: CustomSelectionControls(controller),
      strutStyle: strut,
      style: widget.style,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      controller: controller,
      focusNode: focus,
      maxLines: null,
      onTap: () {
        focus.requestFocus();
      },
    );
  }
}
