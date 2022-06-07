import 'package:weaver_editor/models/block_range.dart';

import 'package:flutter/material.dart';
import '../models/format_node.dart';

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
