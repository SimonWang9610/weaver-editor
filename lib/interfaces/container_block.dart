import 'package:flutter/material.dart';
import 'content_block.dart';

// child should be EditableText
class ContainerBlock extends InheritedWidget {
  ContainerBlock({
    Key? key,
    required this.child,
    this.struct,
  }) : super(key: key, child: child);

  final Widget child;

  StrutStyle? struct;
  TextStyle? style;
  final List<ContentBlock> children = [];

  @override
  bool updateShouldNotify(covariant ContainerBlock oldWidget) {
    if (oldWidget.struct != struct || oldWidget.child != child) {
      return true;
    } else {
      return false;
    }
  }
}
