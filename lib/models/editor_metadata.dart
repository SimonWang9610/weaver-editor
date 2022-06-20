class EditorMetadata {
  final String title;
  final String? id;
  final Map<String, dynamic>? blocks;

  EditorMetadata({
    required this.title,
    this.blocks,
    this.id,
  });

  EditorMetadata copyWith({
    String? title,
    String? id,
    Map<String, dynamic>? data,
  }) {
    // !
    return EditorMetadata(
      title: title ?? this.title,
      id: this.id ?? id,
      blocks: data ?? blocks,
    );
  }
}
