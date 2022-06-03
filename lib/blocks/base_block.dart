import 'package:flutter/material.dart';

abstract class BaseBlock<T extends Element> {
  String get id;

  late T element;

  Widget buildForPreview();
}

abstract class StatefulBlock extends StatefulWidget
    implements BaseBlock<StatefulBlockElement> {
  @override
  final String id;
  StatefulBlock({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  StatefulBlockElement createElement() {
    element = StatefulBlockElement(this);
    return element;
  }
}

abstract class BlockState<T extends StatefulBlock> extends State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}

abstract class StatelessBlock extends StatelessWidget
    implements BaseBlock<StatelessBlockElement> {
  @override
  final String id;
  StatelessBlock({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  StatelessBlockElement createElement() {
    element = StatelessBlockElement(this);
    return element;
  }

  @override
  Widget buildForPreview() => this;
}

class StatefulBlockElement extends StatefulElement {
  StatefulBlockElement(StatefulBlock block) : super(block);
}

class StatelessBlockElement extends StatelessElement {
  StatelessBlockElement(StatelessBlock block) : super(block);
}
