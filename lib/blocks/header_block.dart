import 'package:flutter/material.dart';
import 'package:weaver_editor/base/block_base.dart';

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
}

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
