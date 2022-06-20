# weaver_editor

A minimum block-style rich text editor implementation.

# Design

### `WeaverEditor`
 - `WeaverEditor` will initialize from `EditorMetadata` which holds the `title`, `id` and `blocks` json data.
 - `EditorController


### Block Design

#### `BlockBase`

```mermaid
classDiagram
    BlockBase <|-- TextBlock
    BlockBase <|-- ImageBlock
    BlockBase <|-- VideoBlock
    BlockBase : +T data
    BlockBase : +BlockBuilder builder
    BlockBase : +Map json
    BlockBase : +Widget preview
    BlockBase: +build()
    class TextBlock {
        + TextBlockData data
        + BlockBuilder defaultTextBlockBuilder
        + static TextBlock create(id, style, map)
    }
    class ImageBlock {
        + ImageBlockData data
        + BlockBuilder defaultImageBlockBuilder
        + static ImageBlock create(id, map, embedData)
    }
    class VideoBlock {
        + VideoBlockData data
        + BlockBuilder defaultVideoBlockBuilder
        + static VideoBlock create(id, map, embedData)
    }
    TextBlock <|-- HeaderBlock
    class HeaderBlock {
        + HeaderBlockData data
        + BlockBuilder defaultHeaderBlockBuilder
        + static HeaderBlock create(id, style, map)
    }
```

### `BlockBuilder`: `Widget Function(T data)`

```mermaid
classDiagram
    StatelessBlock <|-- ImageBlockWidget
    StatelessBlock : + T data
    class ImageBlockWidget {
        + ImageBlockData data
        + Widget build(context)
    }
    StatefulBlock <|-- TextBlockWidget
    StatefulBlock <|-- VideoBlockWidget
    StatefulBlock : +T data
    class VideoBlockWidget {
        + VideoBlockData data
        + Widget build(context)
    }
    class TextBlockWidget {
        + String hintText
        + TextBlockData data
        + Widget build(context)
    }
    TextBlockWidget <|-- HeaderBlockWidget
    class HeaderBlockWidget {
        + String hintText
        + HeaderBlockData data
        + Widget build(context)
    }
```

### `BlockData`
```mermaid
classDiagram
    BlockData <|-- ImageBlockData
    BlockData <|-- VideoBlockData
    BlockData <|-- TextBlockData
    BlockData : + String id
    BlockData : + String type
    BlockData: +createPreview()
    BlockData: +toMap()
    class ImageBlockData {
          + String? imageUrl
          + String? imagePath
        + String? caption
    }
    class VideoBlockData {
          + String? videoUrl
        + String? videoPath
        + String? caption
    }
    class TextBlockData {
            + TextStyle style
            + TextAlign align
            + FormatNode? headNode
            + String text
    }
    TextBlockData <|-- HeaderBlockData
    class HeaderBlockData {
        + HeaderLine level
    }
```

### Editable Block State
- `controller` will perform operations by `delegate` before rendering its text
```mermaid
classDiagram
    BlockState <|-- TextBlockState
    BlockState : T data
    class TextBlockState {
        + BlockEditingController controller
        + TextOperationDelegate delegate
        + FocusNode focus
    }
    TextBlockState <|-- HeaderBlockState
    class HeaderBlockState {

    }
    TextEditingController <|-- BlockEditingController
    class BlockEditingController {
        + TextOperationDelegate delegate
        + FocusNode focus
        + TextSpan buildTextSpan(...)
        + set value(newValue)
        + detach()
        + insertLinkNode(data)
    }
```
- `TextOperationMixin` will compose methods of `OperationDelegate` and expose the interfaces to `controller`

```mermaid
classDiagram
    OperationDelegate <|-- TextOperationDelegate
    OperationDelegate : +T data
    OperationDelegate: +performOperation(selection, pair, style)
    OperationDelegate: +findNodesBySelection(selection)
    OperationDelegate: +splitFormatNodes(selection, pair, style)
    OperationDelegate: +chainNodes(preview, next, splitNodes, operation)
    OperationDelegate: +createMiddleNode(selection, pair, style, start, end)
    OperationDelegate: +calculateSplitPoints(selection)
    TextOperationMixin *-- TextOperationDelegate
    TextOperationMixin: +build(text)
    TextOperationMixin: +perform(selection)
    TextOperationMixin: +updateBySelection(selection)
    TextOperationMixin: +deleteBySelection(selection)
    TextOperationMixin: +insertBySelection(selection)
    OperationDelegate .. TextOperationMixin
```

### how `BlockEditingController` build text spans with different text style by `TextOperationDelegate`
```mermaid
sequenceDiagram
    controller->delegate: apply different styles to text value and build widgets
    loop every set new text value
        controller-->>controller: set [newValue]
        controller-->>delegate: call perform(selection)
        delegate-->>delegate: findNodePair(selection)
        opt update
            delegate-->>delegate: updateBySelection(selection)
        end
        opt delete
            delegate-->>delegate: deleteBySelection(selection)
        end
        opt insert
            delegate-->>delegate: insertBySelection(selection)
        end
        delegate->>OperationDelegate: performOperation(selection, pair)
        OperationDelegate-->>OperationDelegate: splitFormatNodes(selection, pair)
        OperationDelegate-->>OperationDelegate: chainNodes(splitNodes)
        OperationDelegate-->>TextBlockData:  set/update [headNode]

        delegate-->>controller: I have split nodes with different styles for the given text
        controller-->>controller: super.value = newValue
        controller-->>controller: buildTextSpan(...)
        controller-->>delegate: call build(text)
        delegate-->>TextBlockData: set new [text]
        delegate-->>TextBlockData: headNode.build(text)
        delegate-->>controller: return the built widgets
    end
```

### how `EditorController` responds to user operations?
```mermaid
sequenceDiagram
    user->controller: perform operations
    loop every tap block control button
        user-->>controller: choose create/manage overlay
        controller-->>manager: create overlay
        manager-->>user: insert(overlay)
        user-->>manager: create/delete/move/drag
        manager-->>controller: insert/move/remove blocks
        opt insert block
            controller-->>factory: create(type)
            factory-->>controller: return a new block
        end
        opt move/remove block
            controller-->>BlockManageDelegate: perform operations
            BlockManageDelegate-->>controller: update [blocks]
        end
        controller-->>user: notify block operation completed
    end



