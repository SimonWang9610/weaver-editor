import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';
import 'package:nanoid/nanoid.dart';
import 'package:weaver_editor/blocks/image_block.dart';
import 'package:weaver_editor/blocks/video_block.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';
import 'package:weaver_editor/models/types.dart';

mixin BlockCreationDelegate {
  ValueKey generateKeyById() => ValueKey(nanoid(5));

  BaseBlock createParagraphBlock(TextStyle defaultStyle) {
    return LeafTextBlock(
      key: generateKeyById(),
      style: defaultStyle,
      type: 'paragraph',
    );
  }

  BaseBlock createImageBlock(EmbedData data) {
    return ImageBlock(
      key: generateKeyById(),
      imageUrl: data.url,
      imageData: data.file,
    );
  }

  BaseBlock createVideoBlock(EmbedData data) {
    return VideoBlock(
      key: generateKeyById(),
      videoStream: data.file,
      videoUrl: data.url,
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
