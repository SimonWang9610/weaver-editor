import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';
import 'package:weaver_editor/models/editor_metadata.dart';
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
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Text(publication.title),
              const SizedBox(
                height: 10,
              ),
              Text('Last update: ${toLocalTime(publication.lastUpdate)}'),
            ],
          ),
        ),
      ),
      onTap: () {
        final style =
            Theme.of(context).textTheme.titleMedium ?? const TextStyle();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeaverEditor(
              metadata: EditorMetadata(
                id: publication.id,
                title: publication.title,
                blocks: publication.blockData,
              ),
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
