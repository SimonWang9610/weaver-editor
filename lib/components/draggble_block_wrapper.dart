// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:weaver_editor/editor.dart';
// import 'package:weaver_editor/models/types.dart';

// class DraggableBlockWrapper extends StatefulWidget {
//   final int index;
//   const DraggableBlockWrapper({
//     Key? key,
//     required this.index,
//   }) : super(key: key);

//   @override
//   State<DraggableBlockWrapper> createState() => _DraggableBlockWrapperState();
// }

// class _DraggableBlockWrapperState extends State<DraggableBlockWrapper> {
//   late StreamSubscription<BlockListEvent> _sub;
//   late String currentBlockId;

//   @override
//   void initState() {
//     super.initState();
//     currentBlockId =
//         EditorBlockProvider.of(context).getBlockIdByIndex(widget.index);
//     _sub = EditorBlockProvider.of(context).listen(_handleBlockReorder);
//   }

//   void _handleBlockReorder(BlockListEvent event) {
//     if (event == BlockListEvent.reorder) {
//       final blockId =
//           EditorBlockProvider.of(context).getBlockIdByIndex(widget.index);
//       if (currentBlockId != blockId) {
//         setState(() {});
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(covariant DraggableBlockWrapper oldWidget) {
//     if (widget.index != oldWidget.index) {
//       // _sub is not related to widget
//       // so no need to cancel and listen again
//       _sub.cancel();
//       currentBlockId =
//           EditorBlockProvider.of(context).getBlockIdByIndex(widget.index);
//       _sub = EditorBlockProvider.of(context).listen(_handleBlockReorder);
//       super.didUpdateWidget(oldWidget);
//     }
//   }

//   @override
//   void dispose() {
//     _sub.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DragTarget<String>(
//         builder: (_, __, ___) => Draggable(
//               data: currentBlockId,
//               child: block,
//               feedback: block,
//             ),
//         onWillAccept: (incomingId) {
//           return incomingId != null && incomingId != currentBlockId;
//         },
//         onAcceptWithDetails: (details) {
//           final dragOffset = details.offset;

//           final blockBox = context.findRenderObject() as RenderBox;

//           final blockRect = blockBox.paintBounds;

//           if (blockRect.contains(dragOffset)) {
//             // move the block to the specific index;
//             EditorBlockProvider.of(context).reorder(
//               details.data,
//               widget.index,
//             );
//             // synchronize the currentBlockId with the index
//             currentBlockId = details.data;
//             setState(() {});
//           }
//         });
//   }

//   Widget get block =>
//       EditorBlockProvider.of(context).findBlockByIndex(widget.index) as Widget;
// }
