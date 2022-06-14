import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'base_block.dart';

/// [buildForPreview] return [VideoBlock] directly
/// TODO: to set custom aspect ratio of the [VideoPlayer]
/// TODO: shoudl fallback to request vidoe resources if [videoUrl] not link to static video files
/// TODO: support Youtube video
/// TODO: add vidoe width & height
/// TODO: enable video caption
class VideoBlock extends StatefulBlock {
  final String? videoUrl;
  final String? videoPath;
  final String? caption;
  // final String id;
  VideoBlock({
    Key? key,
    this.videoUrl,
    this.videoPath,
    this.caption,
    required String id,
    String type = 'video',
  })  : assert(videoUrl != null || videoPath != null),
        super(
          key: key,
          id: id,
          type: type,
        );

  @override
  VideoBlockState createState() => VideoBlockState();

  @override
  late StatefulBlockElement element;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': 'embed',
        'time': DateTime.now().millisecondsSinceEpoch,
        'data': {
          'service': 'local service',
          'source': videoUrl ?? videoPath,
          'embed': videoUrl ?? videoPath,
          'width': 640,
          'height': 428,
          'caption': 'TODO'
        }
      };

  @override
  Widget buildForPreview() => this;
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
      final file = File(widget.videoPath!);
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
