import 'package:flutter/material.dart';
import 'package:weaver_editor/core/editor_controller.dart';
import 'package:weaver_editor/models/editor_metadata.dart';
import 'package:weaver_editor/toolbar/editor_toolbar.dart';
import 'package:weaver_editor/widgets/editor_widget.dart';

class WeaverEditor extends StatefulWidget {
  final EditorMetadata metadata;
  final TextStyle defaultStyle;
  final Widget? child;
  const WeaverEditor({
    Key? key,
    required this.defaultStyle,
    required this.metadata,
    this.child,
  }) : super(key: key);

  @override
  State<WeaverEditor> createState() => _WeaverEditorState();
}

class _WeaverEditorState extends State<WeaverEditor> {
  late final EditorToolbar toolbar;
  late final WeaverEditorProvider provider;

  late final EditorController controller;

  @override
  void initState() {
    super.initState();
    toolbar = EditorToolbar(widget.defaultStyle);

    controller = EditorController(
      toolbar,
      defaultStyle: widget.defaultStyle,
      metadata: widget.metadata,
    );
  }

  @override
  void dispose() {
    toolbar.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WeaverEditorProvider(
      controller: controller,
      child: widget.child ?? const EditorWidget(),
    );
  }
}

class WeaverEditorProvider extends InheritedWidget {
  final EditorController controller;
  const WeaverEditorProvider({
    Key? key,
    required this.controller,
    Widget child = const EditorWidget(),
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant WeaverEditorProvider oldWidget) {
    return !identical(controller, oldWidget.controller);

    // if (!identical(controller.blocks, oldWidget.controller.blocks)) return true;

    // if (controller.blocks.length != oldWidget.controller.blocks.length) {
    //   return true;
    // }

    // for (int i = 0; i < controller.blocks.length; i++) {
    //   final block = controller.blocks[i];
    //   final oldBlock = oldWidget.controller.blocks[i];

    //   if (block.id != oldBlock.id) return true;
    // }
    // return false;
  }

  static EditorController of(BuildContext context, {bool listen = false}) {
    final WeaverEditorProvider? editor = listen
        ? context.dependOnInheritedWidgetOfExactType<WeaverEditorProvider>()
        : context.findAncestorWidgetOfExactType<WeaverEditorProvider>();

    if (editor == null) {
      throw ErrorDescription(
          'BuildContext does not has a root of [WeaverEditorProvider]');
    }
    return editor.controller;
  }
}
