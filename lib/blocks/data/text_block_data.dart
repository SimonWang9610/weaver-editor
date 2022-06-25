import 'package:flutter/material.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';
import '../../base/block_data.dart';

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
    print('disposing text block data');
    headNode?.dispose();
    //! headNode = null;
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
        text: headNode!.build(text, inPreviewMode: true),
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
