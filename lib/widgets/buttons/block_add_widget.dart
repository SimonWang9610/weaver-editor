import 'package:flutter/material.dart';
import '../../editor.dart' show EditorBlockProvider;

class BlockAddWidget extends StatelessWidget {
  final int index;
  const BlockAddWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LayerLink link = LayerLink();

    return CompositedTransformTarget(
      link: link,
      child: IconButton(
        onPressed: () {
          final overlayController =
              EditorBlockProvider.of(context).overlayController;

          final overlay = overlayController.createOptionOverlay(
            context,
            link: link,
            index: index,
          );

          Overlay.of(context)?.insert(overlay);
        },
        icon: const Icon(
          Icons.add_box_outlined,
          color: Colors.greenAccent,
        ),
      ),
    );
  }
}
