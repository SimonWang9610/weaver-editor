import 'package:flutter/material.dart';
import '../controller/block_editing_controller.dart';
import '../editor.dart';
import '../models/format_node.dart';
import '../delegates/text_operation_transformer.dart';
import '../delegates/toolbar_attach_delegate.dart';
import 'base_block.dart';

/// in preview mode, we do not allow to edit [LeafTextBlock]
/// so we will Wrap its [FormatNode] using [RichText]
/// to apply [TextStyle] and enable hit testing
/// after [LeafTextBlockState] is initialized, we must [handleFocusChange]
/// to determine if we need to attach/detach [EditorToolbar] by [EditorBlockProvider]
class LeafTextBlock extends StatefulBlock {
  final TextStyle style;
  final String? text;
  final FormatNode? initNode;
  final TextAlign? align;
  // final String id;
  LeafTextBlock({
    Key? key,
    String type = 'paragraph',
    required this.style,
    required String id,
    this.initNode,
    this.text,
    this.align,
  }) : super(
          key: key,
          id: id,
          type: type,
        );

  @override
  BlockState<LeafTextBlock> createState() => LeafTextBlockState();

  @override
  late StatefulBlockElement element;

  @override
  Widget buildForPreview() {
    final state = element.state as LeafTextBlockState;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        textAlign: state.align ?? TextAlign.start,
        text: state._node.build(state.controller.text),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final state = element.state as LeafTextBlockState;

    return {
      'id': id,
      'time': DateTime.now().millisecondsSinceEpoch,
      'type': 'paragraph',
      'data': {
        'text': state.headNode.toMap(state.controller.text, ''),
        'alignment': state.align?.name ?? TextAlign.start.name,
      }
    };
  }
}

class LeafTextBlockState extends BlockState<LeafTextBlock>
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

    // final TextEditingValue value = widget.text == null
    //     ? TextEditingValue.empty
    //     : TextEditingValue(
    //         text: widget.text!,
    //         selection: TextSelection.collapsed(
    //           offset: widget.text!.characters.length,
    //         ),
    //       );

    // controller = BlockEditingController.fromValue(
    //   block: this,
    //   value: value,
    // );
    controller = BlockEditingController(
      block: this,
      text: widget.text,
    );

    _node = widget.initNode ??
        FormatNode(
          selection: controller.selection,
          style: widget.style,
        );

    defaultStyle = widget.style;

    align = widget.align;

    focus.addListener(handleFocusChange);

    if (widget.initNode == null) {
      focus.requestFocus();
    }
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
    final editorController = EditorController.of(context);

    if (focus.hasFocus) {
      attachedToolbar = editorController.attachBlock(controller);
      attachedToolbar?.executeTaskAfterAttached();

      print('toolbar has attached to block: ${widget.key}');
    } else {
      // blockProvider.detachContentBlock();
      attachedToolbar = null;
      print('toolbar has been detached from ${widget.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build text block: ${widget.key}');

    super.build(context);

    return TextField(
      enabled: true,
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
