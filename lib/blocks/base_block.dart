import 'package:flutter/material.dart';

abstract class BaseBlock {}

abstract class StatefulBlock extends StatefulWidget implements BaseBlock {
  const StatefulBlock({
    Key? key,
  }) : super(key: key);
}

abstract class BlockState<T extends StatefulBlock> extends State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
}

abstract class StatelessBlock extends StatelessWidget implements BaseBlock {
  const StatelessBlock({Key? key}) : super(key: key);
}

abstract class BlockJsonConverter<T extends BaseBlock> {
  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}
