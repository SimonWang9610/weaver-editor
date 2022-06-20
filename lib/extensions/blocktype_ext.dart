import 'package:flutter/foundation.dart';
import 'package:weaver_editor/models/types.dart';

extension ToBlockType on String? {
  BlockType? asType() {
    if (this == null) return null;

    switch (this) {
      case 'image':
        return BlockType.image;
      case 'embed':
        return BlockType.video;
      case 'paragraph':
        return BlockType.paragraph;
      case 'header':
        return BlockType.header;
      default:
        throw ErrorDescription('Unsupported BlockType: $this');
    }
  }
}
