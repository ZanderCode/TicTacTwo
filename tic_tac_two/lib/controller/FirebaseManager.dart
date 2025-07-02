import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../firebase_options.dart';

class FirebaseManager {
  static late FirebaseApp app;

  static Future<void> initialize() async {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> useEmulators(bool useEnumulators) async {
    if (useEnumulators) {
      Map<String, int> ports = await FirebaseManager.getEmulatorPorts();

      FirebaseFirestore.instance.useFirestoreEmulator(
        'localhost',
        ports["firestore"] ?? 8000,
      );
      FirebaseFunctions.instance.useFunctionsEmulator(
        'localhost',
        ports["functions"] ?? 5001,
      );
      FirebaseAuth.instance.useAuthEmulator('localhost', ports["auth"] ?? 9099);
    }
  }

  static Future<Map<String, int>> getEmulatorPorts() async {
    if (kIsWeb) {
      final ports = <String, int>{};
      ports.putIfAbsent("firestore", () => 8000);
      ports.putIfAbsent("functions", () => 5001);
      ports.putIfAbsent("auth", () => 9099);

      return ports;
    }

    //final file = File('firebase.json');
    final contents = await getFirebaseJSON(); //await file.readAsString();
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

  static Future<String> getFirebaseJSON() async {
    return await rootBundle.loadString('firebase.json');
  }
}
