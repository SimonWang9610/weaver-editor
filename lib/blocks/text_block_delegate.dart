import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/content_block.dart';
import 'package:weaver_editor/models/format_node.dart';
import 'package:weaver_editor/toolbar/toolbar_attach_delegate.dart';
import '../widgets/block_editing_controller.dart';
import '../models/node_pair.dart';

mixin LeafTextBlockOperationDelegate<T extends ContentBlock>
    on EditorToolbarDelegate<T> {
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
    if (attachedToolbar == null) return false;

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

    print('^^^^^^^^^^^^end^^^^^^^^^^^^^^^^^^');

    return pair.isMerged();
  }

  void updateBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    if (selection.latest.isCollapsed) {
      attachedToolbar?.synchronize(pair.head.style);
    }

    final activeStyle = attachedToolbar!.style;

    if (activeStyle != pair.head.style && !selection.latest.isCollapsed) {
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

    // if (attachedToolbar!.style != pair.head.style) {
    //   attachedToolbar?.synchronize(pair.head.style);
    // }
  }

  void insertBySelection(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? composedStyle,
  }) {
    pair.head = pair.head.nodeContainsSpot(
      selection.old.baseOffset,
      searchNext: false,
    )!;
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

    final sanitizedPair = pair.sanitize()!;

    _chainNodes(
      splitNodes: splitNodes,
      previous: sanitizedPair.first,
      next: sanitizedPair.last,
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

    final chained = FormatNode.chain(splitNodes);

    print('previous: $previous');
    print('chained split nodes: $chained');
    print('next: $next');

    if (next != null) {
      // ! next will base on the old previous node
      // ! must translateBase before chaining to the new node
      next.translateBase(chained.trail.range.end);
      chained.trail.chainNext(next);
    }

    if (previous != null) {
      previous.chainNext(chained.head);
    } else {
      headNode.unlink();
      headNode = chained.head;
    }

    print('headNode: $headNode');
  }
}
