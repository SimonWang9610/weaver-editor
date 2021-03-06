import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/components/overlays/block_option_overlay.dart';

class BlockControlWidget extends StatelessWidget {
  final int index;
  const BlockControlWidget({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlockOptionOverlay(
          index: index,
          direction: OverlayDirection.left,
          icon: const Icon(
            Icons.post_add_rounded,
            color: Colors.green,
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
    );
  }
}
