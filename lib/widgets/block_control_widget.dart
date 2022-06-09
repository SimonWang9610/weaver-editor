import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';

import '../components/overlays/block_option_overlay.dart';

class BlockControlWidget extends StatelessWidget {
  final int index;
  const BlockControlWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlockOptionOverlay(
            index: index,
            direction: OverlayDirection.left,
            icon: const Icon(
              Icons.add_box_outlined,
              color: Colors.greenAccent,
            ),
          ),
          BlockOptionOverlay(
            index: index,
            direction: OverlayDirection.right,
            icon: const Icon(
              Icons.more_horiz_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
