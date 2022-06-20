import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/video_block.dart';
import '../../base/block_data.dart';

/// TODO: [createPreview] should display the video thumbnail instead of [VideoBlockWidget]
class VideoBlockData extends BlockData {
  final String? videoUrl;
  final String? videoPath;
  final String? caption;

  VideoBlockData({
    required String id,
    String type = 'video',
    this.caption,
    this.videoPath,
    this.videoUrl,
  }) : super(id: id, type: type);

  @override
  Widget createPreview() => VideoBlockWidget(
        data: this,
      );

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
}
