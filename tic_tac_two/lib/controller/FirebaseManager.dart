// ignore: file_names

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class Firebasemanager {
  static late FirebaseApp app;

  static Future<void> initialize() async {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
