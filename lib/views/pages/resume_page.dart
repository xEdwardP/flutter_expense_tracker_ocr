import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_expense_tracker_ocr/models/transaction.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  Stream<List<TransactionModel>> getTransactionsStream() {
    return FirebaseFirestore.instance
        .collection('transactions')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => TransactionModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              "Inicio",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),

      body: StreamBuilder<List<TransactionModel>>(
        stream: getTransactionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;

          final now = DateTime.now();

          double totalIncome = transactions
              .where(
                (t) =>
                    t.type == TransactionType.income &&
                    t.date.month == now.month &&
                    t.date.year == now.year,
              )
              .fold(0, (s, t) => s + t.amount);

          double totalExpense = transactions
              .where(
                (t) =>
                    t.type == TransactionType.expense &&
                    t.date.month == now.month &&
                    t.date.year == now.year,
              )
              .fold(0, (s, t) => s + t.amount);

          final balance = totalIncome - totalExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFF8E7CF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black26,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Balance del mes",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "\$${balance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        label: "Ingresos",
                        amount: totalIncome,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        label: "Gastos",
                        amount: totalExpense,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Transacciones recientes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                ...transactions.take(5).map((t) => _buildTransactionItem(t)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: color, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: t.type == TransactionType.income
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            child: Icon(
              t.type == TransactionType.income
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: t.type == TransactionType.income
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t.type == TransactionType.income ? "Ingreso" : "Gasto",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            "\$${t.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: t.type == TransactionType.income
                  ? Colors.green
                  : Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
