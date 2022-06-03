import 'package:flutter/material.dart';

abstract class BaseBlock {
  String get id;
}

abstract class StatefulBlock extends StatefulWidget implements BaseBlock {
  @override
  final String id;
  const StatefulBlock({
    Key? key,
    required this.id,
  }) : super(key: key);
}

abstract class BlockState<T extends StatefulBlock> extends State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}

abstract class StatelessBlock extends StatelessWidget implements BaseBlock {
  @override
  final String id;
  const StatelessBlock({
    Key? key,
    required this.id,
  }) : super(key: key);
}

abstract class BlockJsonConverter<T extends BaseBlock> {
  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}
