import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'package:weaver_editor/base/block_base.dart';

import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/extensions/blocktype_ext.dart';

import 'blocks.dart';

/// the block [map] of [fromMap] must be the format:
/// {
///   'id': string,
///   'type': string,
///   'data': {
///        ...
///    }
/// }
/// it should be conformant to the [toMap] of each kind of block
///
/// *
/// 1) each block must have a [ValueKey] from its [id] to keep state during re-order/draggable

typedef BlockIdGenerator = String Function(int);

String defaultIdGenerator(int length) => nanoid(length);

/// [defaultStyle] from [EditorController] is used to create [TextBlock]
/// [BlockIdGenerator] will generate the id whose length is [_blockIdLength]
/// if [generator] is null, defaults to [defaultIdGenerator]
class BlockFactory {
  static const int defaultBlockIdLength = 5;
  final TextStyle defaultStyle;
  final BlockIdGenerator _generator;
  final int _blockIdLength;

  BlockFactory(
    this.defaultStyle, {
    int? blockIdLength,
    BlockIdGenerator? generator,
  })  : _blockIdLength = blockIdLength ?? defaultBlockIdLength,
        _generator = generator ?? defaultIdGenerator;

  /// used to restore blocks from the [blocks] map
  /// the sequence will be the [index] string of [blocks]
  /// TODO: for EditorJs, the map [blocks] format may different
  List<BlockBase> createBlockFromMetadata(Map<String, dynamic>? blocks) {
    if (blocks == null || blocks.isEmpty) {
      return [];
    } else {
      return List.generate(
        blocks.length,
        (index) {
          final block = blocks['$index'];
          return create(map: block);
        },
      );
    }
  }

  /// create a block by [BlockType] or restore from [map]
  /// therefore, one of [blockType] and [map] must not be bull
  BlockBase create({
    Map<String, dynamic>? map,
    BlockType? blockType,
    EmbedData? embedData,
  }) {
    assert(map != null || blockType != null);

    final BlockType type = (map?['type'] as String?).asType() ?? blockType!;

    final Map<String, dynamic>? data = map?['data'];
    final String id = map?['id'] ?? _generator(_blockIdLength);

    switch (type) {
      case BlockType.paragraph:
        return TextBlock.create(id, defaultStyle: defaultStyle, map: data);
      case BlockType.header:
        return HeaderBlock.create(id, defaultStyle: defaultStyle, map: data);
      case BlockType.image:
        return ImageBlock.create(id, map: data, embedData: embedData);
      case BlockType.video:
        return VideoBlock.create(id, map: data, embedData: embedData);
      default:
        throw UnimplementedError('Unsupported $type block');
    }
  }
}
