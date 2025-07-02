import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_two/controller/AuthManager.dart';
import 'package:tic_tac_two/controller/FirebaseManager.dart';
import 'package:tic_tac_two/view/GameCard.dart';
import 'package:tic_tac_two/view/Menus/Pause.dart';
import 'package:window_manager/window_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseManager.initialize();

  await FirebaseManager.useEmulators(true);

  await FirebaseFirestore.instance.enableNetwork();

  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.setTitle('Tic Tac Two');
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
  State<TicTacTwo> createState() => AppScreen();
}

class AppScreen extends State<TicTacTwo> {
  late GameBoard board;

  String? firestoreValue;
  String? firebaseFunctionValue;

  @override
  void initState() {
    super.initState();
    board = GameBoard();
  }

  Future<String> getFirebaseValue() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference dr = db
        .collection("accounts")
        .doc("pY1Q5sD3qMTEeFHRm9ui");
    DocumentSnapshot ds = await dr.get();
    print("Doc exists: ${ds.exists}");
    print("Doc data: ${ds.data()}");

    String displayName = (ds.data() as Map<String, dynamic>)["display_name"];

    return await Future.value(displayName);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(firestoreValue ?? ""),
          MaterialButton(
            child: Text("Get Data"),
            onPressed: () {
              getFirebaseValue().then((b) {
                setState(() {
                  firestoreValue = b;
                });
              });
            },
          ),
          MaterialButton(
            child: Text("Sign in"),
            onPressed: () {
              AuthManager.useGoogleSignIn().then((e) {
                print(
                  "User after login: ${FirebaseAuth.instance.currentUser!.uid}",
                );
              });
            },
          ),
          MaterialButton(
            child: Text("Sign out"),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((e) {
                setState(() {
                  firestoreValue = "";
                });
              });
            },
          ),
        ],
      ),
    );
    // return SingleChildScrollView(child: GameBoard());
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  late final TicTacTwoGame game;

  @override
  void initState() {
    super.initState();
    game = TicTacTwoGame();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: MediaQuery.of(context).size.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 10, color: Colors.blue),
        ),
        child: GameWidget(
          game: game,
          overlayBuilderMap: {
            "pause": (context, game) => Center(child: Pause()),
          },
        ),
      ),
    );
  }
}

class TicTacTwoGame extends FlameGame with KeyboardEvents {
  late TextComponent textComp;

  @override
  FutureOr<void> onLoad() {
    add(GameCard(Vector2(100, 100), Vector2(100, 100), text: "X", id: 0));
    add(GameCard(Vector2(200, 100), Vector2(100, 100), text: "0", id: 0));
    add(GameCard(Vector2(300, 100), Vector2(100, 100), text: "X", id: 0));
    add(GameCard(Vector2(100, 200), Vector2(100, 100), text: "0", id: 0));
    add(GameCard(Vector2(200, 200), Vector2(100, 100), text: "X", id: 0));
    add(GameCard(Vector2(300, 200), Vector2(100, 100), text: "0", id: 0));

    textComp = TextComponent(text: "(Firebase value)", position: Vector2(0, 0));
    add(textComp);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (overlays.isActive('pause')) {
          overlays.remove('pause');
          resumeEngine();
        } else {
          overlays.add('pause');
          pauseEngine();
        }
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
