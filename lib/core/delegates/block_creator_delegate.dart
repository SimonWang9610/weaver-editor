import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/blocks/blocks.dart';

import 'package:weaver_editor/models/types.dart';

mixin BlockCreationDelegate {
  String generateId() => nanoid(5);

  BlockBase createParagraphBlock(TextStyle defaultStyle) {
    final id = generateId();

    return TextBlock(
      data: TextBlockData(
        style: defaultStyle,
        id: id,
      ),
    );
  }

  BlockBase createHeaderBlock() {
    final id = generateId();

    return HeaderBlock(
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

  BlockBase createImageBlock(EmbedData data) {
    final id = generateId();

    return ImageBlock(
      data: ImageBlockData(
        id: id,
        imageUrl: data.url,
        imagePath: data.file?.path,
        caption: data.caption,
      ),
    );
  }

  BlockBase createVideoBlock(EmbedData data) {
    final id = generateId();

    return VideoBlock(
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
