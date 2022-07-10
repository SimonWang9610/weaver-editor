import 'package:flutter/material.dart';
import 'package:weaver_editor/utils/helper.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/models/types.dart';
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

  static VideoBlock create(
    String id, {
    Map<String, dynamic>? map,
    EmbedData? embedData,
  }) {
    assert(map != null || embedData != null);

    String? url;
    String? path;
    String? caption;

    if (map == null) {
      url = embedData?.url;
      path = embedData?.file?.path;
      caption = embedData?.caption;
    } else {
      if ((map['embed'] as String).startsWith('http')) {
        url = StringUtil.extractYoutubeId(map['embed']) ??
            StringUtil.extractYoutubeId(map['source']);
      } else {
        path = map['embed'];
      }
      caption = map['caption'];
    }

    return VideoBlock(
      data: VideoBlockData(
        id: id,
        videoUrl: url,
        videoPath: path,
        caption: caption,
      ),
    );
  }
}

class VideoBlockWidget extends StatefulBlock<VideoBlockData> {
  final double aspectRatio;
  const VideoBlockWidget({
    Key? key,
    required VideoBlockData data,
    this.aspectRatio = 16 / 9,
  }) : super(
          key: key,
          data: data,
        );

  @override
  VideoBlockState createState() => VideoBlockState();
}

class VideoBlockState extends BlockState<VideoBlockData, VideoBlockWidget> {
  late YoutubePlayerController _controller;
  late PlayerState _playState;
  late YoutubeMetaData _metaData;
  bool _readyToPlay = false;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.data.videoUrl!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(_handleVideoStateChange);

    _playState = PlayerState.unknown;
    _metaData = const YoutubeMetaData();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoStateChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleVideoStateChange() {
    if (_readyToPlay && mounted) {
      setState(() {
        _metaData = _controller.value.metaData;
        _playState = _controller.value.playerState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return YoutubePlayer(
      key: ValueKey(widget.data.id),
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      topActions: <Widget>[
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            _controller.metadata.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        )
      ],
      bottomActions: [
        CurrentPosition(),
        const SizedBox(width: 10.0),
        ProgressBar(isExpanded: true),
        const SizedBox(width: 10.0),
        RemainingDuration(),
        FullScreenButton(),
      ],
      onReady: () {
        _readyToPlay = true;
      },
    );
  }
}
