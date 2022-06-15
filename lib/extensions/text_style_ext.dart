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

extension HtmlFromTextStyle on TextStyle {
  String toHtml(String text) {
    if (fontWeight == FontWeight.w900) {
      text = '<b>$text</b>';
    }

    if (fontStyle == FontStyle.italic) {
      text = '<i>$text</i>';
    }

    if (decoration == TextDecoration.underline) {
      text = '<u>$text</u>';
    }
    return text;
  }
}
