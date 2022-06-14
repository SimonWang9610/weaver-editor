import 'package:flutter/material.dart';

extension TextStyleFromHtmlTag on TextStyle {
  TextStyle mergeTags(List<String> tags) {
    TextStyle style = this;

    for (final tag in tags) {
      switch (tag) {
        case '<b>':
          style = style.copyWith(
            fontWeight: FontWeight.w900,
          );
          break;
        case '<i>':
          style = style.copyWith(
            fontStyle: FontStyle.italic,
          );
          break;
        case '<u>':
          style = style.copyWith(
            decoration: TextDecoration.underline,
          );
          break;
      }
    }
    return style;
  }
}
