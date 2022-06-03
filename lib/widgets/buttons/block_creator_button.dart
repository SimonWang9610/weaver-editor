import 'package:flutter/material.dart';
import '../../components/outlined_text_button.dart';
import '../../models/types.dart';
import '../../editor.dart' show EditorBlockProvider;
import '../block_embed_widget.dart';

class BlockCreatorButton extends StatelessWidget {
  final BuildContext? globalContext;
  final int index;
  final BlockType type;
  final Widget? child;
  final VoidCallback? beforePressed;
  const BlockCreatorButton({
    Key? key,
    required this.index,
    required this.type,
    this.beforePressed,
    this.child,
    this.globalContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedTextButton(
      child: child ?? Text(type.name.capitalized),
      onPressed: () async {
        beforePressed?.call();

        switch (type) {
          case BlockType.paragraph:
            final blockProvider =
                EditorBlockProvider.of(globalContext ?? context);

            blockProvider.insertBlock(BlockType.paragraph, pos: index);
            break;
          case BlockType.image:
          case BlockType.video:
            _showFilePicker(context);
            break;
          default:
            throw ErrorDescription('Unsupported $type');
        }
      },
    );
  }

  void _showFilePicker(BuildContext context) async {
    final data = await showDialog<EmbedData>(
      context: context,
      builder: (_) => BlockEmbedWidget(
        index: index,
        type: type,
      ),
    );

    if (data != null && data.isValid) {
      final blockProvider = EditorBlockProvider.of(globalContext ?? context);
      blockProvider.insertBlock(type, data: data, pos: index);
    }
  }
}
