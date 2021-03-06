import 'format_node.dart';
import 'hyper_link_node.dart';

class NodePair {
  FormatNode head;
  FormatNode trail;
  bool _paired;
  bool _merged = false;

  NodePair(
    this.head, {
    required this.trail,
    bool paired = false,
  }) : _paired = paired;

  void markAsPaired() => _paired = true;
  bool isPaired() => _paired;
  bool isMerged() => _merged;

  void fuse() {
    if (_merged) return;

    head.fuse(head, trail);
    _merged = true;
  }

  List<FormatNode?>? sanitize() {
    // if merged, it turns out some operations on this pair
    // the head should unlink its previous
    // the trail should unlink its next
    // avoiding memory leak
    if (_merged) {
      final previous = head.previous;
      final next = trail.next;

      head.previous = null;
      trail.next = null;
      previous?.next?.unlink();
      next?.previous?.unlink();
      return [previous, next];
    }
    return null;
  }

  int get start => head.range.start;

  int get end => trail.range.end;

  bool get collapsed => head == trail;

  bool get isValidPair => head.range.interval > 0 && trail.range.interval > 0;

  bool get onSameLinkNode =>
      head is HyperLinkNode && trail is HyperLinkNode && head == trail;

  bool get isEqual => head == trail;

  @override
  String toString() {
    return '${head.range} <--> ${trail.range}';
  }
}
