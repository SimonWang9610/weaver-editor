import 'package:flutter/material.dart';

import 'block_range.dart';
import 'block_editing_controller.dart';
import 'node_pair.dart';

class FormatNode {
  FormatNode? previous;
  FormatNode? next;

  late NodeRange range;
  TextStyle style;

  FormatNode({
    required TextSelection selection,
    required this.style,
  }) : range = NodeRange.fromSelection(selection);

  factory FormatNode.position(int start, int end, {required TextStyle style}) {
    final selection = TextSelection(baseOffset: start, extentOffset: end);
    return FormatNode(selection: selection, style: style);
  }

  static NodePair chain(List<FormatNode> nodes) {
    final trail = nodes.fold<FormatNode>(nodes.first, (previous, current) {
      final merged = previous.merge(current);

      if (merged != null) {
        return merged;
      } else {
        previous.chainNext(current);
        return current;
      }
    });

    return NodePair(nodes.first, trail: trail);
  }

  void unlink() {
    previous = null;
    next = null;
  }

  void dispose() {
    // dereference to avoid memory leak
    next?.dispose();
    previous = null;
    next = null;
  }

  void fuse(FormatNode startNode, FormatNode endNode) {
    // merge always starts from head to trail
    // no need to propagate to its previous node
    // set null to avoid memory leak

    if (this != startNode) {
      previous = null;
    }

    if (this != endNode) {
      next?.fuse(startNode, endNode);
      next = null;
    }
  }

  void translateBase(int baseOffset) {
    print('translate from ${range.start} to $baseOffset');

    if (range.start != baseOffset) {
      range = range.translateTo(baseOffset);

      next?.translateBase(range.end);
    }
  }

  void findNodePair(BlockEditingSelection selection, NodePair pair) {
    if (selection.status == BlockEditingStatus.init) {
      range = NodeRange.fromSelection(selection.latest);

      pair.head = this;
      pair.trail = this;

      pair.markAsPaired();
    } else {
      print('old selection: ${selection.old}');
      print('latest selection: ${selection.latest}');
      print('delta: ${selection.delta}');

      if (range.contains(selection.old.baseOffset)) {
        pair.head = this;
      }

      if (range.contains(selection.old.extentOffset)) {
        pair.trail = this;
        pair.markAsPaired();
      }
    }

    if (pair.isPaired()) return;

    // if next is null
    // the cursor is at the end of the paragraph
    if (next != null) {
      next?.findNodePair(selection, pair);
    } else {
      range = range.rerangeTo(
        baseOffset: range.start,
        extentOffset: selection.old.extentOffset,
      );
      pair.trail = this;
      pair.markAsPaired();
    }
  }

  FormatNode? nodeContainsSpot(int spot, {bool searchNext = true}) {
    if (range.contains(spot)) {
      return this;
    } else {
      return searchNext
          ? next?.nodeContainsSpot(spot)
          : previous?.nodeContainsSpot(
              spot,
              searchNext: false,
            );
    }
  }

  void chainNext(FormatNode other) {
    assert(range.canChain(other.range), '');

    if (!range.canChain(other.range)) {
      throw ErrorDescription('cannot chain $range <--> ${other.range}');
    }
    next = other;
    other.previous = this;
  }

  FormatNode? merge(FormatNode other) {
    if (style == other.style || other.range.canMerge(range)) {
      range = range + other.range;
      next = other.next;
      other.unlink();
      return this;
    } else {
      return null;
    }
  }

  TextSpan build(String content) {
    final text = content.characters.getRange(range.start, range.end).string;
    print('$range: $text');
    final chainedSpan = next?.build(content);

    return TextSpan(
      style: style,
      text: text.isEmpty ? null : text,
      children: [
        if (chainedSpan != null) chainedSpan,
      ],
    );
  }

  @override
  bool operator ==(covariant FormatNode other) {
    return range == other.range;
  }

  @override
  int get hashCode => range.hashCode;

  @override
  String toString() {
    return '$range -> $next';
  }
}
