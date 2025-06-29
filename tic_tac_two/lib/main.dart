import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.setTitle('Tic Tac Two');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Two',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Material(child: TicTacTwo(title: 'Tic Tac Two')),
    );
  }
}

class TicTacTwo extends StatefulWidget {
  const TicTacTwo({super.key, required this.title});

  final String title;

  @override
  State<TicTacTwo> createState() => MainGameLoop();
}

class MainGameLoop extends State<TicTacTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 10, color: Colors.blue),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: BoxBorder.all(width: 10, color: Colors.red),
        ),
        child: SingleChildScrollView(
          child: Column(children: [Text("Play"), Text("Rules"), Text("Exit")]),
        ),
      ),
    );
  }
}
