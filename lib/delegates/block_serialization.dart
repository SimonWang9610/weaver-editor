import '../models/nodes/parsed_node.dart';

class BlockDeserializer with DeserializerHelper {
  static final RegExp reg = RegExp(r"<[^>]*>", multiLine: true);

  BlockDeserializer();

  /// find all tags by [reg]
  /// use [stack] to record left tags not consumed by its right tag
  /// [previousMatched] to record the last tag which is either put in [stack] or used to consume the left tag
  /// meanwhile, we will calculate [anchor] to determine if we need creating a new [ParsedNode]
  /// if tag is [isHyperLink], we also extract [url] by [_getUrl]
  /// finally, we may create the last [ParsedNode] based on [previousMatched]
  List<ParsedNode> parse(String source) {
    final List<ParsedNode> parsed = [];

    final matchedTags = reg.allMatches(source);

    final List<Match> stack = [];

    Match? previousMatched;

    ParsedNode? node;

    for (final match in matchedTags) {
      final tag = source.substring(match.start, match.end);

      final anchor = previousMatched?.end ?? 0;

      if (stack.isEmpty && match.start > anchor) {
        node = ParsedNode(
          source.substring(anchor, match.start),
          tags: const [],
        );
      } else if (stack.isNotEmpty) {
        final distance = calculateDistance(anchor, match.start);

        if (distance > 0) {
          node = ParsedNode(
            source.substring(
              anchor,
              match.start,
            ),
            tags: getTags(source, stack),

            /// when the current [tag] is the right hyper link node
            /// we assert the previous tag is the left hyper link node
            /// so we will extract href/url from the previous tag
            url: isHyperLink(tag) ? _getUrl(source, previousMatched!) : null,
          );
        }
      }

      if (isLeftTag(tag)) {
        stack.add(match);
      } else {
        assert(isClosed(source, stack.last, match));
        stack.removeLast();
      }

      previousMatched = match;

      if (node != null) {
        print('node: $node');
        parsed.add(node);
        node = null;
      }
    }

    if (previousMatched == null || previousMatched.end != source.length) {
      node = ParsedNode(
        source.substring(previousMatched?.end ?? 0),
        tags: const [],
      );

      parsed.add(node);
    }

    assert(stack.isEmpty);

    return parsed;
  }
}

mixin DeserializerHelper {
  String? _getUrl(String source, Match tag) {
    final linkTag = source.substring(tag.start, tag.end);
    final hrefReg = RegExp(r"href=(['" '"])(.*?)\\1');
    final matched = hrefReg.firstMatch(linkTag);
    if (matched != null) {
      final href = linkTag.substring(matched.start, matched.end);
      final matchedUrl = RegExp(r'"(.*?)"').firstMatch(href);
      return href.substring(matchedUrl!.start + 1, matchedUrl.end - 1);
    }
    return null;
  }

  int calculateDistance(int previousEnd, int nextStart) {
    return nextStart - previousEnd;
  }

  List<String> getTags(String source, List<Match> stack) {
    final List<String> result = [];

    for (final match in stack) {
      result.add(source.substring(match.start, match.end));
    }
    return result;
  }

  bool isClosed(String source, Match previous, Match incoming) {
    final leftTag = source.substring(previous.start, previous.end);
    final incomingTag = source.substring(incoming.start, incoming.end);

    return incomingTag[1] == '/' && leftTag[1] == incomingTag[2];
  }

  bool isLeftTag(String tag) {
    assert(tag[0] == '<');
    return tag[1] != '/';
  }

  bool isHyperLink(String tag) {
    return tag == '</a>';
  }
}
