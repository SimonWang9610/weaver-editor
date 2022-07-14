import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/storage/editor_provider.dart';

class BlockPreview extends StatelessWidget {
  final List<BlockBase> blocks;
  final String title;
  final String id;
  const BlockPreview({
    Key? key,
    required this.blocks,
    required this.id,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Blocks'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await EditorProvider().save(id, title, blocks);

              print('save $result publication of $title');
            },
            icon: const Icon(
              Icons.save_alt_outlined,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: blocks.length,
                itemBuilder: (_, index) => blocks[index].preview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
