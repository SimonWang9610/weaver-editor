import 'package:flutter/material.dart';

class NodeRange {
  final int start;
  final int end;

  NodeRange({
    required this.start,
    required this.end,
  });

  factory NodeRange.empty() => NodeRange(start: 0, end: 0);

  factory NodeRange.collapsed(int offset) =>
      NodeRange(start: offset, end: offset);

  factory NodeRange.fromSelection(TextSelection selection) {
    if (selection.isCollapsed) {
      return NodeRange.collapsed(selection.baseOffset);
    } else {
      return NodeRange(
          start: selection.baseOffset, end: selection.extentOffset);
    }
  }

  factory NodeRange.normalization(int num1, int num2) {
    if (num1 <= num2) {
      return NodeRange(start: num1, end: num2);
    } else {
      return NodeRange(start: num2, end: num1);
    }
  }

  bool get isCollapsed => start >= end;

  // translate range starting from the baseOffset
  NodeRange translateTo(int baseOffset) {
    final extOffset = baseOffset + (end - start);

    return NodeRange(start: baseOffset, end: extOffset);
  }

  NodeRange rerangeTo({int? baseOffset, int? extentOffset}) => NodeRange(
        start: baseOffset ?? start,
        end: extentOffset ?? end,
      );

  bool contains(int spot) {
    final isZero = spot == 0 && start == 0;

    return (isZero || start < spot) && end >= spot;
  }

  bool canChain(NodeRange other) => end == other.start;
  bool canMerge(NodeRange previous) {
    return previous.end == start && start == end;
  }

  int get interval => end - start;

  NodeRange operator +(covariant NodeRange other) {
    assert(end == other.start || start == other.start && end == other.end,
        'NodeRanges must be consecutive or identical to add');
    return NodeRange(start: start, end: other.end);
  }

  @override
  bool operator ==(covariant NodeRange other) {
    return other.start == start && other.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() {
    return 'NodeRange($start, $end)';
  }
}
