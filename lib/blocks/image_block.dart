import 'dart:io';

import 'package:flutter/material.dart';
import 'base_block.dart';
import '../models/data/block_data.dart';

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
    return ImageBlock(
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

/// must override [element] to declare its [Element] type explicitly
/// TODO: if [imageUrl] not link to static image files, like [.jpg, .png], should fallback to request image by http
/// TODO: how [BoxFit] works
/// TODO: enabel image caption
class ImageBlock extends StatelessBlock<ImageBlockData> {
  const ImageBlock({
    Key? key,
    required ImageBlockData data,
  }) : super(key: key, data: data);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * data.screenScale;

    setBlockSize(context);

    final Image image = data.imageUrl != null
        ? Image.network(
            data.imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (_, __, ___) => loadingWidget,
            errorBuilder: (_, __, ___) => errorWidget,
          )
        : Image.file(
            File(data.imagePath!),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => errorWidget,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox.square(
          dimension: width,
          child: image,
        ),
        if (data.caption != null) Text(data.caption!),
      ],
    );
  }

  Widget get loadingWidget => const Center(
        child: CircularProgressIndicator(),
      );

  Widget get errorWidget => const Center(
        child: Icon(Icons.error),
      );
}
