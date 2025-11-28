import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/views/pages/transaction_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.push(context,MaterialPageRoute(builder: (_) => TransactionsList()),);
        break;
      case 2:
        //Navigator.push(context,MaterialPageRoute(builder: (_) => const AddTransactionPage()),);
        break;
      case 3:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage()));
        break;
      case 4:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense Tracker OCR")),
      body: Center(
        child: Text(
          "Página seleccionada: $_selectedIndex",
          style: const TextStyle(fontSize: 20),
        ),
      ),
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
