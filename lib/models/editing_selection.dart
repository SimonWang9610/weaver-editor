import 'package:flutter/services.dart';
import 'types.dart';

class BlockEditingSelection {
  final TextSelection old;
  final TextSelection latest;
  final BlockEditingStatus status;
  final int delta;

  BlockEditingSelection({
    required this.old,
    required this.latest,
    required this.delta,
    required this.status,
  });
}

extension TextSelectionCompare on TextSelection {
  TextSelection operator -(TextSelection other) {
    final start = this.start - other.start;
    final end = this.end - other.end;

    return TextSelection(
        baseOffset: start >= -1 ? start : -1,
        extentOffset: end >= -1 ? end : -1);
  }
}
