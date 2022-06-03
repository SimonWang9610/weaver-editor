import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'base_block.dart';

class ImageBlock extends StatelessBlock {
  final String? imageUrl;
  final PlatformFile? imageData;
  final double screenScale;
  const ImageBlock({
    Key? key,
    this.imageUrl,
    this.imageData,
    this.screenScale = 0.6,
  })  : assert(imageUrl != null || imageData != null),
        super(key: key);

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

    return SizedBox.square(
      dimension: width,
      child: image,
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
