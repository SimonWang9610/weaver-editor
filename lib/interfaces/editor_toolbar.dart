import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/block_editing_controller.dart';

class EditorToolbar with ChangeNotifier {
  TextStyle _historyStyle;
  TextStyle _style;
  TextAlign _align;

  EditorToolbar(TextStyle style, {TextAlign? align})
      : _style = style,
        _historyStyle = style,
        _align = align ?? TextAlign.start;

  TextStyle get style => _style;
  set style(TextStyle value) {
    if (_style != value) {
      print('@@@@formatting text by toolbar');
      _historyStyle = _style;
      _style = value;
      notifyListeners();
    }
  }

  TextAlign get align => _align;
  set align(TextAlign value) {
    if (_align != value) {
      _align = value;
      notifyListeners();
    }
  }

  // only when set cursor manually or delete text
  // we need to synchronize style with the format node
  // once we complete select/insert operation
  // we must reset [needSynchronized] to false
  // because the two operations always make tool bar synchronized with node
  bool get synchronized => _historyStyle == _style;

  BlockEditingController? _attachedController;

  EditorToolbar attach(BlockEditingController controller) {
    // should detach bound controller before attaching new controller

    if (_attachedController == controller) return this;

    detach();
    _attachedController = controller;

    addListener(_applyStyleByController);

    return this;
  }

  void detach() {
    removeListener(_applyStyleByController);
    _attachedController = null;
  }

  void boldText() {
    if (style.fontWeight == FontWeight.w900) {
      style = style.copyWith(
        fontWeight: FontWeight.normal,
      );
    } else {
      style = style.copyWith(fontWeight: FontWeight.w900);
    }
  }

  void italicText() {
    if (style.fontStyle == FontStyle.italic) {
      style = style.copyWith(fontStyle: FontStyle.normal);
    } else {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
  }

  void underlineText() {
    if (style.decoration == TextDecoration.underline) {
      style = style.copyWith(decoration: TextDecoration.none);
    } else {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
  }

  void _applyStyleByController() {
    _attachedController?.mayApplyStyle();
  }

  void synchronize(TextStyle value) {
    print('synchronizing tool bal style..........');

    if (synchronized && _style == value) return;

    _historyStyle = value;
    _style = value;
    // will re-build EditorToolbarWidget
    // to follow the style of the focused FormatNode
    notifyListeners();
  }
}

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
  late TextStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.toolbar.style;
    widget.toolbar.addListener(_handleToolbarStyleChange);
  }

  @override
  void didUpdateWidget(covariant EditorToolbarWidget oldWidget) {
    if (widget.toolbar != oldWidget.toolbar) {
      oldWidget.toolbar.removeListener(_handleToolbarStyleChange);
      widget.toolbar.addListener(_handleToolbarStyleChange);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.toolbar.removeListener(_handleToolbarStyleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // TODO: enable change block align

    return SizedBox(
      width: size.width,
      height: size.height * 0.1,
      child: RepaintBoundary(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FormatBoldButton(
              backgroundColor: _currentStyle.fontWeight == FontWeight.w900
                  ? Colors.greenAccent
                  : null,
              onPressed: widget.toolbar.boldText,
            ),
            FormatItalicButton(
              backgroundColor: _currentStyle.fontStyle == FontStyle.italic
                  ? Colors.greenAccent
                  : null,
              onPressed: widget.toolbar.italicText,
            ),
            FormatUnderlineButton(
              backgroundColor:
                  _currentStyle.decoration == TextDecoration.underline
                      ? Colors.greenAccent
                      : null,
              onPressed: widget.toolbar.underlineText,
            )
          ],
        ),
      ),
    );
  }

  void _handleToolbarStyleChange() {
    _currentStyle = widget.toolbar.style;
    setState(() {});
  }
}

class FormatBoldButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  const FormatBoldButton({
    Key? key,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: const Icon(Icons.format_bold_outlined),
    );
  }
}

class FormatItalicButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  const FormatItalicButton({
    Key? key,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: const Icon(Icons.format_italic_outlined),
    );
  }
}

class FormatUnderlineButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  const FormatUnderlineButton({
    Key? key,
    this.backgroundColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: const Icon(Icons.format_underline_outlined),
    );
  }
}
