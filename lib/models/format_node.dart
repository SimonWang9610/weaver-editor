import 'package:flutter/material.dart';
import 'package:weaver_editor/models/hyper_link_node.dart';

import 'editing_selection.dart';
import 'block_range.dart';
import 'node_pair.dart';
import 'types.dart';

class FormatNode {
  FormatNode? previous;
  FormatNode? next;

  TextStyle style;
  late NodeRange range;

  FormatNode({
    required TextSelection selection,
    required this.style,
  }) : range = NodeRange.fromSelection(selection);

  factory FormatNode.position(int start, int end, {required TextStyle style}) {
    final selection = TextSelection(baseOffset: start, extentOffset: end);
    return FormatNode(selection: selection, style: style);
  }

  // used to chain new nodes split by [select/delete/insert] operations
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
    print('####################unlink: $range');
    previous = null;
    next = null;
  }

  void dispose() {
    // dereference to avoid memory leak
    next?.dispose();
    unlink();
  }

  // to fuse all nodes between [startNode] and [endNode]
  //
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

  // translate the node to the specific baseOffset
  // but not change its interval
  void translateBase(int baseOffset) {
    print('translate from ${range.start} to $baseOffset');

    if (range.start != baseOffset) {
      range = range.translateTo(baseOffset);

      next?.translateBase(range.end);
    }
  }

  // find all nodes containing [selection]
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
      // if the node is the last node
      // we should re-range because both its baseOffset and interval may change
      range = range.rerangeTo(
        baseOffset: range.start,
        extentOffset: selection.old.extentOffset,
      );
      pair.trail = this;
      pair.markAsPaired();
    }
  }

  // ensure the found node pair correct
  // if searchNext is true, we may continue searching the next node
  // if false, we may continue searching the previous node;
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

    if (!range.isValid) {
      throw ErrorDescription('FormatNode range invalid: $this');
    }

    next = other;
    other.previous = this;
  }

  FormatNode? merge(FormatNode other) {
    if (other.range.isCollapsed) {
      return _merge(other);
    }

    if (this is HyperLinkNode && other is HyperLinkNode) {
      if ((this as HyperLinkNode).url == other.url) {
        return _merge(other);
      }
    }

    if (style == other.style || other.range.canMerge(range)) {
      return _merge(other);
    }

    return null;
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

  bool notEndAt(int spot) {
    return spot < range.end;
  }

  bool notStartAt(int spot) {
    return spot > range.start;
  }

  bool get isInitNode => range.start == 0 && range.end == 0;

  FormatNode _merge(FormatNode other) {
    range = range + other.range;
    next = other.next;
    other.unlink();
    return this;
  }

  @override
  bool operator ==(covariant FormatNode other) {
    return range == other.range;
  }

  @override
  int get hashCode => range.hashCode;

  bool get canAsHeadNode => range.start == 0;

  @override
  String toString() {
    return '$range -> $next';
  }
}
