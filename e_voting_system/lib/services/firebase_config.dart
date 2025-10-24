// services/firebase_config.dart
import 'package:e_voting_system/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// This will be generated

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}