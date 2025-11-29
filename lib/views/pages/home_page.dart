import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/add_transaction_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/profile_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/resume_page.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/transaction_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ResumePage(),
    const TransactionsList(),
    const AddTransactionPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Transacciones",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Agregar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
