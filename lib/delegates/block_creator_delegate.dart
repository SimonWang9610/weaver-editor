import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';
import 'package:nanoid/nanoid.dart';
import 'package:weaver_editor/blocks/head_block.dart';
import 'package:weaver_editor/blocks/image_block.dart';
import 'package:weaver_editor/blocks/video_block.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';
import 'package:weaver_editor/models/types.dart';

mixin BlockCreationDelegate {
  String generateId() => nanoid(5);

  BaseBlock createParagraphBlock(TextStyle defaultStyle) {
    final id = generateId();
    return LeafTextBlock(
      id: id,
      key: ValueKey(id),
      style: defaultStyle,
    );
  }

  BaseBlock createHeaderBlock() {
    final id = generateId();

    return HeaderBlock(
      id: id,
      key: ValueKey(id),
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: HeaderLine.level2.size,
      ),
    );
  }

  BaseBlock createImageBlock(EmbedData data) {
    final id = generateId();

    return ImageBlock(
      id: id,
      key: ValueKey(id),
      imageUrl: data.url,
      imageData: data.file,
      caption: data.caption,
    );
  }

  BaseBlock createVideoBlock(EmbedData data) {
    final id = generateId();

    return VideoBlock(
      id: id,
      key: ValueKey(id),
      videoStream: data.file,
      videoUrl: data.url,
      caption: data.caption,
    );
  }
}

bool isValidUrl(EmbedData data) {
  if (data.url != null) {
    final uri = Uri.tryParse(data.url!);

    if (uri != null) {
      return true;
    }
  }
  return false;
}
