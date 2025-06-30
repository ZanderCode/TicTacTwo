import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseManager {
  static late FirebaseApp app;

  static Future<void> initialize() async {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<Map<String, int>> getEmulatorPorts() async {
    final file = File('firebase.json');
    final contents = await file.readAsString();
    final jsonData = jsonDecode(contents);

    final emulators = jsonData['emulators'] as Map<String, dynamic>;

    final ports = <String, int>{};
    for (var entry in emulators.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic> && value.containsKey('port')) {
        ports[entry.key] = value['port'];
      }
    }

    return ports;
  }
}
