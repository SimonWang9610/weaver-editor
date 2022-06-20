import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weaver_editor/core/editor_controller.dart';
import 'package:weaver_editor/models/types.dart';
import 'package:weaver_editor/components/animated_block_list.dart';
import 'package:weaver_editor/components/draggble_block_wrapper.dart';
import 'package:weaver_editor/widgets/editor_appbar.dart';
import 'package:weaver_editor/toolbar/widgets/toolbar_widget.dart';
import 'block_control_widget.dart';

import 'package:weaver_editor/editor.dart';

class EditorWidget extends StatefulWidget {
  const EditorWidget({Key? key}) : super(key: key);

  @override
  State<EditorWidget> createState() => _EditorWidgetState();
}

class _EditorWidgetState extends State<EditorWidget> {
  late final EditorController controller;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedBlockListState> _listKey =
      GlobalKey<AnimatedBlockListState>();

  late StreamSubscription<BlockOperationEvent> _sub;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ! before initState is completed, we cannot find the [WeaverEditorProvider]
    controller = WeaverEditorProvider.of(context, listen: true);
    _sub = controller.listen(_handleBlockChange);
  }

  void _handleBlockChange(BlockOperationEvent event) {
    _listKey.currentState?.animateTo(event.index, event.operation);

    controller.scrollToIndexIfNeeded(_scrollController, event.index);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('create editor: title: ${controller.data.title}');

    return WillPopScope(
      child: GestureDetector(
        child: Scaffold(
          appBar: EditorAppBar(
            title: Text(
              controller.data.title,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedBlockList(
                      key: _listKey,
                      scrollController: _scrollController,
                      initItemCount: controller.blocks.length,
                      separatedBuilder: (_, index) => BlockControlWidget(
                        index: index,
                      ),
                      itemBuilder: (_, index, animation) {
                        final block = controller.getBlockByIndex(index);

                        return FadeTransition(
                          key: ValueKey(block.id),
                          opacity: animation,
                          child: DragTargetWrapper(
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                  EditorToolbarWidget(
                    toolbar: controller.toolbar,
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          controller.manager.removeOverlay(
            playReverseAnimation: true,
          );
        },
      ),
      onWillPop: () async {
        // TODO: show dialog to prompt if saving unsaved changes
        return true;
      },
    );
  }
}
