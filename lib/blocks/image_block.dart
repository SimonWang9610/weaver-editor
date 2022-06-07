import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'base_block.dart';

/// must override [element] to declare its [Element] type explicitly
/// TODO: if [imageUrl] not link to static image files, like [.jpg, .png], should fallback to request image by http
/// TODO: how [BoxFit] works
/// TODO: enabel image caption
class ImageBlock extends StatelessBlock {
  final String? imageUrl;
  final PlatformFile? imageData;
  final String? caption;
  final double screenScale;

  ImageBlock({
    Key? key,
    required String id,
    this.imageUrl,
    this.imageData,
    this.caption,
    this.screenScale = 0.6,
  })  : assert(imageUrl != null || imageData != null),
        super(key: key, id: id);

  @override
  late StatelessBlockElement element;

  @override
  Map<String, dynamic> toMap() => {
        'type': 'image',
        'data': {
          'file': imageUrl ?? imageData?.path,
        },
        'caption': caption,
        'withBorder': false,
        'withBackground': false,
        'stretched': true,
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
            File(imageData!.path!),
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

  Widget get networkImage => CachedNetworkImage(
        imageUrl: imageUrl!,
        progressIndicatorBuilder: (innerContext, url, progress) => Center(
          child: CircularProgressIndicator(
            value: progress.progress,
          ),
        ),
        errorWidget: (_, __, error) => const Center(
          child: Icon(
            Icons.error_outline,
          ),
        ),
      );

  Widget get loadingWidget => const Center(
        child: CircularProgressIndicator(),
      );

  Widget get errorWidget => const Center(
        child: Icon(Icons.error),
      );
}
