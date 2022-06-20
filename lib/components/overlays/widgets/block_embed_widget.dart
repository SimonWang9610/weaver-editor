import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:weaver_editor/components/outlined_text_button.dart';
import 'package:weaver_editor/models/types.dart';

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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? remoteUrl;
  String? caption;
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
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: '${widget.type.name.capitalized} URL',
                    ),
                    onChanged: (value) {
                      remoteUrl = value;
                    },
                    onSaved: (value) {
                      remoteUrl = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Caption',
                    ),
                    onChanged: (value) {
                      caption = value;
                    },
                    onSaved: (value) {
                      caption = value;
                    },
                  ),
                ],
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
              formKey.currentState?.save();

              final data = EmbedData(
                url: remoteUrl != null && remoteUrl!.isNotEmpty
                    ? remoteUrl
                    : null,
                file: file,
                caption: caption,
              );

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
