import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';
import '../../editor.dart' show EditorController;

class BlockOverlayButton extends StatelessWidget {
  final int index;
  final Widget icon;
  final OverlayDirection direction;
  const BlockOverlayButton({
    Key? key,
    required this.index,
    required this.direction,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LayerLink link = LayerLink();

    return CompositedTransformTarget(
      link: link,
      child: IconButton(
        onPressed: () {
          final manager = EditorController.of(context).manager;

          final overlay = manager.createOptionOverlay(
            context,
            link: link,
            index: index,
            direction: direction,
          );

          Overlay.of(context)?.insert(overlay);
        },
        icon: icon,
      ),
    );
  }
}
