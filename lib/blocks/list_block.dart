import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';

import '../base/block_base.dart';
import '../extensions/list_type_ext.dart';
import 'data/list_block_data.dart';

typedef IndexedTextChanged = void Function(int, String);

Widget defaultListBlockBuilder(ListBlockData data) => ListBlockWidget(
      key: ValueKey(data.id),
      data: data,
    );

class ListBlock extends BlockBase<ListBlockData> {
  ListBlock({
    required ListBlockData data,
    BlockBuilder? builder,
  }) : super(data: data, builder: builder ?? defaultListBlockBuilder);

  static create(String id, {Map<String, dynamic>? map}) {
    final String? style = map?['style'];
    final List<String>? items = map?['items'];

    return ListBlock(
      data: ListBlockData(
        id: id,
        type: 'list',
        style: style?.toListStyle() ?? ListBlockStyle.unordered,
        initItems: items,
      ),
    );
  }
}

class ListBlockWidget extends StatefulBlock<ListBlockData> {
  const ListBlockWidget({
    Key? key,
    required ListBlockData data,
  }) : super(key: key, data: data);

  @override
  ListBlockWidgetState createState() => ListBlockWidgetState();
}

class ListBlockWidgetState extends BlockState<ListBlockData, ListBlockWidget> {
  void applyTextChange(int index, String value) {
    final itemInserted = widget.data.applyTextChange(index, value);
    if (mounted && itemInserted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.items.length + 1,
      itemBuilder: (_, index) => ListItemWidget(
        index: index,
        prefix: data.getItemPrefix(index),
        applyTextChange: applyTextChange,
      ),
    );
  }
}

class ListItemWidget extends StatefulWidget {
  final int index;
  final Widget prefix;
  final IndexedTextChanged applyTextChange;
  const ListItemWidget({
    Key? key,
    required this.index,
    required this.prefix,
    required this.applyTextChange,
  }) : super(key: key);

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focus.requestFocus();
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = Theme.of(context).iconTheme.size ?? 24;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: iconSize * 2,
          child: Center(
            child: widget.prefix,
          ),
        ),
        Expanded(
          child: TextField(
            // enabled: true,
            strutStyle: StrutStyle.disabled,
            decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: const BorderSide(
                  color: Colors.white38,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide.none,
              ),
            ),
            controller: controller,
            focusNode: focus,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              widget.applyTextChange(widget.index, value);
            },
            maxLines: null,
          ),
        ),
      ],
    );
  }
}
