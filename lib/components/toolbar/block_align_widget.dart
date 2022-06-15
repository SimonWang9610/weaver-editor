import 'package:flutter/material.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import 'package:weaver_editor/components/format_button.dart';

class BlockAlignWidget extends StatelessWidget {
  final EditorToolbar toolbar;
  final TextAlign align;
  final VoidCallback? overlayRemoveCallback;
  const BlockAlignWidget({
    Key? key,
    required this.align,
    required this.toolbar,
    this.overlayRemoveCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FormatButton(
          backgroundColor: align == TextAlign.start
              ? const Color.fromARGB(255, 48, 222, 202)
              : null,
          icon: const Icon(
            Icons.format_align_justify_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            toolbar.updateAlign(TextAlign.start);
            overlayRemoveCallback?.call();
          },
        ),
        FormatButton(
          backgroundColor: align == TextAlign.left
              ? const Color.fromARGB(255, 48, 222, 202)
              : null,
          icon: const Icon(
            Icons.format_align_left_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            toolbar.updateAlign(TextAlign.left);
            overlayRemoveCallback?.call();
          },
        ),
        FormatButton(
          backgroundColor: align == TextAlign.center
              ? const Color.fromARGB(255, 48, 222, 202)
              : null,
          icon: const Icon(
            Icons.format_align_center_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            toolbar.updateAlign(TextAlign.center);
            overlayRemoveCallback?.call();
          },
        ),
        FormatButton(
          backgroundColor: align == TextAlign.right
              ? const Color.fromARGB(255, 48, 222, 202)
              : null,
          icon: const Icon(
            Icons.format_align_right_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            toolbar.updateAlign(TextAlign.right);
            overlayRemoveCallback?.call();
          },
        ),
      ],
    );
  }
}
