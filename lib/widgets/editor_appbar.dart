import 'package:flutter/material.dart';
import 'preview_button.dart';

class EditorAppBar extends AppBar {
  EditorAppBar({
    Key? key,
    required String title,
    Widget? leading,
  }) : super(
          key: key,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white70,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          leading: leading,
          actions: const [
            EditorPreviewButton(),
          ],
        );
}
