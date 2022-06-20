import 'package:flutter/material.dart';
import 'package:weaver_editor/models/editor_metadata.dart';
import 'package:weaver_editor/publications/local_publication_list.dart';

import 'package:weaver_editor/editor.dart';

class PublicationScreen extends StatefulWidget {
  const PublicationScreen({Key? key}) : super(key: key);

  @override
  State<PublicationScreen> createState() => _PublicationScreenState();
}

class _PublicationScreenState extends State<PublicationScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Your Publication'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Create a new publication',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: controller,
                  focusNode: focus,
                  decoration: InputDecoration(
                    suffix: IconButton(
                      onPressed: _createNewPublication,
                      icon: const Icon(
                        Icons.create_outlined,
                        size: 14,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Publication Title',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Expanded(
                  child: LocalPublicationList(),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: focus.unfocus,
    );
  }

  void _createNewPublication() {
    if (controller.text.isEmpty) return;

    final style = Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    final title = controller.text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeaverEditor(
          metadata: EditorMetadata(title: title),
          defaultStyle: style,
        ),
      ),
    );

    controller.clear();
  }
}
