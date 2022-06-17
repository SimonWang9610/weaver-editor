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
      key: ValueKey(id),
      data: TextBlockData(
        id: id,
        style: defaultStyle,
      ),
    );
  }

  BaseBlock createHeaderBlock() {
    final id = generateId();

    return HeaderBlock(
      key: ValueKey(id),
      data: HeaderBlockData(
        id: id,
        align: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: HeaderLine.level1.size,
        ),
      ),
    );
  }

  BaseBlock createImageBlock(EmbedData data) {
    final id = generateId();

    return ImageBlock(
      key: ValueKey(id),
      data: ImageBlockData(
        id: id,
        imageUrl: data.url,
        imagePath: data.file?.path,
        caption: data.caption,
      ),
    );
  }

  BaseBlock createVideoBlock(EmbedData data) {
    final id = generateId();

    return VideoBlock(
      key: ValueKey(id),
      data: VideoBlockData(
        id: id,
        videoPath: data.file?.path,
        videoUrl: data.url,
        caption: data.caption,
      ),
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
