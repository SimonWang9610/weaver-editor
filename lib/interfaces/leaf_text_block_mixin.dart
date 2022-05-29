import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/format_node.dart';
import 'block_editing_controller.dart';
import 'node_pair.dart';

mixin LeafTextBlockOperationDelegate {
  FormatNode get headNode;
  set headNode(FormatNode newNode);

  NodePair findNodesBySelection(BlockEditingSelection selection) {
    final pair = NodePair(headNode, trail: headNode);
    headNode.findNodePair(selection, pair);
    return pair;
  }

  bool mayUpdateNodes(
    BlockEditingSelection selection, {
    TextStyle? composedStyle,
  }) {
    final pair = findNodesBySelection(selection);

    assert(pair.isPaired(), 'operation must be on a paired path');

    switch (selection.status) {
      case BlockEditingStatus.select:
        mayUpdateStyleBySelection(
          selection,
          pair,
          composedStyle: composedStyle,
        );
        break;
      case BlockEditingStatus.delete:
        mergeDeletedNodes(selection, pair);
        break;
      case BlockEditingStatus.insert:
        maySplitNodeBySelection(
          selection,
          pair,
          composedStyle: composedStyle,
        );
        break;
    }

    pair.unpair();

    return pair.isMerged();
  }

  void mayUpdateStyleBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    if (composedStyle != null && !selection.latest.isCollapsed) {
      final middleHalf =
          FormatNode(selection: selection.latest, style: composedStyle);

      _handleOperation(selection, pair, middle: middleHalf);
    }
  }

  void mergeDeletedNodes(BlockEditingSelection selection, NodePair pair) {
    assert(selection.latest.isCollapsed);
    assert(pair.isPaired(), 'operation must be on a paired path');

    pair.trail = pair.trail.nodeContainsSpot(selection.old.extentOffset)!;

    _handleOperation(selection, pair);
  }

  void maySplitNodeBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    pair.head = pair.head.nodeContainsSpot(selection.old.baseOffset)!;

    final middleHalf = FormatNode(
      selection: selection.latest,
      style: composedStyle ?? pair.head.style,
    );

    _handleOperation(selection, pair, middle: middleHalf);
  }

  void _handleOperation(
    BlockEditingSelection selection,
    NodePair pair, {
    FormatNode? middle,
  }) {
    final splitNodes = _splitNodeBySelection(selection, pair, middle: middle);

    pair.merge();

    _chainNodes(
      splitNodes: splitNodes,
      previous: pair.head.previous,
      next: pair.trail.next,
    );
  }

  List<FormatNode> _splitNodeBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    FormatNode? middle,
  }) {
    final firstHalf = FormatNode.position(
      pair.start,
      selection.latest.baseOffset,
      style: pair.head.style,
    );
    final secondHalf = FormatNode.position(
      selection.latest.extentOffset,
      pair.end,
      style: pair.trail.style,
    );

    if (middle != null) {
      return [firstHalf, middle, secondHalf];
    } else {
      return [firstHalf, secondHalf];
    }
  }

  void _chainNodes({
    FormatNode? previous,
    FormatNode? next,
    required List<FormatNode> splitNodes,
  }) {
    assert(splitNodes.length >= 2);

    for (int i = 1; i < splitNodes.length; i++) {
      splitNodes[i - 1].chainNext(splitNodes[i]);
    }

    if (previous != null) {
      previous.chainNext(splitNodes.first);
    } else {
      headNode.copy(splitNodes.first);
    }

    if (next != null) {
      splitNodes.last.chainNext(next);
    }

    final baseOffset = splitNodes.last.range.start;
    splitNodes.last.translateTo(baseOffset);
  }
}
