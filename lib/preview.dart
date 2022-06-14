import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';

class BlockPreview extends StatelessWidget {
  final List<BaseBlock> blocks;
  const BlockPreview({
    Key? key,
    required this.blocks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Blocks'),
        actions: [
          IconButton(
            onPressed: () {
              final List<Map<String, dynamic>> data = [];

              for (final block in blocks) {
                data.add(block.toMap());
              }

              for (final ele in data) {
                print(ele);
              }
            },
            icon: const Icon(
              Icons.print_outlined,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: blocks.length,
                itemBuilder: (_, index) => blocks[index].buildForPreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
