import 'package:flutter/material.dart';
import 'package:weaver_editor/publications/publication_screen.dart';
import 'package:weaver_editor/storage/editor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EditorProvider().init();

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
      home: const PublicationScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PublicationScreen();
  }
}
