import 'package:flutter/widgets.dart';

abstract class BlockData {
  final String id;
  final String type;
  Size? size;
  Offset? bottom;

  BlockData({required this.id, required this.type});

  Widget createPreview();
  Map<String, dynamic> toMap();

  void updateBlockSize({Size? newSize, Offset? offset}) {
    size = newSize;
    bottom = offset;
  }
}
