import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:weaver_editor/base/block_base.dart';
import 'data/video_block_data.dart';

Widget defaultVideoBlockBuilder(VideoBlockData data) => VideoBlockWidget(
      key: ValueKey(data.id),
      data: data,
    );

class VideoBlock extends BlockBase<VideoBlockData> {
  VideoBlock({
    required VideoBlockData data,
    BlockBuilder? builder,
  }) : super(
          data: data,
          builder: builder ?? defaultVideoBlockBuilder,
        );
}

class VideoBlockWidget extends StatefulBlock<VideoBlockData> {
  const VideoBlockWidget({
    Key? key,
    required VideoBlockData data,
  }) : super(
          key: key,
          data: data,
        );

  @override
  VideoBlockState createState() => VideoBlockState();
}

class VideoBlockState extends BlockState<VideoBlockData, VideoBlockWidget> {
  late VideoPlayerController _controller;

  bool _displayControl = true;

  @override
  VideoBlockData get data => widget.data;

  @override
  void initState() {
    super.initState();

    if (data.videoUrl != null) {
      _controller = VideoPlayerController.network(data.videoUrl!);
    } else {
      final file = File(data.videoPath!);
      _controller = VideoPlayerController.file(file);
    }

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    setRenderObject(context);

    final width = MediaQuery.of(context).size.width * 0.6;

    return GestureDetector(
      child: SizedBox(
        width: width,
        height: width / _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                bufferedColor: Colors.white,
                playedColor: Colors.grey,
              ),
            ),
            if (_displayControl)
              Align(
                alignment: Alignment.center,
                child: VideoPlayControlWidget(
                  controller: _controller,
                  afterPressed: _removeControl,
                ),
              )
          ],
        ),
      ),
      onTap: () {
        _displayControl = true;
        setState(() {});
      },
    );
  }

  void _removeControl() {
    _displayControl = false;
    setState(() {});
  }
}

class VideoPlayControlWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback? afterPressed;
  const VideoPlayControlWidget({
    Key? key,
    required this.controller,
    this.afterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }

        afterPressed?.call();
      },
      icon: icon,
    );
  }

  Widget get icon {
    if (controller.value.isPlaying) {
      return const Icon(
        Icons.pause_circle_filled_outlined,
        color: Colors.white,
        size: 48,
      );
    } else {
      return const Icon(
        Icons.play_arrow_outlined,
        color: Colors.white,
        size: 48,
      );
    }
  }
}
