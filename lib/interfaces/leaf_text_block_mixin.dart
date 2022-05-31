import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/format_node.dart';
import 'package:weaver_editor/interfaces/toolbar_attach_delegate.dart';
import 'block_editing_controller.dart';
import 'node_pair.dart';

mixin LeafTextBlockOperationDelegate on EditorToolbarDelegate {
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
    print('^^^^^^^^^^^^^^^update format nodes^^^^^^^^^^^^^^^^');
    final pair = findNodesBySelection(selection);

    print('found pair: ${pair.head.range} <--> ${pair.trail.range}');
    print(' status: ${selection.status}');
    assert(pair.isPaired(), 'operation must be on a paired path');

    switch (selection.status) {
      case BlockEditingStatus.select:
        updateBySelection(
          selection,
          pair,
          composedStyle: composedStyle,
        );
        break;
      case BlockEditingStatus.delete:
        deleteBySelection(selection, pair);
        break;
      case BlockEditingStatus.insert:
        insertBySelection(
          selection,
          pair,
          composedStyle: composedStyle,
        );
        break;
      case BlockEditingStatus.init:
        break;
    }

    pair.unpair();
    print('^^^^^^^^^^^^end^^^^^^^^^^^^^^^^^^');

    return pair.isMerged();
  }

  void updateBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    late final TextStyle activeStyle;

    if (selection.latest.isCollapsed && !attachedToolbar!.formatting) {
      activeStyle = pair.head.style;

      if (!attachedToolbar!.synchronized) {
        // keep toolbar style same as the focused FormatNode
        attachedToolbar?.synchronize(activeStyle);
      }
    } else {
      activeStyle = attachedToolbar!.style;
    }

    if (activeStyle != pair.head.style) {
      _handleOperation(
        selection,
        pair,
        style: activeStyle,
      );
    }
  }

  void deleteBySelection(BlockEditingSelection selection, NodePair pair) {
    assert(selection.latest.isCollapsed);

    pair.trail = pair.trail.nodeContainsSpot(selection.old.extentOffset)!;

    _handleOperation(
      selection,
      pair,
    );

    if (attachedToolbar!.style != pair.head.style) {
      attachedToolbar?.synchronize(pair.head.style);
    }
  }

  void insertBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    print('inserting text');
    pair.head = pair.head.nodeContainsSpot(selection.old.baseOffset)!;

    _handleOperation(
      selection,
      pair,
      style: attachedToolbar!.style,
    );
  }

  void _handleOperation(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    final splitNodes = _splitNodeBySelection(
      selection,
      pair,
      style: style,
    );

    pair.fuse();

    _chainNodes(
      splitNodes: splitNodes,
      previous: pair.head.previous,
      next: pair.trail.next,
      operation: selection.status,
    );
  }

  List<FormatNode> _splitNodeBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    late final int previousEnd;
    late final int nextStart;

    // ! set  as [late final] will have silence exception
    FormatNode? middle;

    switch (selection.status) {
      case BlockEditingStatus.select:
        previousEnd = selection.latest.baseOffset;
        nextStart = selection.latest.extentOffset;
        break;
      case BlockEditingStatus.insert:
        previousEnd = selection.old.extentOffset;
        nextStart = selection.latest.extentOffset;
        break;
      case BlockEditingStatus.delete:
        previousEnd = selection.latest.baseOffset;
        nextStart = selection.latest.extentOffset;
        break;
      default:
        throw ErrorDescription('cannot split nodes for init status');
    }

    final previous = FormatNode.position(
      pair.start,
      previousEnd,
      style: pair.head.style,
    );

    if (selection.status == BlockEditingStatus.select ||
        selection.status == BlockEditingStatus.insert) {
      middle = FormatNode.position(
        previousEnd,
        nextStart,
        style: style ?? pair.head.style,
      );
    }

    final next = FormatNode.position(
      nextStart,
      pair.end + selection.delta,
      style: pair.trail.style,
    );

    print('next start: ${nextStart}, end: ${pair.end + selection.delta}');

    print('previous: ${previous.range}');
    print('middle: ${middle?.range}');
    print('next : ${next.range}');

    if (middle != null) {
      return [previous, middle, next];
    } else {
      return [previous, next];
    }
  }

  void _chainNodes({
    FormatNode? previous,
    FormatNode? next,
    required List<FormatNode> splitNodes,
    required BlockEditingStatus operation,
  }) {
    assert(splitNodes.length >= 2);

    FormatNode chain = splitNodes.first;

    for (final node in splitNodes) {
      chain = chain.chainNext(node);
    }

    if (next != null) {
      chain.chainNext(next);
    }

    print('first node: ${chain.range}');

    if (previous != null) {
      previous.chainNext(chain);
    } else {
      headNode.unlink();
      headNode = chain;
    }

    print('headNode range: ${headNode.range}');

    // final baseOffset = splitNodes.last.range.start;
    // splitNodes.last.translateTo(baseOffset);
    late final baseOffset = chain.range.start;
    chain.translateTo(baseOffset);
  }
}

enum Operation {
  select,
  delete,
  insert,
}
