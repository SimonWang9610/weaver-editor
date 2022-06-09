import 'package:flutter/material.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import '../format_button.dart';
import 'add_link_button.dart';

class BlockFormatWidget extends StatelessWidget {
  final EditorToolbar toolbar;
  final TextStyle style;
  const BlockFormatWidget({
    Key? key,
    required this.style,
    required this.toolbar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FormatButton(
          backgroundColor:
              style.fontWeight == FontWeight.w900 ? Colors.grey : null,
          onPressed: toolbar.boldText,
          icon: const Icon(
            Icons.format_bold_outlined,
            color: Colors.black,
          ),
        ),
        FormatButton(
          backgroundColor:
              style.fontStyle == FontStyle.italic ? Colors.grey : null,
          onPressed: toolbar.italicText,
          icon: const Icon(
            Icons.format_italic_outlined,
            color: Colors.black,
          ),
        ),
        FormatButton(
          backgroundColor:
              style.decoration == TextDecoration.underline ? Colors.grey : null,
          onPressed: toolbar.underlineText,
          icon: const Icon(
            Icons.format_underline_outlined,
            color: Colors.black,
          ),
        ),
        HyperLinkButton(
          onPressed: () => toolbar.addLinkInFocusedBlock(context),
        ),
      ],
    );
  }
}
