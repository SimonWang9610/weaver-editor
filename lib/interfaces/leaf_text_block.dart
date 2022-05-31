import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/block_editing_controller.dart';
import 'package:weaver_editor/interfaces/editor.dart';
import 'package:weaver_editor/interfaces/format_node.dart';
import 'package:weaver_editor/interfaces/leaf_text_block_mixin.dart';
import 'package:weaver_editor/interfaces/toolbar_attach_delegate.dart';
import 'content_block.dart';

class LeafTextBlock extends ContentBlock {
  final String type;
  final TextStyle style;

  const LeafTextBlock({
    Key? key,
    required this.style,
    required this.type,
  }) : super(key: key);

  @override
  ContentBlockState<LeafTextBlock> createState() => LeafTextBlockState();
}

class LeafTextBlockState extends ContentBlockState<LeafTextBlock>
    with EditorToolbarDelegate, LeafTextBlockOperationDelegate {
  late final BlockEditingController controller;
  final FocusNode focus = FocusNode();
  late FormatNode _node;

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

    print('headNode: ${_node.range}');
    focus.addListener(handleFocusChange);

    focus.requestFocus();
  }

  @override
  void dispose() {
    focus.removeListener(handleFocusChange);

    controller.dispose();
    focus.dispose();
    _node.dispose();
    super.dispose();
  }

  @override
  void handleFocusChange() {
    final blockProvider = EditorBlockProvider.of(context);

    if (focus.hasFocus) {
      attachedToolbar = blockProvider.attachContentBlock(controller);
    } else {
      blockProvider.detachContentBlock();
      attachedToolbar = null;
    }
    print('toolbar has attached to block');
  }

  @override
  Widget build(BuildContext context) {
    print('build text block: ${widget.key}');

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
        print('tapped on text block');
      },
      onEditingComplete: () {
        focus.unfocus();
        // TODO: should create new ContentBblock inside of ContainerBlock
      },
    );
  }
}
