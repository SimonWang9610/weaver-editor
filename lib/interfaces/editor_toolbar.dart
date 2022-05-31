import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/block_editing_controller.dart';

class EditorToolbar with ChangeNotifier {
  TextStyle _historyStyle;
  TextStyle _style;
  TextAlign _align;

  bool _formatting = false;

  EditorToolbar(TextStyle style, {TextAlign? align})
      : _style = style,
        _historyStyle = style,
        _align = align ?? TextAlign.start;

  TextStyle get style => _style;
  set style(TextStyle value) {
    if (_style != value) {
      _historyStyle = _style;
      _style = value;
      _formatting = true;

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

  bool get formatting => _formatting;
  bool get synchronized => _historyStyle == _style;

  BlockEditingController? _attachedController;

  EditorToolbar attach(BlockEditingController controller) {
    // should detach bound controller before attaching new controller
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
    if (style.fontWeight == FontWeight.bold) {
      style = style.copyWith(
        fontWeight: FontWeight.normal,
      );
    } else {
      style = style.copyWith(fontWeight: FontWeight.bold);
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
    _attachedController?.mayApplyStyle(!synchronized || formatting);
  }

  void synchronize(TextStyle value) {
    _historyStyle = value;
    _style = value;
    _formatting = false;
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
              iconColor: _currentStyle.fontWeight == FontWeight.bold
                  ? Colors.grey
                  : null,
              onPressed: widget.toolbar.boldText,
            ),
            FormatItalicButton(
              iconColor: _currentStyle.fontStyle == FontStyle.italic
                  ? Colors.grey
                  : null,
              onPressed: widget.toolbar.italicText,
            ),
            FormatUnderlineButton(
              iconColor: _currentStyle.decoration == TextDecoration.underline
                  ? Colors.grey
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
  final Color? iconColor;
  final VoidCallback? onPressed;
  const FormatBoldButton({
    Key? key,
    this.iconColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: iconColor,
      icon: const Icon(
        Icons.format_bold_outlined,
      ),
    );
  }
}

class FormatItalicButton extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback? onPressed;
  const FormatItalicButton({
    Key? key,
    this.iconColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: iconColor,
      icon: const Icon(Icons.format_italic_outlined),
    );
  }
}

class FormatUnderlineButton extends StatelessWidget {
  final Color? iconColor;
  final VoidCallback? onPressed;
  const FormatUnderlineButton({
    Key? key,
    this.iconColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: iconColor,
      icon: const Icon(Icons.format_underline_outlined),
    );
  }
}
