import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'format_node.dart';

class HyperLinkNode extends FormatNode {
  TapGestureRecognizer? recognizer;
  final String url;

  HyperLinkNode(
    this.url, {
    required TextSelection selection,
    TextStyle style = const TextStyle(
      inherit: true,
      color: Colors.red,
      decoration: TextDecoration.underline,
      textBaseline: TextBaseline.ideographic,
      fontSize: 28,
    ),
  }) : super(selection: selection, style: style);

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
    recognizer?.dispose();
    super.unlink();
  }

  @override
  void fuse(FormatNode startNode, FormatNode endNode) {
    super.fuse(startNode, endNode);

    if (previous == null && next == null) {
      recognizer?.dispose();
    }
  }

  @override
  TextSpan build(
    String content, {
    bool inPreviewMode = false,
  }) {
    final caption = content.characters.getRange(range.start, range.end).string;

    print('build hyper link node: $url, range: $range');

    // ! must create recognizer after the first build is completed
    // ! otherwise, it will throw recognizer lateInitializationError
    // ! it may because the consecutive two build of a block restored from local database
    // ! when the first build, the WeaverEditorProvider has not been laid out completely.
    // ! so we initialize the recognizer after the WeaverEditorProvider has been laid out/first built
    /// it also may because some operations trigger [TapGestureRecognizer.onTap] during the first build
    /// consequently, it throws LateInitializationError

    ///  only allow to tap for [inPreviewMode]
    /// if we create [recognizer] by [addPostFrameCallback] for [inPreviewMode]
    /// it cannot create successfully
    if (inPreviewMode) {
      recognizer ??= TapGestureRecognizer()..onTap = _handleTap;
    } else {
      // recognizer?.dispose();
      // recognizer = null;

      // WidgetsBinding.instance.addPostFrameCallback(
      //   (_) {
      //     recognizer ??= TapGestureRecognizer()..onTap = _handleTap;
      //   },
      // );
      // ! in edit mode, recognizer may throw exception when scrolling out of this node
      recognizer?.dispose();
      recognizer = null;
    }

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

  @override
  String toPlainText(String content, String result) {
    final text = content.characters.getRange(range.start, range.end).string;

    if (text.isNotEmpty) {
      result += '<a href="$url">$text</a>';
    }

    if (next != null) {
      result = next!.toPlainText(content, result);
    }
    return result;
  }

  void _handleTap() {
    print('double tapped on Hyperlink: $url');
  }

  @override
  String toString() {
    return 'HyperNode: ${super.toString()}';
  }
}
