import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';

import 'buttons/block_overlay_button.dart';

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
          BlockOverlayButton(
            index: index,
            direction: OverlayDirection.left,
            icon: const Icon(
              Icons.add_box_outlined,
              color: Colors.greenAccent,
            ),
          ),
          BlockOverlayButton(
            index: index,
            direction: OverlayDirection.right,
            icon: const Icon(
              Icons.arrow_circle_left_outlined,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
