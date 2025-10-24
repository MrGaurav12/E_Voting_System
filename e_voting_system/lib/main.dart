import 'package:e_voting_system/Screen/SignUpScreen.dart';
import 'package:e_voting_system/Screen/homepage.dart';
import 'package:e_voting_system/Screen/logingpage.dart';
import 'package:e_voting_system/firebase_options.dart';
import 'package:e_voting_system/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '🌳 Live Voting Machine 🌲',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/main': (context) => ElectionApp(),
        },
        home: LoginScreen(),
      ),
    );
  }
}
