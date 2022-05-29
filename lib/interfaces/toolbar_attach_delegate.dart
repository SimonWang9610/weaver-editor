import 'package:weaver_editor/interfaces/editor_toolbar.dart';

mixin EditorToolbarDelegate {
  EditorToolbar? attachedToolbar;

  void attach();

  void detach() => attachedToolbar = null;
}
