import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../blocks/base_block.dart';

class Publication {
  final List<BaseBlock> blocks;
  final String id;
  final String title;
  Publication(
    this.id,
    this.title, {
    required this.blocks,
  });

  factory Publication.fromMap(Map<String, dynamic> map) {
    final String id = map['id'];
    final String title = map['title'];
    final Map<int, dynamic> content = json.decode(map['content']);

    final List<BaseBlock> blocks = [];

    for (final key in content.keys.toList()..sort()) {
      blocks.add(content[key]);
    }
    return Publication(id, title, blocks: blocks);
  }

  String get content {
    final Map<int, String> content = {};

    for (int i = 0; i < blocks.length; i++) {
      content[i] = json.encode(blocks[i].toMap());
    }
    return json.encode(content);
  }

  int get lastUpdate => DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'lastUpdate': lastUpdate,
      'content': content,
    };
  }
}

class EditorProvider {
  static const String editorTable = 'publications';
  static final EditorProvider _instance = EditorProvider._();

  EditorProvider._();

  factory EditorProvider() => _instance;

  late Database _db;

  Future<void> init(String path, {int version = 1}) async {
    _db = await openDatabase(
      path,
      version: version,
      onCreate: _createDatabase,
    );
  }

  Future<int> upsert(String id, String title, List<BaseBlock> blocks) async {
    final publication = Publication(
      id,
      title,
      blocks: blocks,
    );

    final updates = {
      'lastUpdate': publication.lastUpdate,
      'content': publication.content,
      'title': publication.title,
    };

    try {
      final updated = await _db.update(
        editorTable,
        updates,
        where: 'id = ?',
        whereArgs: [publication.id],
      );

      if (updated == 0) {
        updates['id'] = publication.id;

        return _db.insert(
          editorTable,
          updates,
        );
      } else {
        return updated;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      '''
        create table $editorTable (
          id text primary key,
          title text not null,
          lastUpdate numeric not null,
          content text not null
        )
      ''',
    );
  }
}
