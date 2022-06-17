import 'package:flutter/material.dart';
import 'package:weaver_editor/delegates/text_operation_delegate.dart';
import '../controller/block_editing_controller.dart';
import '../editor.dart';
import '../models/nodes/format_node.dart';
import '../models/data/block_data.dart';
import 'base_block.dart';

class TextBlockData extends BlockData {
  final TextStyle style;
  TextAlign align;
  FormatNode? headNode;
  String text;

  TextBlockData({
    required this.style,
    required String id,
    String type = 'paragraph',
    this.text = '',
    this.headNode,
    this.align = TextAlign.start,
  }) : super(id: id, type: type);

  void dispose() {
    headNode?.dispose();
  }

  bool adoptAlign(TextAlign value) {
    if (align != value) {
      align = value;
      return true;
    }
    return false;
  }

  @override
  Widget createPreview() {
    assert(headNode != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        textAlign: align,
        text: headNode!.build(text),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'data': {
        'text': headNode?.toPlainText(text, '') ?? '',
        'alignment': align.name,
      }
    };
  }
}

class LeafTextBlock<T extends TextBlockData> extends StatefulBlock<T> {
  final String hintText;
  const LeafTextBlock({
    Key? key,
    this.hintText = 'Write Something',
    required T data,
  }) : super(key: key, data: data);

  @override
  BlockState<LeafTextBlock> createState() => LeafTextBlockState();
}

class LeafTextBlockState<T extends TextBlockData>
    extends BlockState<LeafTextBlock<T>> {
  late final BlockEditingController<T> controller;
  late final TextOperationDelegate<T> _delegate;

  final FocusNode _focus = FocusNode();

  @override
  T get data => widget.data;

  @override
  void initState() {
    super.initState();
    _delegate = TextOperationDelegate<T>(data);

    controller = BlockEditingController<T>(
      delegate: _delegate,
      focus: _focus,
      text: data.text,
    );

    _focus.addListener(handleFocusChange);

    if (data.headNode == null) {
      _focus.requestFocus();
    }

    data.headNode ??= FormatNode(
      selection: controller.selection,
      style: data.style,
    );

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // setBlockSize(context);
  }

  @override
  void dispose() {
    _delegate.dispose();
    controller.dispose();
    _focus.removeListener(handleFocusChange);
    _focus.dispose();
    super.dispose();
  }

  void handleFocusChange() {
    final editorController = EditorController.of(context);

    if (_focus.hasFocus) {
      _delegate.attachedToolbar = editorController.attachBlock(controller);
      _delegate.performTaskAfterAttached();

      print('toolbar has attached to block: ${widget.key}');
    } else {
      // blockProvider.detachContentBlock();
      _delegate.detach();
      print('toolbar has been detached from ${widget.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build text block: ${widget.key}');

    super.build(context);

    setBlockSize(context);

    return TextField(
      enabled: true,
      strutStyle: StrutStyle.fromTextStyle(data.style),
      style: data.style,
      textAlign: data.align,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(
            color: Colors.white38,
            width: 1,
          ),
        ),
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide.none,
        ),
      ),
      controller: controller,
      focusNode: _focus,
      maxLines: null,
    );
  }
}
