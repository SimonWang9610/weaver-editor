import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/editor_toolbar.dart';

mixin EditorToolbarDelegate<T extends StatefulBlock> on State<T> {
  late TextStyle defaultStyle;
  EditorToolbar? attachedToolbar;
  TextAlign? align;

  void handleFocusChange();

  void setAlign(TextAlign newAlign) {
    align = newAlign;
  }
}
