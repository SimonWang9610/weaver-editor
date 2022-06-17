import 'package:flutter/material.dart';
import 'package:weaver_editor/models/nodes/format_node.dart';

import '../blocks/leaf_text_block.dart';
import '../toolbar/editor_toolbar.dart';
import '../models/editing_selection.dart';
import '../models/nodes/node_pair.dart';
import '../models/nodes/hyper_link_node.dart';
import '../models/types.dart';

class TextOperationDelegate<T extends TextBlockData>
    extends OperationDelegate<T> with TextOperationMixin {
  TextOperationDelegate(T data) : super(data: data);
}

mixin TextOperationMixin<T extends TextBlockData> on OperationDelegate<T> {
  void mergeStyle() {
    headNode.synchronize(headNode.style);
  }

  TextSpan build(String content) {
    data.text = content;
    return headNode.build(content);
  }

  bool transform(BlockEditingSelection selection) {
    if (!hasAttachedToolbar) return false;

    final pair = findNodesBySelection(selection);

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

    return pair.isMerged();
  }

  void updateBySelection(BlockEditingSelection selection, NodePair pair) {
    // ! do not apply style changes to same HyperLinkNode
    if (pair.onSameLinkNode) return;
    // ! if cursor at the end of HyperLinkNode, do not synchronize style
    if (selection.latest.isCollapsed) {
      if (pair.head is! HyperLinkNode) {
        synchronize(pair.head.style);
      } else {
        synchronize(pair.trail.next?.style ?? data.style);
      }
    }

    final activeStyle = effectiveStyle;

    if (activeStyle != pair.head.style &&
        !selection.latest.isCollapsed &&
        !toolbarSynchronized) {
      performOperation(
        selection,
        pair,
        style: activeStyle,
      );
    }
  }

  void deleteBySelection(BlockEditingSelection selection, NodePair pair) {
    assert(selection.latest.isCollapsed);

    performOperation(
      selection,
      pair,
    );
  }

  void insertBySelection(BlockEditingSelection selection, NodePair pair) {
    performOperation(
      selection,
      pair,
      style: effectiveStyle,
    );
  }
}

class OperationDelegate<T extends TextBlockData> with ToolbarBridge {
  final T data;

  OperationDelegate({
    required this.data,
  });

  TextStyle get defaultStyle => data.style;

  FormatNode get headNode => data.headNode!;
  set headNode(FormatNode value) => data.headNode = value;

  void dispose() {
    detach();
    headNode.dispose();
    data.dispose();
  }

  void performOperation(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    final splitNodes = splitFormatNodes(
      selection,
      pair,
      style: style,
    );

    pair.fuse();

    final sanitizedPair = pair.sanitize()!;

    chainNodes(
      splitNodes: splitNodes,
      previous: sanitizedPair.first,
      next: sanitizedPair.last,
      operation: selection.status,
    );
  }

  NodePair findNodesBySelection(BlockEditingSelection selection) {
    final pair = NodePair(headNode, trail: headNode);
    headNode.findNodePair(selection, pair);
    return pair;
  }

  List<FormatNode> splitFormatNodes(
    BlockEditingSelection selection,
    NodePair pair, {
    TextStyle? style,
  }) {
    final points = calculateSplitPoints(selection);
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
      middle = createMiddleNode(
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

  void chainNodes({
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
        style: attachedToolbar?.style ?? data.style,
      );
      formatNode.next = headNode.next;
      headNode.unlink();
      headNode = formatNode;
    }

    // print('headNode: $headNode');
  }

  FormatNode? createMiddleNode(
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

  List<int> calculateSplitPoints(BlockEditingSelection selection) {
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
}

mixin ToolbarBridge {
  EditorToolbar? attachedToolbar;

  bool get hasAttachedToolbar => attachedToolbar != null;

  bool get toolbarSynchronized =>
      hasAttachedToolbar && attachedToolbar!.synchronized;

  void performTaskAfterAttached() {
    attachedToolbar?.executeTaskAfterAttached();
  }

  void synchronize(TextStyle? style) {
    attachedToolbar?.synchronize(style);
  }

  void detach() => attachedToolbar = null;

  TextStyle get effectiveStyle => attachedToolbar!.style;
}
