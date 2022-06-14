import '../models/parsed_node.dart';

class BlockDeserializer with DeserializerHelper {
  static final RegExp reg = RegExp(r"<[^>]*>", multiLine: true);

  BlockDeserializer();

  List<ParsedNode> parse(String source) {
    final List<ParsedNode> parsed = [];

    final matchedTags = reg.allMatches(source);

    final List<Match> stack = [];

    Match? previousMatched;

    ParsedNode? node;

    for (final match in matchedTags) {
      final tag = source.substring(match.start, match.end);

      if (stack.isEmpty && match.start > 0) {
        node = ParsedNode(
          source.substring(0, match.start),
          tags: const [],
        );
      } else if (stack.isNotEmpty) {
        final distance = calculateDistance(previousMatched!.end, match.start);

        if (distance > 0) {
          node = ParsedNode(
            source.substring(
              previousMatched.end,
              match.start,
            ),
            tags: getTags(source, stack),

            /// when the current [tag] is the right hyper link node
            /// we assert the previous tag is the left hyper link node
            /// so we will extract href/url from the previous tag
            url: isHyperLink(tag) ? _getUrl(source, previousMatched) : null,
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
        parsed.add(node);
        node = null;
      }
    }

    if (previousMatched!.end != source.length) {
      node = ParsedNode(source.substring(previousMatched.end), tags: const []);
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
