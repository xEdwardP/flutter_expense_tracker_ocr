import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/add_transaction_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/home_page.dart';
import 'package:flutter_expense_tracker_ocr/views/theme/theme.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker OCR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: HomePage(),
    );
  }
}
