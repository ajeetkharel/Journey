import 'package:flutter/material.dart';
import 'package:journey/home.dart';
import 'package:journey/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required for async initialization
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MainApp(prefs: prefs));
}


class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8800)),
        useMaterial3: true,
      ),
      home: prefs.getString('userName') == null
          ? SignInPage(prefs: prefs)
          : Home(prefs: prefs),
    );
  }
}