import 'package:flutter/material.dart';

import 'package:weaver_editor/editor.dart' show EditorController;
import 'package:weaver_editor/controller/block_editing_controller.dart';
import 'package:weaver_editor/core/delegates/text_operation_delegate.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';

import 'data/text_block_data.dart';

import '../base/block_base.dart';

Widget defaultTextBlockBuilder<T extends TextBlockData>(T data) =>
    TextBlockWidget(
      key: ValueKey(data.id),
      data: data,
    );

class TextBlock<T extends TextBlockData> extends BlockBase<T> {
  TextBlock({
    required T data,
    BlockBuilder? builder,
  }) : super(
          data: data,
          builder: builder ?? defaultTextBlockBuilder<T>,
        );
}

class TextBlockWidget<T extends TextBlockData> extends StatefulBlock<T> {
  final String hintText;
  const TextBlockWidget({
    Key? key,
    this.hintText = 'Write Something',
    required T data,
  }) : super(
          data: data,
          key: key,
        );

  @override
  BlockState<T, TextBlockWidget<T>> createState() => TextBlockState<T>();
}

class TextBlockState<T extends TextBlockData>
    extends BlockState<T, TextBlockWidget<T>> {
  late final BlockEditingController _controller;
  late final TextOperationDelegate<T> _delegate;

  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    print('initializing block: ${data.id}');
    _delegate = TextOperationDelegate<T>(data);

    _controller = BlockEditingController(
      delegate: _delegate,
      focus: _focus,
      text: data.text,
    );

    _focus.addListener(_handleFocusChange);

    if (data.headNode == null) {
      _focus.requestFocus();
    }

    data.headNode ??= FormatNode(
      selection: _controller.selection,
      style: data.style,
    );

    // to update TextAlign/HeaderLine
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _delegate.dispose();
    _controller.dispose();
    _focus.removeListener(_handleFocusChange);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build text block: ${widget.key}');

    super.build(context);

    setRenderObject(context);

    return TextField(
      // enabled: true,
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
      controller: _controller,
      focusNode: _focus,
      maxLines: null,
    );
  }

  void _handleFocusChange() {
    final editorController = EditorController.of(context);

    if (_focus.hasFocus) {
      _delegate.attachedToolbar = editorController.attachBlock(_controller);
      _delegate.performTaskAfterAttached();

      print('toolbar has attached to block: ${widget.key}');
    } else {
      // blockProvider.detachContentBlock();
      _delegate.detach();
      print('toolbar has been detached from ${widget.key}');
    }
  }
}
