import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';

import 'buttons/block_add_widget.dart';

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
          BlockAddWidget(index: index),
          IconButton(
            onPressed: () {
              EditorBlockProvider.of(context).removeBlock(index);
            },
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: Colors.redAccent,
            ),
          )
        ],
      ),
    );
  }
}
