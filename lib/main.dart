import 'package:flutter/material.dart';
import 'package:weaver_editor/interfaces/editor.dart';
import 'package:weaver_editor/interfaces/editor_toolbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall ?? const TextStyle();

    return WeaverEditor(
      toolbar: EditorToolbar(style),
    );
  }
}
