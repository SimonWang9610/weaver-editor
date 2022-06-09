import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/leaf_text_block.dart';

import '../blocks/head_block.dart';
import '../models/types.dart';

mixin ToolbarChangeDelegate on TextEditingController {
  LeafTextBlockState get block;

  bool get isHeaderBlock => block is HeaderBlockState;

  TextStyle get blockDefaultStyle => block.defaultStyle;

  void unfocus() {
    if (block.focus.hasFocus) {
      block.focus.unfocus();
    }
  }

  void mayApplyStyle() {
    if (!selection.isCollapsed) {
      value = value.copyWith();
    }
  }

  void applyHeaderLevel(HeaderLine newLevel) {
    assert(isHeaderBlock);

    (block as HeaderBlockState).changeHeaderLevel(newLevel);
  }

  void applyAlign(TextAlign value) {
    block.changeBlockAlign(value);
  }
}
