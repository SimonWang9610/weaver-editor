import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/head_block.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';
import 'package:weaver_editor/blocks/video_block.dart';
import 'package:weaver_editor/delegates/block_serialization.dart';
import 'package:weaver_editor/models/nodes/hyper_link_node.dart';
import 'package:weaver_editor/models/nodes/parsed_node.dart';

import 'base_block.dart';
import 'image_block.dart';
import '../models/types.dart';
import '../models/nodes/format_node.dart';
import '../extensions/headerline_ext.dart';
import '../extensions/text_style_ext.dart';

/// the block [map] of [fromMap] must be the format:
/// {
///   'id': string,
///   'type': string,
///   'data': {
///        ...
///    }
/// }
/// it should be conformant to the [toMap] of each kind of block
///
/// *
/// 1) each block must have a [ValueKey] from its [id] to keep state during re-order/draggable

class BlockFactory {
  static final BlockDeserializer deserializer = BlockDeserializer();

  static final _instance = BlockFactory._();

  factory BlockFactory() => _instance;

  BlockFactory._();

  BaseBlock fromMap(Map<String, dynamic> map, TextStyle defaultStyle) {
    final String type = map['type'];
    final Map<String, dynamic> data = map['data'];
    final String id = map['id'];

    switch (type) {
      case 'image':
        return toImageBlock(id, data);
      case 'embed':
        return toVideoBlock(id, data);
      case 'paragraph':
        return toTextBlock(id, data, defaultStyle);
      case 'header':
        return toHeaderBlock(id, data);
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
      key: ValueKey(id),
      data: ImageBlockData(
        id: id,
        imagePath: path,
        imageUrl: url,
        caption: map['caption'],
      ),
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
      key: ValueKey(id),
      data: VideoBlockData(
        id: id,
        videoUrl: url,
        videoPath: path,
        caption: map['caption'],
      ),
    );
  }

  BaseBlock toHeaderBlock(String id, Map<String, dynamic> map) {
    final String? align = map['alignment'];
    final num? level = map['level'];
    final TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: level?.levelHeaderLine().size ?? HeaderLine.level1.size,
    );

    final FormatNode headNode = FormatNode.position(
      0,
      0,
      style: style,
    );

    final String text = extractText(map['text'], headNode);

    return HeaderBlock(
      key: ValueKey(id),
      data: HeaderBlockData(
        id: id,
        text: text,
        align: align?.toTextAlign() ?? TextAlign.start,
        style: style,
        headNode: headNode,
      ),
    );
  }

  BaseBlock toTextBlock(
      String id, Map<String, dynamic> map, TextStyle defaultStyle) {
    final FormatNode headNode = FormatNode.position(
      0,
      0,
      style: defaultStyle,
    );

    final String? align = map['align'];

    final String text = extractText(map['text'], headNode);

    return LeafTextBlock(
      key: ValueKey(id),
      data: TextBlockData(
        style: headNode.style,
        id: id,
        headNode: headNode,
        text: text,
        align: align?.toTextAlign() ?? TextAlign.start,
      ),
    );
  }

  String extractText(String source, FormatNode headNode) {
    String text = '';

    final List<ParsedNode> parsedNodes = deserializer.parse(source);

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
