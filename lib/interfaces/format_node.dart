import 'package:flutter/material.dart';

import 'block_range.dart';
import 'block_editing_controller.dart';
import 'node_pair.dart';

class FormatNode {
  FormatNode? previous;
  FormatNode? next;

  late NodeRange range;
  TextStyle? style;

  FormatNode({
    required TextSelection selection,
    this.style,
  }) : range = NodeRange.fromSelection(selection);

  factory FormatNode.position(int start, int end, {TextStyle? style}) {
    final selection = TextSelection(baseOffset: start, extentOffset: end);
    return FormatNode(selection: selection, style: style);
  }

  void copy(FormatNode other) {
    range = other.range;
    style = other.style;
    previous = other.previous;
    next = other.next;

    other.unlink();
  }

  void unlink() {
    previous = null;
    next = null;
    style = null;
  }

  void dispose() {
    // dereference to avoid memory leak
    next?.dispose();
    previous = null;
    next = null;
  }

  void merge(FormatNode startNode, FormatNode endNode) {
    // merge always starts from head to trail
    // no need to propagate to its previous node
    // set null to avoid memory leak

    if (this != startNode) {
      previous = null;
    }

    if (this != endNode) {
      next?.merge(startNode, endNode);
      next = null;
    }
  }

  void translateTo(int baseOffset) {
    range = range.translateTo(baseOffset);

    next?.translateTo(range.end);
  }

  @override
  bool operator ==(covariant FormatNode other) {
    return range == other.range;
  }

  @override
  int get hashCode => range.hashCode;

  void findNodePair(BlockEditingSelection selection, NodePair pair) {
    if (range.contains(selection.latest.baseOffset)) {
      pair.head = this;
    }

    if (range.contains(selection.latest.extentOffset)) {
      pair.trail = this;
      pair.markAsPaired();
    }

    if (pair.isPaired()) return;

    next?.findNodePair(selection, pair);
  }

  FormatNode? nodeContainsSpot(int spot) {
    if (range.contains(spot)) {
      return this;
    } else {
      return next?.nodeContainsSpot(spot);
    }
  }

  void chainNext(FormatNode? other) {
    // if two nodes have same styles, merge them instead of chaining them
    if (other != null && style == other.style) {
      range = range + other.range;
    } else {
      next = other;
      other?.previous = this;
    }
  }

  TextSpan build(String content) {
    final text = content.characters.getRange(range.start + 1, range.end).string;

    final chainedSpan = next?.build(content);

    return TextSpan(
      style: style,
      text: text,
      children: [
        if (chainedSpan != null) chainedSpan,
      ],
    );
  }
}
