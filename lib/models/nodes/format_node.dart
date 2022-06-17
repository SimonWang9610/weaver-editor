import 'package:flutter/material.dart';
import 'package:weaver_editor/models/nodes/hyper_link_node.dart';

import '../../extensions/text_style_ext.dart';

import '../editing_selection.dart';
import 'block_range.dart';
import 'node_pair.dart';
import '../types.dart';

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

  void synchronize(TextStyle? newStyle) {
    if (newStyle != null) {
      style = newStyle;
      next?.synchronize(newStyle);
    }
  }

  TextSpan build(String content, {TextStyle? forcedStyle}) {
    final text = content.characters.getRange(range.start, range.end).string;
    // print('$range: $text, style: $style');

    final chainedSpan = next?.build(
      content,
      forcedStyle: forcedStyle,
    );

    return TextSpan(
      style: forcedStyle ?? style,
      text: text.isEmpty ? null : text,
      children: [
        if (chainedSpan != null) chainedSpan,
      ],
    );
  }

  String toPlainText(String content, String result) {
    final text = content.characters.getRange(range.start, range.end).string;

    if (text.isNotEmpty) {
      result += style.toHtml(text);
    }

    if (next != null) {
      result = next!.toPlainText(content, result);
    }
    return result;
  }

  void unlink() {
    // print('####################unlink: $range');
    previous = null;
    next = null;

    if (isInitNode) {
      previous?.unlink();
    }
  }

  void dispose() {
    // dereference to avoid memory leak
    next?.dispose();
    unlink();
  }

  /// to fuse all nodes between [startNode] and [endNode]
  /// to dereference all nodes between [NodePair]
  /// but keeps the [previous] of [startNode] and [next] of [endNode]
  /// so that we can re-chain the new part made of nodes to the original node chain
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
    if (range.start != baseOffset) {
      range = range.translateTo(baseOffset);

      next?.translateBase(range.end);
    }
  }

  /// find a [NodePair], a path connecting all nodes covered by [selection]
  /// [NodePair] will base on the [BlockEditingSelection.old] to calculate
  void findNodePair(BlockEditingSelection selection, NodePair pair) {
    if (selection.status == BlockEditingStatus.init) {
      range = NodeRange.fromSelection(selection.latest);

      pair.head = this;
      pair.trail = this;

      pair.markAsPaired();
    } else {
      // print('old selection: ${selection.old}');
      // print('latest selection: ${selection.latest}');
      // print('delta: ${selection.delta}');

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

  /// set [other] as [next] if cannot merge them
  void chainNext(FormatNode other) {
    assert(
        range.canChain(other.range), 'cannot chain $range <--> ${other.range}');

    assert(range.isValid, 'FormatNode range invalid: $this');

    if (range.canMerge(other.range)) {
      _merge(other);
    } else {
      next = other;
      other.previous = this;
    }
  }

  /// append [other] to the trail of the linked nodes
  void append(FormatNode other) {
    if (next != null) {
      next?.append(other);
    } else {
      chainNext(other);
    }
  }

  /// merge the adjacent nodes if
  /// 1) they have same [style] for [FormatNode]
  /// 2) they have same [url] for [HyperLinkNode]
  /// 3) no matter what kind of node they are,
  ///  we also merge them as long as [other] is collapsed
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

  bool notEndAt(int spot) {
    return spot < range.end;
  }

  bool notStartAt(int spot) {
    return spot > range.start;
  }

  /// particularly, the init [headNode] of each block usually is initialized as (0, 0)
  bool get isInitNode => range.start == 0 && range.end == 0;

  /// once merged, [other] must dereference its [previous] and [next]
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
