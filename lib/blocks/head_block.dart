import 'package:flutter/material.dart';

import 'leaf_text_block.dart';
import '../models/types.dart';
import '../models/format_node.dart';
import '../extensions/headerline_ext.dart';

class HeaderBlock extends LeafTextBlock {
  HeaderBlock({
    Key? key,
    required String id,
    required TextStyle style,
    String? text,
    FormatNode? initNode,
    TextAlign? align,
    String type = 'header',
  }) : super(
          key: key,
          id: id,
          style: style,
          type: type,
          text: text,
          align: align,
          initNode: initNode,
        );

  @override
  Widget buildForPreview() {
    final state = element.state as HeaderBlockState;
    return Text(
      state.controller.text,
      style: state.headNode.style,
      textAlign: state.align ?? TextAlign.center,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final state = element.state as HeaderBlockState;

    late int level;

    switch (state.level) {
      case HeaderLine.level1:
        level = 1;
        break;
      case HeaderLine.level2:
        level = 2;
        break;
      case HeaderLine.level3:
        level = 3;
        break;
    }

    return {
      'id': id,
      'time': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'data': {
        'level': level,
        'text': state.headNode.toMap(state.controller.text, ''),
        'alignment': state.align?.name ?? TextAlign.center.name,
      }
    };
  }

  @override
  HeaderBlockState createState() => HeaderBlockState();
}

class HeaderBlockState extends LeafTextBlockState {
  late HeaderLine level;

  @override
  void initState() {
    super.initState();
    level = widget.style.fontSize!.sizeToHeaderLine();
  }

  void changeHeaderLevel(HeaderLine newLevel) {
    if (level != newLevel) {
      level = newLevel;
      headNode.style = headNode.style.copyWith(
        fontSize: level.size,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return TextField(
      strutStyle: strut,
      style: widget.style,
      textAlign: align ?? TextAlign.center,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(
            color: Colors.white38,
            width: 1,
          ),
        ),
        hintText: 'Add Header',
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
