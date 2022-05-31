import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/content_block.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';

mixin EditorToolbarDelegate<T extends ContentBlock> on ContentBlockState<T> {
  EditorToolbar? attachedToolbar;
  TextAlign? align;

  void handleFocusChange();

  void setTextAlign() {
    align = attachedToolbar?.align;
    setState(() {});
  }
}