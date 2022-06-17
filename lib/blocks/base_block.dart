import 'package:flutter/material.dart';

import 'package:weaver_editor/models/data/block_data.dart';

/// [id] the block identity
/// [element] the current active [Element] of the block
/// [buildForPreview] build preview widgets
///   1) by accessing [element] if the block is [StatefulBlock]
///   2) return itself if the block is [StatelessBlock]
///
/// TODO: implement methods to serialize/deserialize [BaseBlock] to/from [Map]
abstract class BaseBlock<T extends BlockData> {
  T get data;

  Widget get preview;
  String get id;
  Offset? get offset;
  Map<String, dynamic> get map;
}

/// when the widget creates [Element], binding its [Element] to [element]
/// so that we could access its [State] in the block widget
/// ? [element] will be disposed correctly once the whole widget is removed

abstract class StatefulBlock<T extends BlockData> extends StatefulWidget
    implements BaseBlock<T> {
  @override
  final T data;
  const StatefulBlock({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget get preview => data.createPreview();

  @override
  Map<String, dynamic> get map => data.toMap();

  @override
  String get id => data.id;

  @override
  Offset? get offset => data.bottom;
}

/// each [StatefulBlock] will extend [BlockState] to create its [State]
/// and keep alive
abstract class BlockState<T extends StatefulBlock> extends State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  BlockData get data => widget.data;

  /// [BuildContext.findRenderObject] only returns a valid result after completing build phase
  void setBlockSize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      final bottomLeft = box?.paintBounds.bottomLeft;
      final offset = box?.localToGlobal(bottomLeft ?? Offset.zero);
      data.updateBlockSize(newSize: box?.size, offset: offset);
    });
  }
}

abstract class StatelessBlock<T extends BlockData> extends StatelessWidget
    implements BaseBlock<T> {
  @override
  final T data;

  const StatelessBlock({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget get preview => data.createPreview();

  @override
  Map<String, dynamic> get map => data.toMap();

  @override
  String get id => data.id;

  @override
  Offset? get offset => data.bottom;

  void setBlockSize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      final bottomLeft = box?.paintBounds.bottomLeft;
      final offset = box?.localToGlobal(bottomLeft ?? Offset.zero);
      data.updateBlockSize(newSize: box?.size, offset: offset);
    });
  }
}
