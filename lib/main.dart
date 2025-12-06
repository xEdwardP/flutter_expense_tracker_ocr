import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/app.dart';
import 'package:flutter_expense_tracker_ocr/data/firebase_config.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/login_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/register_screen.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}
//mas cambios aqui animal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker OCR",
      
      initialRoute: "/login", 

      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterScreen(), 
        "/app": (context) => const MyApp(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}
