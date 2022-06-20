import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/data/data.dart';

import 'package:weaver_editor/core/delegates/text_operation_delegate.dart';
import 'package:weaver_editor/models/types.dart';

mixin ToolbarChangeDelegate<T extends TextBlockData> on TextEditingController {
  TextOperationDelegate<T> get delegate;

  TextStyle get blockDefaultStyle => delegate.defaultStyle;

  void mayApplyStyle() {
    if (!selection.isCollapsed) {
      value = value.copyWith();
    }
  }

  void applyHeaderLevel(HeaderLine newLevel) {
    assert(delegate.data is HeaderBlockData);

    final isAdopted = (delegate.data as HeaderBlockData).adoptLevel(newLevel);

    if (isAdopted) {
      notifyListeners();
    }
  }

  void applyAlign(TextAlign value) {
    final isAdopted = delegate.data.adoptAlign(value);

    if (isAdopted) {
      notifyListeners();
    }
  }
}
