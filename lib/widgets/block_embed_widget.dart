import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../components/outlined_text_button.dart';
import '../models/types.dart';

class BlockEmbedWidget extends StatefulWidget {
  final int index;
  final BlockType type;
  const BlockEmbedWidget({
    Key? key,
    required this.index,
    required this.type,
  }) : super(key: key);

  @override
  State<BlockEmbedWidget> createState() => _BlockEmbedWidgetState();
}

class _BlockEmbedWidgetState extends State<BlockEmbedWidget> {
  final TextEditingController _controller = TextEditingController();

  PlatformFile? file;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose asset'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text('Enter a remote URL or choose local files'),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Remote URL',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedTextButton(
              child: Text('Choose ${widget.type.name.capitalized}'),
              onPressed: () async {
                final FileType type = widget.type == BlockType.image
                    ? FileType.image
                    : FileType.video;

                final FilePickerResult? result =
                    await FilePicker.platform.pickFiles(
                  type: type,
                  //withData: type == FileType.image ? true : false,
                );

                if (result != null) {
                  file = result.files.single;
                  setState(() {});
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Text(file == null ? 'No file chosen' : '${file!.name} chosen'),
          ],
        ),
      ),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: [
          OutlinedTextButton(
            child: const Text('Add'),
            onPressed: () {
              final data = EmbedData(
                url: _controller.text.isNotEmpty ? _controller.text : null,
                file: file,
              );

              print('${file?.bytes}');

              Navigator.of(context).pop(data);
            },
          ),
          OutlinedTextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

extension StringCapitalization on String {
  String get capitalized {
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
