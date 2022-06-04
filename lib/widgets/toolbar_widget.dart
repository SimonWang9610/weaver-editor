import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weaver_editor/widgets/buttons/add_link_button.dart';
import '../editor_toolbar.dart';
import 'buttons/format_button.dart';

class EditorToolbarWidget extends StatefulWidget {
  final EditorToolbar toolbar;
  const EditorToolbarWidget({
    Key? key,
    required this.toolbar,
  }) : super(key: key);

  @override
  State<EditorToolbarWidget> createState() => _EditorToolbarWidgetState();
}

class _EditorToolbarWidgetState extends State<EditorToolbarWidget> {
  late final StreamSubscription _sub;
  late TextStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.toolbar.style;
    _sub = widget.toolbar.listen(_handleToolbarStyleChange);
  }

  @override
  void didUpdateWidget(covariant EditorToolbarWidget oldWidget) {
    if (widget.toolbar != oldWidget.toolbar) {
      _sub.cancel();
      _sub = widget.toolbar.listen(_handleToolbarStyleChange);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // TODO: enable change block align

    return SizedBox(
      width: size.width,
      height: size.height * 0.05,
      child: RepaintBoundary(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FormatButton(
              backgroundColor: _currentStyle.fontWeight == FontWeight.w900
                  ? Colors.grey
                  : null,
              onPressed: widget.toolbar.boldText,
              icon: const Icon(
                Icons.format_bold_outlined,
                color: Colors.black,
              ),
            ),
            FormatButton(
              backgroundColor: _currentStyle.fontStyle == FontStyle.italic
                  ? Colors.grey
                  : null,
              onPressed: widget.toolbar.italicText,
              icon: const Icon(
                Icons.format_italic_outlined,
                color: Colors.black,
              ),
            ),
            FormatButton(
              backgroundColor:
                  _currentStyle.decoration == TextDecoration.underline
                      ? Colors.grey
                      : null,
              onPressed: widget.toolbar.underlineText,
              icon: const Icon(
                Icons.format_underline_outlined,
                color: Colors.black,
              ),
            ),
            HyperLinkButton(
              onPressed: () => widget.toolbar.addLinkInFocusedBlock(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToolbarStyleChange(ToolbarEvent event) {
    _currentStyle = widget.toolbar.style;
    setState(() {});
  }
}
