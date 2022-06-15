import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';

extension HeaderLineFromFontSize on num {
  HeaderLine levelHeaderLine() {
    switch (this) {
      case 1:
        return HeaderLine.level1;
      case 2:
        return HeaderLine.level2;
      case 3:
        return HeaderLine.level3;
      default:
        throw ErrorDescription('Cannot convert $this to supported HeaderLine');
    }
  }

  HeaderLine sizeToHeaderLine() {
    switch (this) {
      case 60:
        return HeaderLine.level1;
      case 48:
        return HeaderLine.level2;
      case 36:
        return HeaderLine.level3;
      default:
        throw ErrorDescription('Cannot convert $this to supported HeaderLine');
    }
  }
}

extension TextAlignFromName on String {
  TextAlign toTextAlign() {
    switch (this) {
      case 'start':
        return TextAlign.start;
      case 'center':
        return TextAlign.center;
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      default:
        throw ErrorDescription('Unsupported Text Align: $this');
    }
  }
}
