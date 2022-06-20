import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_base.dart';
import 'package:weaver_editor/extensions/headerline_ext.dart';
import 'package:weaver_editor/utils/helper.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/core/nodes/format_node.dart';
import 'data/header_block_data.dart';
import 'text_block.dart';

Widget defaultHeaderBlockBuilder(HeaderBlockData data) => HeaderBlockWidget(
      key: ValueKey(data.id),
      data: data,
    );

class HeaderBlock extends BlockBase<HeaderBlockData> {
  HeaderBlock({
    required HeaderBlockData data,
    BlockBuilder? builder,
  }) : super(
          data: data,
          builder: builder ?? defaultHeaderBlockBuilder,
        );

  /// currently, [HeaderBlock] has a specific [TextStyle] and cannot be changed by [EditorToolbar]
  static HeaderBlock create(
    String id, {
    required TextStyle defaultStyle,
    Map<String, dynamic>? map,
  }) {
    final String? align = map?['alignment'];
    final num? level = map?['level'];

    final TextStyle style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: level?.levelHeaderLine().size ?? HeaderLine.level1.size,
    );

    final FormatNode? headNode = map != null
        ? FormatNode.position(
            0,
            0,
            style: style,
          )
        : null;

    final String text = extractText(map?['text'], headNode);

    return HeaderBlock(
      data: HeaderBlockData(
        id: id,
        text: text,
        align: align?.toTextAlign() ?? TextAlign.center,
        style: style,
        headNode: headNode,
      ),
    );
  }
}

/// Apart from [data] type, [HeaderBlockWidget] also has a different [hintText] compared to [TextBlockWidget]
class HeaderBlockWidget extends TextBlockWidget<HeaderBlockData> {
  const HeaderBlockWidget({
    Key? key,
    String hintText = 'Add Header',
    required HeaderBlockData data,
  }) : super(
          key: key,
          hintText: hintText,
          data: data,
        );
}
