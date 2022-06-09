import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

class EditorPreviewButton extends StatelessWidget {
  const EditorPreviewButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        EditorController.of(context).startPreview(context);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Text('Preview'),
      ),
      style: TextButton.styleFrom(
        elevation: 5.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
