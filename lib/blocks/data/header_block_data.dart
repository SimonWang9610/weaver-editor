import 'package:flutter/material.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/extensions/headerline_ext.dart';
import 'text_block_data.dart';

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
