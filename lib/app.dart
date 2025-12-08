import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/text_strings.dart';
import 'package:flutter_expense_tracker_ocr/core/utils/theme/theme.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/home_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/login_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/register_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/welcome_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      title: tAppName,
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      initialRoute: "/welcome",
      routes: {
        "/welcome": (context) => const WelcomePage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home": (context) => const HomePage(),
      },
    );
  }
}
