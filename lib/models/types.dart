import 'package:file_picker/file_picker.dart';

enum BlockEditingStatus {
  init,
  insert,
  select,
  delete,
}

enum BlockType {
  paragraph('paragraph'),
  list('list'),
  image('image'),
  video('video'),
  header('header');

  final String type;
  const BlockType(this.type);
}

enum BlockOperation {
  insert,
  remove,
  reorder,
  replace,
}

enum OverlayDirection {
  left,
  right,
}

enum HeaderLine {
  level1(60),
  level2(48),
  level3(36);

  final double size;
  const HeaderLine(this.size);
}

class HyperLinkData {
  final String url;
  final String caption;
  final int? pos;

  HyperLinkData(
    this.url, {
    required this.caption,
    this.pos,
  });
}

class BlockOperationEvent {
  final BlockOperation operation;
  final int index;
  BlockOperationEvent(this.operation, {required this.index});
}

class EmbedData {
  final String? url;
  final PlatformFile? file;
  final String? caption;

  EmbedData({
    this.file,
    this.url,
    this.caption,
  });

  bool get isValid => isValidUrl || file != null;

  bool get isValidUrl {
    if (url != null) {
      final uri = Uri.tryParse(url!);

      if (uri != null) {
        return true;
      }
    }
    return false;
  }
}

class ClipboardUrl {
  final String? imageUrl;
  final String? youtubeUrl;
  final String? externalUrl;

  ClipboardUrl({
    this.imageUrl,
    this.youtubeUrl,
    this.externalUrl,
  });

  factory ClipboardUrl.empty() => ClipboardUrl();

  bool get hasValidUrl =>
      imageUrl != null || youtubeUrl != null || externalUrl != null;

  EmbedData? asEmbedData() {
    if (hasValidUrl) {
      return EmbedData(url: youtubeUrl ?? imageUrl);
    }
    return null;
  }

  BlockType get type {
    assert(hasValidUrl,
        'Cannot determine which [BlockType] should be because no valid remote URL was provided.');
    if (youtubeUrl != null) {
      return BlockType.video;
    } else {
      return BlockType.image;
    }
  }

  @override
  String toString() {
    return 'ClipboardUrl(image: $imageUrl, youtube: $youtubeUrl, external: $externalUrl)';
  }
}

enum ListBlockStyle {
  unordered('unordered'),
  ordered('ordered');

  final String style;

  const ListBlockStyle(this.style);
}
