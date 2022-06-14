import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'base_block.dart';

/// must override [element] to declare its [Element] type explicitly
/// TODO: if [imageUrl] not link to static image files, like [.jpg, .png], should fallback to request image by http
/// TODO: how [BoxFit] works
/// TODO: enabel image caption
class ImageBlock extends StatelessBlock {
  final String? imageUrl;
  final String? imagePath;
  final String? caption;
  final double screenScale;

  ImageBlock({
    Key? key,
    required String id,
    String type = 'image',
    this.imageUrl,
    this.imagePath,
    this.caption,
    this.screenScale = 0.6,
  })  : assert(imageUrl != null || imagePath != null),
        super(
          key: key,
          id: id,
          type: type,
        );

  @override
  late StatelessBlockElement element;

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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * screenScale;

    final Image image = imageUrl != null
        ? Image.network(
            imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (_, __, ___) => loadingWidget,
            errorBuilder: (_, __, ___) => errorWidget,
          )
        : Image.file(
            File(imagePath!),
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
        if (caption != null) Text(caption!),
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
