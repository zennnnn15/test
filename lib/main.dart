import 'loginscreen.dart';
import 'add.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Widget homeScreen;

    if (user != null) {
      homeScreen = MainScreen();
    } else {
      homeScreen = LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: homeScreen,
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
