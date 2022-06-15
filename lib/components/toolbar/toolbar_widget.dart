import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weaver_editor/components/toolbar/block_format_widget.dart';
import 'package:weaver_editor/components/toolbar/block_header_widget.dart';
import 'package:weaver_editor/components/overlays/block_align_overlay.dart';
import '../../editor_toolbar.dart';

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
  String type = 'paragraph';

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

    return SizedBox(
      width: size.width,
      height: size.height * 0.05,
      child: RepaintBoundary(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            type == 'paragraph'
                ? BlockFormatWidget(
                    style: _currentStyle,
                    toolbar: widget.toolbar,
                  )
                : BlockHeaderWidget(
                    toolbar: widget.toolbar,
                  ),
            const BlockAlignOverlay(),
          ],
        ),
      ),
    );
  }

  void _handleToolbarStyleChange(ToolbarEvent event) {
    _currentStyle = widget.toolbar.style;
    type = widget.toolbar.blockType ?? 'paragraph';
    setState(() {});
  }
}
