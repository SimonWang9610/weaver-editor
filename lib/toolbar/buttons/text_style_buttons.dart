import 'package:flutter/material.dart';

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
