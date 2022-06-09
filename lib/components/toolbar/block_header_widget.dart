import 'package:flutter/material.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/components/format_button.dart';

class BlockHeaderWidget extends StatelessWidget {
  final EditorToolbar toolbar;
  const BlockHeaderWidget({
    Key? key,
    required this.toolbar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerLevel = toolbar.level;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FormatButton(
          backgroundColor:
              headerLevel == HeaderLine.level1 ? Colors.grey : null,
          icon: const Text(
            'H1',
          ),
          onPressed: () {
            toolbar.updateLevel(HeaderLine.level1);
          },
        ),
        FormatButton(
          backgroundColor:
              headerLevel == HeaderLine.level2 ? Colors.grey : null,
          icon: const Text(
            'H2',
          ),
          onPressed: () {
            toolbar.updateLevel(HeaderLine.level2);
          },
        ),
        FormatButton(
          backgroundColor:
              headerLevel == HeaderLine.level3 ? Colors.grey : null,
          icon: const Text(
            'H3',
          ),
          onPressed: () {
            toolbar.updateLevel(HeaderLine.level3);
          },
        ),
      ],
    );
  }
}
