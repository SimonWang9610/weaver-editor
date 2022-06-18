import 'package:flutter/material.dart';
import 'package:weaver_editor/editor.dart';
import 'package:weaver_editor/models/types.dart';

typedef AnimatedItemBuilder = Widget Function(
    BuildContext context, int index, Animation<double>);

typedef SeparatorBuilder = Widget Function(BuildContext context, int index);

/// TODO: handle didUpdateWidget

class AnimatedBlockList extends StatefulWidget {
  final int initItemCount;

  /// if true, the list will start from a separator, and items will always at even index
  /// if false, the list will start from an item, and items will always at even index
  final bool startWithSeparator;
  final Duration? duration;
  final Animatable<double>? animation;
  final AnimatedItemBuilder itemBuilder;
  final SeparatorBuilder separatedBuilder;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final Clip clipBehavior;
  const AnimatedBlockList({
    Key? key,
    required this.initItemCount,
    required this.itemBuilder,
    required this.separatedBuilder,
    this.startWithSeparator = true,
    this.duration,
    this.animation,
    this.scrollController,
    this.clipBehavior = Clip.hardEdge,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  State<AnimatedBlockList> createState() => AnimatedBlockListState();
}

class AnimatedBlockListState extends State<AnimatedBlockList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _itemIndexEven;

  late int _itemCount;
  // the first build will not play animation
  // so [_activeItemIndex] should be null
  int? _activeItemIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ??
          const Duration(
            milliseconds: 300,
          ),
    );

    _itemCount = widget.initItemCount;
    _itemIndexEven = !widget.startWithSeparator;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      clipBehavior: widget.clipBehavior,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverList(
          delegate: _createDelegate(),
        ),
      ],
    );
  }

  SliverChildDelegate _createDelegate() {
    return SliverChildBuilderDelegate(
      _builderWithSeparator,
      childCount: 2 * _itemCount + 1,
      findChildIndexCallback: _findChildIndex,
    );
  }

  void animateTo(int index, BlockOperation operation) {
    switch (operation) {
      case BlockOperation.insert:
        _itemCount++;
        break;
      case BlockOperation.remove:
        _itemCount--;
        break;
      default:
        break;
    }
    _activeItemIndex = index;
    _controller.reset();
    setState(() {
      _controller.forward().then((_) => _activeItemIndex = null);
    });
  }

  // find the index of existed block so as to reuse elements
  int? _findChildIndex(Key key) {
    if (key is ValueKey<String>) {
      final id = key.value;

      final index = EditorController.of(context).getBlockIndex(id);
      final effectiveIndex = _itemIndexEven ? index * 2 : index * 2 + 1;
      return index > -1 ? effectiveIndex : null;
    }
    return null;
  }

  Widget _itemBuilder(BuildContext context, int effectiveIndex) {
    final animation = _createAnimation(effectiveIndex);

    return widget.itemBuilder(
      context,
      effectiveIndex,
      animation,
    );
  }

  // ! must restore as effective index
  /// the total widgets in this list should be all items and separators
  /// [itemIndex] will represent one of the total widgets
  /// because each item is attached to a separator
  /// so the effective index should be half of [itemIndex] and same between items and separator
  Widget _builderWithSeparator(BuildContext context, int itemIndex) {
    final effectiveIndex = itemIndex ~/ 2;

    if (_itemIndexEven) {
      return itemIndex.isEven
          ? _itemBuilder(context, effectiveIndex)
          : widget.separatedBuilder(context, effectiveIndex);
    } else {
      return itemIndex.isOdd
          ? _itemBuilder(context, effectiveIndex)
          : widget.separatedBuilder(context, effectiveIndex);
    }
  }

  Animation<double> _createAnimation(int itemIndex) {
    if (_activeItemIndex == itemIndex) {
      return widget.animation?.animate(_controller) ??
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInCubic,
          );
    } else {
      return AlwaysStoppedAnimation<double>(_controller.upperBound);
    }
  }
}
