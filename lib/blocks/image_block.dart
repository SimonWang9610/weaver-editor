import 'dart:io';

import 'package:flutter/material.dart';

import 'package:weaver_editor/base/block_base.dart';
import 'data/image_block_data.dart';

Widget defaultImageBlockBuilder(ImageBlockData data) => ImageBlockWidget(
      key: ValueKey(data.id),
      data: data,
    );

class ImageBlock extends BlockBase<ImageBlockData> {
  ImageBlock({
    required ImageBlockData data,
    BlockBuilder? builder,
  }) : super(
          data: data,
          builder: builder ?? defaultImageBlockBuilder,
        );
}

class ImageBlockWidget extends StatelessBlock<ImageBlockData> {
  const ImageBlockWidget({
    Key? key,
    required ImageBlockData data,
  }) : super(
          key: key,
          data: data,
        );

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * data.screenScale;

    setRenderObject(context);

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
