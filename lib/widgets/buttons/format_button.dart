import 'package:flutter/material.dart';

class FormatButton extends StatelessWidget {
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final Widget icon;
  const FormatButton({
    Key? key,
    required this.backgroundColor,
    required this.icon,
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
      child: icon,
    );
  }
}
