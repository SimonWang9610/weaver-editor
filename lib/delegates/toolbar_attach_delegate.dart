import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/editor_toolbar.dart';

mixin EditorToolbarDelegate<T extends StatefulBlock> on BlockState<T> {
  late final TextStyle defaultStyle;
  EditorToolbar? attachedToolbar;
  TextAlign? align;

  void handleFocusChange();

  void changeBlockAlign(TextAlign? newAlign) {
    if (newAlign != null) {
      align = newAlign;
      setState(() {});
    }
  }
}
