import 'package:flutter/material.dart';

/// [id] the block identity
/// [element] the current active [Element] of the block
/// [buildForPreview] build preview widgets
///   1) by accessing [element] if the block is [StatefulBlock]
///   2) return itself if the block is [StatelessBlock]
///
/// TODO: implement methods to serialize/deserialize [BaseBlock] to/from [Map]
abstract class BaseBlock<T extends Element> with BaseBlockConvert {
  String get id;

  String get type;
  late T element;

  Widget buildForPreview();
}

/// when the widget creates [Element], binding its [Element] to [element]
/// so that we could access its [State] in the block widget
/// ? [element] will be disposed correctly once the whole widget is removed

abstract class StatefulBlock extends StatefulWidget
    implements BaseBlock<StatefulBlockElement> {
  @override
  final String id;
  @override
  final String type;
  StatefulBlock({
    Key? key,
    required this.id,
    required this.type,
  }) : super(key: key);

  @override
  StatefulBlockElement createElement() {
    element = StatefulBlockElement(this);
    return element;
  }
}

/// each [StatefulBlock] will extend [BlockState] to create its [State]
/// and keep alive
abstract class BlockState<T extends StatefulBlock> extends State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}

abstract class StatelessBlock extends StatelessWidget
    implements BaseBlock<StatelessBlockElement> {
  @override
  final String id;
  @override
  final String type;

  StatelessBlock({
    Key? key,
    required this.id,
    required this.type,
  }) : super(key: key);

  @override
  StatelessBlockElement createElement() {
    element = StatelessBlockElement(this);
    return element;
  }

  @override
  Widget buildForPreview() => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: this,
      );
}

/// actually, no need to create below custom [Elements]
class StatefulBlockElement extends StatefulElement {
  StatefulBlockElement(StatefulBlock block) : super(block);
}

class StatelessBlockElement extends StatelessElement {
  StatelessBlockElement(StatelessBlock block) : super(block);
}

mixin BaseBlockConvert {
  Map<String, dynamic> toMap();
}
