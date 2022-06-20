import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';
import 'package:weaver_editor/components/outlined_text_button.dart';
import 'package:weaver_editor/models/types.dart';
import 'block_embed_widget.dart';

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
          case BlockType.header:
            final editorController =
                WeaverEditorProvider.of(globalContext ?? context);

            editorController.insertBlock(type, pos: index);
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
      final editorController =
          WeaverEditorProvider.of(globalContext ?? context);
      editorController.insertBlock(type, data: data, pos: index);
    }
  }
}
