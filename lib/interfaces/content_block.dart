import 'package:flutter/material.dart';

abstract class ContentBlock extends StatefulWidget {
  const ContentBlock({
    Key? key,
  }) : super(key: key);
}

abstract class ContentBlockState<T extends ContentBlock> extends State<T> {}

abstract class BlockJsonConverter<T extends ContentBlock> {
  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}
