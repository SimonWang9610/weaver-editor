import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';

import 'package:weaver_editor/blocks/content_block.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'block_editing_controller.dart';
import '../blocks/leaf_text_block.dart';

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
    widget.toolbar.dispose();
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
              Expanded(
                child: ListView(
                  children: _interleaveBlock(),
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

  List<Widget> _interleaveBlock() {
    final List<Widget> widgets = [const BlockCreator(index: 0)];

    if (_blocks.isEmpty) return widgets;

    for (int i = 0; i < _blocks.length; i++) {
      widgets.addAll([_blocks[i], BlockCreator(index: i + 1)]);
    }

    return widgets;
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
    print('block creator: $index');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
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

  static EditorBlockProvider of(BuildContext context) {
    final editor = context.findAncestorStateOfType<_WeaverEditorState>();

    if (editor == null) {
      throw ErrorDescription('No Editor Found');
    }

    return editor.provider;
  }

  EditorToolbar attachContentBlock(BlockEditingController controller) {
    return toolbar.attach(controller);
  }

  void detachContentBlock() {
    toolbar.detach();
  }

  void insertContentBlock(ContentBlockType type, [int? pos]) {
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

    if (pos != null && pos >= 0) {
      blocks.insert(pos, block);
    } else {
      blocks.add(block);
    }

    notifyListeners();
  }

  void reorder(int src, int dst) {
    final block = blocks.removeAt(src);
    blocks.insert(dst, block);
    notifyListeners();
  }
}

enum ContentBlockType {
  paragraph,
  list,
  image,
  video,
}
