import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_data.dart';

typedef BlockBuilder<T extends BlockData> = Widget Function(T data);

abstract class BlockBase<T extends BlockData> {
  final T data;
  final BlockBuilder<T> builder;

  BlockBase({
    required this.builder,
    required this.data,
  });

  String get id => data.id;
  Offset? get offset => data.offset;
  Size? get size => data.size;
  Map<String, dynamic> get json => data.toMap();
  Widget get preview => data.createPreview();

  Widget build() {
    // print('build block[$id]');
    return builder(data);
  }

  void dispose() {
    data.dispose();
  }
}

abstract class StatelessBlock<T extends BlockData> extends StatelessWidget
    with BlockRenderObjectObserver {
  @override
  final T data;
  const StatelessBlock({
    Key? key,
    required this.data,
  }) : super(key: key);
}

abstract class StatefulBlock<T extends BlockData> extends StatefulWidget {
  final T data;
  const StatefulBlock({
    Key? key,
    required this.data,
  }) : super(key: key);
}

abstract class BlockState<S extends BlockData, T extends StatefulBlock<S>>
    extends State<T>
    with AutomaticKeepAliveClientMixin, BlockRenderObjectObserver {
  @override
  bool get wantKeepAlive => true;

  @override
  S get data => widget.data;
}

mixin BlockRenderObjectObserver<T extends BlockData> {
  T get data;

  void setRenderObject(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      final bottomLeft = box?.paintBounds.bottomLeft;
      final offset = box?.localToGlobal(bottomLeft ?? Offset.zero);
      // print('set render object offset: $offset');
      data.updateBlockSize(newSize: box?.size, offset: offset);
    });
  }
}
