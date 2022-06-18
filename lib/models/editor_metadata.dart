import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/blocks/block_factory.dart';

class EditorMetadata {
  final String title;
  final String? id;
  final Map<String, dynamic>? blocks;

  EditorMetadata({
    required this.title,
    this.blocks,
    this.id,
  });

  EditorMetadata copyWith({
    String? title,
    String? id,
    Map<String, dynamic>? data,
  }) {
    // !
    return EditorMetadata(
      title: title ?? this.title,
      id: this.id ?? id,
      blocks: data ?? blocks,
    );
  }

  List<BlockBase> getBlocks(TextStyle style) {
    if (blocks != null && blocks!.isNotEmpty) {
      return List.generate(
        blocks!.length,
        (index) {
          final block = blocks!['$index'];
          return BlockFactory().fromMap(block, style);
        },
      );
    } else {
      return [];
    }
  }
}
