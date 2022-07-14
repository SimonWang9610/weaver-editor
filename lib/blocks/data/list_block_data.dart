import 'package:flutter/material.dart';
import 'package:weaver_editor/models/types.dart';

import '../../base/block_data.dart';

class ListBlockData extends BlockData {
  final ListBlockStyle style;
  final List<String> items;

  ListBlockData({
    required String id,
    required String type,
    required this.style,
    List<String>? initItems,
  })  : items = initItems ?? [],
        super(id: id, type: type);

  bool applyTextChange(int index, String value) {
    if (items.length > index) {
      items[index] = value;
      return false;
    } else {
      items.add(value);
      return true;
    }
  }

  Widget getItemPrefix(int index) {
    switch (style) {
      case ListBlockStyle.ordered:
        return Text(
          '${index + 1}.',
          style: const TextStyle(fontSize: 28),
        );
      case ListBlockStyle.unordered:
        return const Text(
          '•',
          style: TextStyle(fontSize: 28),
        );
    }
  }

  Widget buildItem(int index) {
    final Widget orderWidget = getItemPrefix(index);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        orderWidget,
        Text(
          items[index],
          softWrap: true,
        ),
      ],
    );
  }

  @override
  Widget createPreview() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (_, index) => buildItem(index),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': {
        'style': style.style,
        'items': items,
      }
    };
  }
}
