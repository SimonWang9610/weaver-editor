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

enum BlockListEvent {
  insert,
  remove,
  reorder,
}

class EmbedData {
  final String? url;
  final PlatformFile? file;

  EmbedData({
    this.file,
    this.url,
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
