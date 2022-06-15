import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weaver_editor/blocks/block_factory.dart';

import '../blocks/base_block.dart';

typedef BlockData = Map<String, dynamic>;

class Publication {
  final List<BaseBlock> blocks;
  final BlockData blockData;
  final String id;
  final String title;
  final int lastUpdate;
  Publication(
    this.id,
    this.title, {
    this.blocks = const [],
    this.blockData = const {},
    required this.lastUpdate,
  });

  factory Publication.fromMap(Map<String, dynamic> map) {
    final String id = map['id'];
    final String title = map['title'];
    final Map<String, dynamic> content = jsonDecode(map['content']);

    // print(content);

    return Publication(
      id,
      title,
      lastUpdate: map['lastUpdate'],
      blockData: content,
    );

    // final List<BaseBlock> blocks = List.generate(
    //   content.length,
    //   (index) {
    //     final block = content['$index'];

    //     return BlockFactory().fromMap(block);
    //   },
    // );

    // return Publication(
    //   id,
    //   title,
    //   blocks: blocks,
    //   lastUpdate: map['lastUpdate'],
    // );
  }

  String get content {
    final Map<String, dynamic> content = {};

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i].toMap();
      content['$i'] = block;
    }
    print(content);
    return jsonEncode(content);
  }

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
  static const String dbName = 'publications.db';
  static const String editorTable = 'publications';
  static final EditorProvider _instance = EditorProvider._();

  EditorProvider._();

  factory EditorProvider() => _instance;

  late Database _db;

  Future<void> init({int version = 1}) async {
    final path = await getDatabasesPath();

    _db = await openDatabase(
      join(path, dbName),
      version: version,
      onCreate: _createDatabase,
    );
  }

  Future<int> save(String id, String title, List<BaseBlock> blocks) async {
    final publication = Publication(
      id,
      title,
      blocks: blocks,
      lastUpdate: DateTime.now().millisecondsSinceEpoch,
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
      throw ErrorDescription('Error on upserts: $e');
    }
  }

  Future<int> clearAllPublications() async {
    final result = await _db.delete(
      editorTable,
    );
    return result;
  }

  Future<List<Publication>> getAllPublications(int offset,
      [int limit = 10]) async {
    final List<Publication> publications = [];

    final results = await _db.query(
      editorTable,
      orderBy: 'lastUpdate DESC',
      limit: limit,
      offset: offset,
    );

    for (final map in results) {
      publications.add(Publication.fromMap(map));
    }

    return publications;
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
