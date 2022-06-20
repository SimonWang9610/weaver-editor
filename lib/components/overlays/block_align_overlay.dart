import 'package:flutter/material.dart';
import '../../editor.dart';

class BlockAlignOverlay extends StatelessWidget {
  const BlockAlignOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LayerLink link = LayerLink();

    return CompositedTransformTarget(
      link: link,
      child: IconButton(
        onPressed: () {
          final manager = WeaverEditorProvider.of(context).manager;

          final overlay = manager.createAlignOverlay(context, link: link);

          Overlay.of(context)?.insert(overlay);
        },
        icon: const Icon(
          Icons.format_indent_increase_outlined,
        ),
      ),
    );
  }
}
