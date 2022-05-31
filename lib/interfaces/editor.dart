import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'package:weaver_editor/interfaces/content_block.dart';
import 'package:weaver_editor/interfaces/editor_toolbar.dart';
import 'block_editing_controller.dart';
import 'leaf_text_block.dart';

class WeaverEditor extends StatefulWidget {
  final EditorToolbar toolbar;
  const WeaverEditor({
    Key? key,
    required this.toolbar,
  }) : super(key: key);

  @override
  State<WeaverEditor> createState() => _WeaverEditorState();
}

class _WeaverEditorState extends State<WeaverEditor> {
  late final EditorBlockProvider provider;

  List<ContentBlock> _blocks = [];

  @override
  void initState() {
    super.initState();
    provider = EditorBlockProvider(widget.toolbar);
    _blocks = provider.blocks;

    provider.addListener(_handleBlockChange);
  }

  void _handleBlockChange() {
    _blocks = provider.blocks;

    setState(() {});
  }

  @override
  void dispose() {
    provider.removeListener(_handleBlockChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weaver Editor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          child: Column(
            children: [
              const BlockCreator(index: -1),
              Expanded(
                child: ListView.separated(
                  itemCount: _blocks.length,
                  itemBuilder: (_, index) => _blocks[index],
                  separatorBuilder: (_, index) => BlockCreator(
                    index: index,
                  ),
                ),
              ),
              EditorToolbarWidget(
                toolbar: provider.toolbar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlockCreator extends StatelessWidget {
  final int index;
  const BlockCreator({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: IconButton(
          onPressed: () {
            final blockProvider = EditorBlockProvider.of(context);

            blockProvider.insertContentBlock(ContentBlockType.paragraph, index);
          },
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class EditorBlockProvider with ChangeNotifier {
  final List<ContentBlock> blocks;

  final EditorToolbar toolbar;

  EditorBlockProvider(this.toolbar, {List<ContentBlock>? initBlocks})
      : blocks = initBlocks ?? [];

  EditorToolbar attachContentBlock(BlockEditingController controller) {
    return toolbar.attach(controller);
  }

  void detachContentBlock() {
    toolbar.detach();
  }

  void insertContentBlock(ContentBlockType type, [int? pos]) {
    print('creating content block');
    late final block;
    final String id = nanoid(5);

    switch (type) {
      case ContentBlockType.paragraph:
        block = LeafTextBlock(
          key: ValueKey(id),
          style: toolbar.style,
          type: type.name,
        );
        break;
      default:
        throw UnimplementedError('Unsupported $type block');
    }

    // TODO: should auto unfocus before inserting a new block

    if (pos != null && pos >= 0) {
      block.insert(pos, block);
    } else {
      blocks.add(block);
    }
    print('blocks: ${blocks.length}');

    notifyListeners();
  }

  void reorder(int src, int dst) {
    final block = blocks.removeAt(src);
    blocks.insert(dst, block);
    notifyListeners();
  }

  static EditorBlockProvider of(BuildContext context) {
    final editor = context.findAncestorStateOfType<_WeaverEditorState>();

    if (editor == null) {
      throw ErrorDescription('No Editor Found');
    }

    return editor.provider;
  }
}

enum ContentBlockType {
  paragraph,
  list,
  image,
  video,
}
