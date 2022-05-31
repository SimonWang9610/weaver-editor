import 'package:flutter/material.dart';
import '../widgets/block_editing_controller.dart';
import '../widgets/editor.dart';
import '../models/format_node.dart';
import 'text_operation_transformer.dart';
import '../toolbar/toolbar_attach_delegate.dart';
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
    with EditorToolbarDelegate, LeafTextBlockTransformer {
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
      print('toolbar has attached to block: ${widget.key}');
    } else {
      blockProvider.detachContentBlock();
      attachedToolbar = null;
      print('toolbar has been detached from ${widget.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build text block: ${widget.key}');

    return TextField(
      strutStyle: strut,
      style: widget.style,
      textAlign: align ?? TextAlign.start,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(
            color: Colors.white38,
            width: 1,
          ),
        ),
        hintText: 'Write something',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide.none,
        ),
      ),
      controller: controller,
      focusNode: focus,
      maxLines: null,
    );
  }
}