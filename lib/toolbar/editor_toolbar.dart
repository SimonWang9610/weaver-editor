import 'package:flutter/material.dart';
import '../widgets/block_editing_controller.dart';
import 'buttons/text_style_buttons.dart';

class EditorToolbar with ChangeNotifier {
  TextStyle _historyStyle;
  TextStyle _style;
  TextAlign _align;
  bool _shouldApplyStyle = false;

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
      _shouldApplyStyle = true;

      notifyListeners();
    }
  }

  TextAlign get align => _align;
  set align(TextAlign value) {
    if (_align != value) {
      _align = value;
      _shouldApplyStyle = false;
      notifyListeners();
    }
  }

  void synchronize(TextStyle value) {
    print('synchronizing tool bal style..........');

    if (synchronized && _style == value) return;

    _historyStyle = value;
    _style = value;
    _shouldApplyStyle = true;
    // will re-build EditorToolbarWidget
    // to follow the style of the focused FormatNode
    notifyListeners();
  }

  bool get synchronized => _historyStyle == _style;

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

    _attachedController?.unfocus();

    _attachedController = null;
  }

  void _applyStyleByController() {
    if (_shouldApplyStyle) {
      _attachedController?.mayApplyStyle();
    }
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
