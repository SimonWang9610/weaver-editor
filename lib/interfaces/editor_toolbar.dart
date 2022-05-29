import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/block_editing_controller.dart';
import 'content_block.dart';

class EditorToolbar {
  TextStyle? style;

  BlockEditingController? _attachedController;

  void attach(BlockEditingController controller) {
    _attachedController = controller;
  }

  void unattach() {
    _attachedController = null;
  }
}
