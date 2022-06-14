import 'package:flutter/material.dart';
import 'package:weaver_editor/editor_toolbar.dart';
import 'package:weaver_editor/editor.dart';
import 'package:weaver_editor/storage/editor_provider.dart';

class PublicationThumbnail extends StatelessWidget {
  final Publication publication;
  const PublicationThumbnail({
    Key? key,
    required this.publication,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 3,
        color: Colors.white54,
        child: Column(
          children: [
            Text(publication.id),
            Text(publication.title),
            Text('last update: ${toLocalTime(publication.lastUpdate)}'),
          ],
        ),
      ),
      onTap: () {
        final style =
            Theme.of(context).textTheme.titleMedium ?? const TextStyle();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeaverEditor(
              initId: publication.id,
              title: publication.title,
              blockData: publication.blockData,
              toolbar: EditorToolbar(style),
              defaultStyle: style,
            ),
          ),
        );
      },
    );
  }

  String toLocalTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    return date.toString();
  }
}
