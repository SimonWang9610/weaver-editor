import 'package:flutter/material.dart';
import 'package:weaver_editor/components/outlined_text_button.dart';
import 'package:weaver_editor/storage/editor_provider.dart';

import '../components/outlined_text_button.dart';
import 'publication_thumbnail.dart';

class LocalPublicationList extends StatefulWidget {
  const LocalPublicationList({Key? key}) : super(key: key);

  @override
  State<LocalPublicationList> createState() => _LocalPublicationListState();
}

class _LocalPublicationListState extends State<LocalPublicationList> {
  int offset = 0;

  final List<Publication> publications = [];

  @override
  void initState() {
    super.initState();
    _loadLocalPublications();
  }

  Future<void> _loadLocalPublications([bool shouldRefresh = false]) async {
    if (shouldRefresh) {
      offset = 0;
      publications.clear();
    }

    final result = await EditorProvider().getAllPublications(offset);

    if (result.isNotEmpty) {
      publications.addAll(result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          'Or load local publications',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: publications.isNotEmpty
              ? ListView.builder(
                  itemCount: publications.length,
                  itemBuilder: (_, index) {
                    return PublicationThumbnail(
                      publication: publications[index],
                    );
                  },
                )
              : const Text('No local Publications'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedTextButton(
              enableOutlineBorder: true,
              child: const Text('Load more'),
              onPressed: _loadLocalPublications,
            ),
            OutlinedTextButton(
              enableOutlineBorder: true,
              child: const Text('Refresh'),
              onPressed: () => _loadLocalPublications(true),
            ),
            OutlinedTextButton(
              enableOutlineBorder: true,
              child: const Text('Delete all'),
              onPressed: EditorProvider().clearAllPublications,
            ),
          ],
        )
      ],
    );
  }
}
