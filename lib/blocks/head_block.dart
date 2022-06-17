import 'package:flutter/material.dart';

import 'leaf_text_block.dart';
import '../models/types.dart';
import '../models/nodes/format_node.dart';
import '../extensions/headerline_ext.dart';

class HeaderBlockData extends TextBlockData {
  late HeaderLine level;

  HeaderBlockData({
    this.level = HeaderLine.level1,
    required TextStyle style,
    required String id,
    String type = 'header',
    String text = '',
    FormatNode? headNode,
    TextAlign align = TextAlign.start,
  }) : super(
          id: id,
          type: type,
          style: style,
          headNode: headNode,
          align: align,
          text: text,
        ) {
    level = style.fontSize!.sizeToHeaderLine();
  }

  bool adoptLevel(HeaderLine value) {
    if (level != value) {
      level = value;
      headNode!.style = headNode!.style.copyWith(
        fontSize: level.size,
      );
      return true;
    }
    return false;
  }

  @override
  Widget createPreview() {
    assert(headNode != null);

    return Text(
      text,
      style: headNode?.style ?? style,
      textAlign: align,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    late int headerLevel;

    switch (level) {
      case HeaderLine.level1:
        headerLevel = 1;
        break;
      case HeaderLine.level2:
        headerLevel = 2;
        break;
      case HeaderLine.level3:
        headerLevel = 3;
        break;
    }

    return {
      'id': id,
      'time': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'data': {
        'level': headerLevel,
        'text': headNode?.toPlainText(text, '') ?? '',
        'alignment': align.name,
      }
    };
  }
}

class HeaderBlock extends LeafTextBlock<HeaderBlockData> {
  const HeaderBlock({
    Key? key,
    required HeaderBlockData data,
    String hintText = 'Add Header',
  }) : super(
          key: key,
          data: data,
          hintText: hintText,
        );

  @override
  HeaderBlockState createState() => HeaderBlockState();
}

class HeaderBlockState extends LeafTextBlockState<HeaderBlockData> {
  void changeHeaderLevel(HeaderLine newLevel) {
    if (data.adoptLevel(newLevel)) {
      setState(() {});
    }
  }
}
