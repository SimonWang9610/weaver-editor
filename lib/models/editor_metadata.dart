import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/block_factory.dart';
import '../blocks/base_block.dart';

class EditorMetadata {
  final String title;
  final String? id;
  final Map<String, dynamic>? blockData;

  EditorMetadata({
    required this.title,
    this.blockData,
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
      blockData: data ?? blockData,
    );
  }

  List<BaseBlock> getBlocks(TextStyle style) {
    if (blockData != null && blockData!.isNotEmpty) {
      return List.generate(
        blockData!.length,
        (index) {
          final block = blockData!['$index'];
          return BlockFactory().fromMap(block, style);
        },
      );
    } else {
      return [];
    }
  }
}
