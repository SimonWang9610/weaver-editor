import 'package:file_picker/file_picker.dart';

enum BlockEditingStatus {
  init,
  insert,
  select,
  delete,
}

enum BlockType {
  paragraph,
  list,
  image,
  video,
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
