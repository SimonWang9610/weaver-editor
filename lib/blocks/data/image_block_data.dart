import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/image_block.dart';
import 'package:weaver_editor/base/block_data.dart';

class ImageBlockData extends BlockData {
  final String? imageUrl;
  final String? imagePath;
  final String? caption;
  final double screenScale;

  ImageBlockData({
    required String id,
    String type = 'image',
    this.imagePath,
    this.imageUrl,
    this.caption,
    this.screenScale = 0.6,
  })  : assert(imageUrl != null || imagePath != null),
        super(id: id, type: type);

  @override
  Widget createPreview() {
    return ImageBlockWidget(
      data: this,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'time': DateTime.now().millisecondsSinceEpoch,
        'data': {
          'file': imageUrl ?? imagePath,
          'caption': caption,
          'withBorder': false,
          'withBackground': false,
          'stretched': true,
        },
      };
}
