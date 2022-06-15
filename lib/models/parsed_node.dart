import 'package:weaver_editor/models/format_node.dart';

class ParsedNode {
  final String? url;
  final String text;
  final List<String> tags;

  ParsedNode(
    this.text, {
    required this.tags,
    this.url,
  });

  @override
  String toString() {
    if (url != null) {
      return '<a> $text : $url';
    } else {
      if (tags.isEmpty) return text;
      return '${tags.reduce((value, element) => value + element)} $text';
    }
  }
}
