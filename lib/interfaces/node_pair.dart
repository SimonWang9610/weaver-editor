import 'format_node.dart';

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

  void merge() {
    if (_merged) return;

    head.merge(head, trail);
    _merged = true;
  }

  void unpair() {
    // if merged, it turns out some operations on this pair
    // the head should unlink its previous
    // the trail should unlink its next
    // avoiding memory leak
    if (_merged) {
      head.previous = null;
      trail.next = null;
    }
  }

  int get start => head.range.start;

  int get end => trail.range.end;
}
