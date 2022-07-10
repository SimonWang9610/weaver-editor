import 'package:flutter/widgets.dart';

abstract class BlockData {
  final String id;
  final String type;
  Size? size;
  Offset? offset;

  BlockData({required this.id, required this.type});

  Widget createPreview();
  Map<String, dynamic> toMap();
  bool get isNotEmpty => true;

  void dispose() {}

  void updateBlockSize({Size? newSize, Offset? offset}) {
    size = newSize;
    offset = offset;
  }
}
