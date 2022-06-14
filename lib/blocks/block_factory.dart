import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';
import 'package:weaver_editor/blocks/video_block.dart';
import 'package:weaver_editor/delegates/block_serialization.dart';
import 'package:weaver_editor/models/hyper_link_node.dart';
import 'package:weaver_editor/models/parsed_node.dart';

import 'base_block.dart';
import 'image_block.dart';
import '../models/types.dart';
import '../models/format_node.dart';

class BlockFactory {
  static final BlockDeserializer deserializer = BlockDeserializer();

  BaseBlock fromMap(Map<String, dynamic> map) {
    final String type = map['type'];

    switch (type) {
      case 'image':
        return toImageBlock(map['id'], map['data']);
      case 'embed':
        return toVideoBlock(map['id'], map['data']);
      default:
        throw ErrorDescription('Under development');
    }
  }

  BaseBlock toImageBlock(String id, Map<String, dynamic> map) {
    String? url;
    String? path;

    if ((map['file'] as String).startsWith('http')) {
      url = map['file'];
    } else {
      path = map['file'];
    }

    return ImageBlock(
      id: id,
      imagePath: path,
      imageUrl: url,
      caption: map['caption'],
    );
  }

  BaseBlock toVideoBlock(String id, Map<String, dynamic> map) {
    String? url;
    String? path;

    if ((map['embed'] as String).startsWith('http')) {
      url = map['embed'];
    } else {
      path = map['embed'];
    }

    return VideoBlock(
      id: id,
      videoUrl: url,
      videoPath: path,
      caption: map['caption'],
    );
  }

  BaseBlock toTextBlock(String id, Map<String, dynamic> map) {
    final FormatNode headNode = FormatNode.position(
      0,
      0,
      style: const TextStyle(),
    );

    final String text = extractText(map['text'], headNode);

    return LeafTextBlock(
      style: headNode.style,
      id: id,
      initNode: headNode,
      text: text,
      align: map['align'] ?? TextAlign.start,
    );
  }

  String extractText(String source, FormatNode headNode) {
    String text = '';

    final List<ParsedNode> parsedNodes = deserializer.parse(source);

    for (final node in parsedNodes) {
      late FormatNode format;

      //! because NodeRange incudes [start] but not includes [end]
      final start = text.characters.length + 1;
      final end = start + node.text.characters.length;

      if (node.url != null) {
        format = HyperLinkNode.position(
          start,
          end,
          url: node.url!,
        );
      } else {
        format = FormatNode.position(
          start,
          end,
          style: textStyleFromTags(
            headNode.style,
            node.tags,
          ),
        );
      }

      text += node.text;

      headNode.append(format);
    }

    return text;
  }

  TextStyle textStyleFromTags(TextStyle style, List<String> tags) {
    for (final tag in tags) {
      switch (tag) {
        case '<b>':
          style = style.copyWith(
            fontWeight: FontWeight.w900,
          );
          break;
        case '<i>':
          style = style.copyWith(
            fontStyle: FontStyle.italic,
          );
          break;
        case '<u>':
          style = style.copyWith(
            decoration: TextDecoration.underline,
          );
          break;
      }
    }
    return style;
  }
}
