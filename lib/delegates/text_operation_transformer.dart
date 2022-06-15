import 'package:flutter/material.dart';
import 'package:weaver_editor/blocks/base_block.dart';
import 'package:weaver_editor/models/format_node.dart';
import 'package:weaver_editor/delegates/toolbar_attach_delegate.dart';

import '../models/editing_selection.dart';
import '../models/node_pair.dart';
import '../models/hyper_link_node.dart';
import '../models/types.dart';

/// [updateBySelection]
/// 1) if [TextSelection.isCollapsed], we should synchronize the toolbar style with the current format node
/// 2) [TextSelection] is not collapsed, we should only apply the toolbar style
///   when the toolbar is not synchronized
///
/// [deleteBySelection]
/// [insertBySelection]
///  no need to manually synchronize the toolbar style
///   because there is always collapsed selection operation after delete and insert operations
mixin LeafTextBlockTransformer<T extends StatefulBlock>
    on EditorToolbarDelegate<T> {
  FormatNode get headNode;
  set headNode(FormatNode newNode);

  NodePair findNodesBySelection(BlockEditingSelection selection) {
    final pair = NodePair(headNode, trail: headNode);
    headNode.findNodePair(selection, pair);
    return pair;
  }

  bool transform(BlockEditingSelection selection) {
    if (attachedToolbar == null) return false;

    // print('^^^^^^^^^^^^^^^update format nodes^^^^^^^^^^^^^^^^');
    final pair = findNodesBySelection(selection);

    // print('found pair: $pair');
    print(' status: ${selection.status}');
    assert(pair.isPaired(), 'operation must be on a paired path');

    switch (selection.status) {
      case BlockEditingStatus.select:
        updateBySelection(
          selection,
          pair,
        );
        break;
      case BlockEditingStatus.delete:
        deleteBySelection(selection, pair);
        break;
      case BlockEditingStatus.insert:
        insertBySelection(
          selection,
          pair,
        );
        break;
      case BlockEditingStatus.init:
        break;
    }

    // print('^^^^^^^^^^^^end^^^^^^^^^^^^^^^^^^');

    return pair.isMerged();
  }

  /// 1) do not apply any style changes if [NodePair] is on the same [HyperLinkNode]
  /// 2) [synchronize] the style if the [BlockEditingSelection.last] is collapsed
  /// therefore, we could keep [attachedToolbar] always has the synchronized style with the focused node
  /// ! because it will trigger a selection operation automatically after completing each insert/delete operation
  /// 3) when the [BlockEditingSelection.last] is not collapsed, we may not need to apply the stye of [attachedToolbar]
  /// if the toolbar style is still synchronized. only when the toolbar style is also not synchronized, we must apply the style to the selected words
  void updateBySelection(BlockEditingSelection selection, NodePair pair) {
    // ! do not apply style changes to same HyperLinkNode
    if (pair.onSameLinkNode) return;
    // ! if cursor at the end of HyperLinkNode, do not synchronize style
    if (selection.latest.isCollapsed) {
      if (pair.head is! HyperLinkNode) {
        attachedToolbar?.synchronize(pair.head.style);
      } else {
        attachedToolbar?.synchronize(pair.trail.next?.style);
      }
    }

    final activeStyle = attachedToolbar!.style;

    if (activeStyle != pair.head.style &&
        !selection.latest.isCollapsed &&
        !attachedToolbar!.synchronized) {
      _handleOperation(
        selection,
        pair,
        style: activeStyle,
      );
    }
  }

  void deleteBySelection(BlockEditingSelection selection, NodePair pair) {
    assert(selection.latest.isCollapsed);

    // pair.trail = pair.trail.nodeContainsSpot(selection.old.extentOffset)!;

    _handleOperation(
      selection,
      pair,
    );
  }

  void insertBySelection(BlockEditingSelection selection, NodePair pair) {
    // pair.head = pair.head.nodeContainsSpot(
    //   selection.old.baseOffset,
    //   searchNext: false,
    // )!;

    _handleOperation(
      selection,
      pair,
      style: attachedToolbar?.style,
    );
  }

  /// by [NodePair.sanitize], we dereference its head and trail
  /// and keep the head [previous] and the trail [next] to restore and update the node chain
  void _handleOperation(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    final splitNodes = _splitFormatNodes(
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

  /// before chain all nodes together, we may need to align [next] to the end of the trail of [chained]
  /// because the entire range of [chained] may increase by insert or decrease by delete
  /// meanwhile, to
  void _chainNodes({
    FormatNode? previous,
    FormatNode? next,
    required List<FormatNode> splitNodes,
    required BlockEditingStatus operation,
  }) {
    assert(splitNodes.length >= 2);

    final chained = FormatNode.chain(splitNodes);

    // print('chained split nodes: $chained');

    if (next != null) {
      // ! next will base on the old previous node
      // ! must translateBase before chaining to the new node
      next.translateBase(chained.trail.range.end);
      chained.trail.chainNext(next);
    }

    if (chained.head.canAsHeadNode || previous == null) {
      headNode.unlink();
      headNode = chained.head;
    } else {
      previous.chainNext(chained.head);
    }

    if (headNode is HyperLinkNode && headNode.isInitNode) {
      // avoid the head node is an empty HyperLinkNode
      final formatNode = FormatNode.position(
        0,
        0,
        style: attachedToolbar?.style ?? defaultStyle,
      );
      formatNode.next = headNode.next;
      headNode.unlink();
      headNode = formatNode;
    }

    // print('headNode: $headNode');
  }

  List<FormatNode> _splitFormatNodes(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    final points = _calculateSplitPoints(selection);
    final int previousEnd = points[0];
    late final int nextStart = points[1];

    // ! set  as [late final] will have silence exception
    FormatNode? middle;
    late FormatNode previous;
    late FormatNode next;

    if (pair.head is HyperLinkNode &&
        pair.head.notStartAt(selection.old.baseOffset)) {
      final url = (pair.head as HyperLinkNode).url;
      previous = HyperLinkNode.position(pair.start, previousEnd, url: url);
    } else {
      previous = FormatNode.position(
        pair.start,
        previousEnd,
        style: pair.head.style,
      );
    }

    if (selection.status == BlockEditingStatus.select ||
        selection.status == BlockEditingStatus.insert) {
      middle = _createMiddleNode(
        selection,
        pair,
        style: style ?? pair.head.style,
        start: previousEnd,
        end: nextStart,
      );
    }

    if (pair.trail is HyperLinkNode &&
        pair.trail.notEndAt(selection.old.extentOffset)) {
      final url = (pair.head as HyperLinkNode).url;

      next = HyperLinkNode.position(nextStart, pair.end + selection.delta,
          url: url);
    } else {
      final nextStyle = pair.trail is! HyperLinkNode
          ? pair.trail.style
          : pair.trail.next?.style ?? headNode.style;
      next = FormatNode.position(
        nextStart,
        pair.end + selection.delta,
        style: nextStyle,
      );
    }

    if (middle != null) {
      return [previous, middle, next];
    } else {
      return [previous, next];
    }
  }

  List<int> _calculateSplitPoints(BlockEditingSelection selection) {
    late final int previousEnd;
    late final int nextStart;

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

    return [previousEnd, nextStart];
  }

  FormatNode? _createMiddleNode(
    BlockEditingSelection selection,
    NodePair pair, {
    required TextStyle style,
    required int start,
    required int end,
  }) {
    FormatNode? middle;

    if (attachedToolbar?.linkData != null ||
        pair.onSameLinkNode &&
            pair.trail.notEndAt(selection.old.extentOffset)) {
      final url =
          attachedToolbar?.linkData?.url ?? (pair.head as HyperLinkNode).url;
      middle = HyperLinkNode.position(start, end, url: url);
      attachedToolbar?.clearLinkData();
    } else {
      middle = FormatNode.position(start, end, style: style);
    }

    return middle;
  }
}
