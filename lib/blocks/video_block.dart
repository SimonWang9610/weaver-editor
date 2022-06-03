import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'base_block.dart';

class VideoBlock extends StatefulBlock {
  final String? videoUrl;
  final PlatformFile? videoStream;
  const VideoBlock({
    Key? key,
    this.videoUrl,
    this.videoStream,
  })  : assert(videoUrl != null || videoStream != null),
        super(key: key);

  @override
  VideoBlockState createState() => VideoBlockState();
}

class VideoBlockState extends BlockState<VideoBlock> {
  late VideoPlayerController _controller;

  bool _displayControl = true;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!);
    } else {
      final file = File(widget.videoStream!.path!);
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
