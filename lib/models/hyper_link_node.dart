import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'format_node.dart';

class HyperLinkNode extends FormatNode {
  late final TapGestureRecognizer recognizer;
  final String url;

  HyperLinkNode(
    this.url, {
    required TextSelection selection,
    TextStyle style = const TextStyle(
      color: Colors.red,
      decoration: TextDecoration.underline,
      textBaseline: TextBaseline.ideographic,
      fontSize: 28,
    ),
  }) : super(selection: selection, style: style) {
    recognizer = TapGestureRecognizer()..onTap = _handleTap;
  }

  factory HyperLinkNode.position(
    int start,
    int end, {
    required String url,
  }) {
    final selection = TextSelection(baseOffset: start, extentOffset: end);
    return HyperLinkNode(url, selection: selection);
  }

  @override
  void unlink() {
    recognizer.dispose();
    super.unlink();
  }

  @override
  void fuse(FormatNode startNode, FormatNode endNode) {
    super.fuse(startNode, endNode);

    if (previous == null && next == null) {
      recognizer.dispose();
    }
  }

  @override
  TextSpan build(String content) {
    final caption = content.characters.getRange(range.start, range.end).string;

    final chainedSpan = next?.build(content);

    return TextSpan(
      style: style,
      text: caption.isNotEmpty ? caption : null,
      recognizer: recognizer,
      children: [
        chainedSpan ?? const TextSpan(text: ''),
      ],
    );
  }

  void _handleTap() {
    print('double tapped on Hyperlink: $url');
  }
}
