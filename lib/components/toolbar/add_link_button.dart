import 'package:flutter/material.dart';
import '../../models/types.dart';

class HyperLinkButton extends StatelessWidget {
  final VoidCallback onPressed;
  const HyperLinkButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      child: const Icon(Icons.add_link),
    );
  }
}

class HyperLinkForm extends StatefulWidget {
  final int? cursorOffset;
  const HyperLinkForm({
    Key? key,
    required this.cursorOffset,
  }) : super(key: key);

  @override
  State<HyperLinkForm> createState() => _HyperLinkFormState();
}

class _HyperLinkFormState extends State<HyperLinkForm> {
  final formKey = GlobalKey<FormState>();

  String? linkUrl;
  String? linkCaption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hyperlink'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'enter link URL',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? url) {
                    if (url != null) {
                      final parsedUrl = Uri.tryParse(url);
                      if (parsedUrl == null) {
                        return 'please enter a valid url';
                      }
                    }
                    return null;
                  },
                  onSaved: (String? url) {
                    linkUrl = url;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'enter URL label',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? caption) {
                    if (caption == null) {
                      return 'caption must not be empty';
                    }
                  },
                  onSaved: (String? caption) => linkCaption = caption,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () {
              final form = formKey.currentState!;

              if (form.validate()) {
                form.save();
                final data = HyperLinkData(
                  linkUrl!,
                  caption: linkCaption!,
                  pos: widget.cursorOffset,
                );
                Navigator.of(context).pop(data);
              }
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }
}
