import 'package:characters/characters.dart';
import 'package:weaver_editor/core/delegates/block_serialization.dart';
import 'package:weaver_editor/core/nodes/parsed_node.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';
import 'package:weaver_editor/core/nodes/hyper_link_node.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/extensions/text_style_ext.dart';

class StringUtil {
  static final List<RegExp> youtubeMatchers = [
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ];

  static final List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];

  static String? extractYoutubeId(String youtubeUrl) {
    String? id;
    for (final matcher in youtubeMatchers) {
      final matched = matcher.firstMatch(youtubeUrl);

      if (matched != null && matched.groupCount >= 1) {
        id = matched.group(1);
        break;
      }
    }
    return id;
  }

  static ClipboardUrl tryExtractUrl(String? text) {
    if (text == null || !text.startsWith('http')) return ClipboardUrl.empty();

    bool isValidUrl = Uri.tryParse(text)?.host.isNotEmpty ?? false;

    if (!isValidUrl) return ClipboardUrl.empty();

    String? youtubeUrl = StringUtil.extractYoutubeId(text);
    String? imageUrl;
    String? externalUrl;

    if (youtubeUrl == null) {
      final ext = text.substring(text.lastIndexOf('.') + 1);
      if (imageExtensions.contains(ext.toLowerCase())) {
        imageUrl = text;
      } else {
        externalUrl = text;
      }
    }

    return ClipboardUrl(
      imageUrl: imageUrl,
      youtubeUrl: youtubeUrl,
      externalUrl: externalUrl,
    );
  }

  static String extractText(String? source, FormatNode? headNode) {
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
}
