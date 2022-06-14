import 'package:flutter/material.dart';
import 'preview_button.dart';

class EditorAppBar extends AppBar {
  EditorAppBar({
    Key? key,
    required Widget title,
  }) : super(
          key: key,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white70,
          title: title,
          actions: const [
            EditorPreviewButton(),
          ],
        );
}
