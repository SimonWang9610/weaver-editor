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
