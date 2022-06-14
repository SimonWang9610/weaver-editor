import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

class EditorPreviewButton extends StatelessWidget {
  const EditorPreviewButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: TextButton(
        onPressed: () {
          EditorController.of(context).startPreview(context);
        },
        child: const Text(
          'Preview',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: TextButton.styleFrom(
          elevation: 5.0,
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
