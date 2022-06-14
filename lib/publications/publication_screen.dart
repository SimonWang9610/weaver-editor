import 'package:flutter/material.dart';
import 'package:weaver_editor/publications/local_publication_list.dart';

import '../editor.dart';
import '../editor_toolbar.dart';

class PublicationScreen extends StatefulWidget {
  const PublicationScreen({Key? key}) : super(key: key);

  @override
  State<PublicationScreen> createState() => _PublicationScreenState();
}

class _PublicationScreenState extends State<PublicationScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Publication'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Create a new publication'),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  suffix: IconButton(
                    onPressed: _createNewPublication,
                    icon: const Icon(
                      Icons.create_outlined,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  hintText: 'Publication Title',
                ),
              ),
              const Text('Or load local publications'),
              const Expanded(
                child: LocalPublicationList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewPublication() {
    if (controller.text.isEmpty) return;

    final style = Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeaverEditor(
          title: controller.text,
          toolbar: EditorToolbar(style),
          defaultStyle: style,
        ),
      ),
    );
  }
}
