import 'package:characters/characters.dart';
import 'package:weaver_editor/core/delegates/block_serialization.dart';
import 'package:weaver_editor/core/nodes/parsed_node.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';
import 'package:weaver_editor/core/nodes/hyper_link_node.dart';

import 'package:weaver_editor/extensions/text_style_ext.dart';

String extractText(String? source, FormatNode? headNode) {
  String text = '';

  if (source == null || headNode == null) {
    return source ?? text;
  }

  final List<ParsedNode> parsedNodes = BlockDeserializer().parse(source);

  for (final node in parsedNodes) {
    late FormatNode format;

    //! because NodeRange incudes [start] but not includes [end]
    final start = text.characters.length;
    final end = start + node.text.characters.length;

    if (node.url != null) {
      format = HyperLinkNode.position(
        start,
        end,
        url: node.url!,
      );
    } else {
      final style = headNode.style.mergeTags(node.tags);

      format = FormatNode.position(
        start,
        end,
        style: style,
      );
    }

    text += node.text;

    headNode.append(format);
  }

  return text;
}
