import 'package:flutter/material.dart';

class OutlinedTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool enableOutlineBorder;
  const OutlinedTextButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
    this.enableOutlineBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: child,
      ),
      style: enableOutlineBorder
          ? style ??
              TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(),
                  borderRadius: BorderRadius.circular(4),
                ),
              )
          : null,
    );
  }
}
