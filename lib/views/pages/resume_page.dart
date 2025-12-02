import 'package:flutter/material.dart';
import '../../controllers/resume_controller.dart';
import '../../models/transaction.dart';
import 'package:intl/intl.dart';

class ResumePage extends StatelessWidget {
  ResumePage({super.key});

  final ResumeController controller = ResumeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Inicio",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: controller.getTransactionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;
          final totalIncome = controller.getTotalIncome(transactions);
          final totalExpense = controller.getTotalExpense(transactions);
          final balance = totalIncome - totalExpense;
          final lastNotes = controller.getLastNotes(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(balance),
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
                const SizedBox(height: 20),
                if (lastNotes.isNotEmpty)
                  _buildLastNotesSection(lastNotes),
                const SizedBox(height: 30),
                const Text(
                  "Transacciones recientes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...transactions.take(5).map(_buildTransactionItem),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF8E7CF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
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

  Widget _buildLastNotesSection(List<TransactionModel> lastNotes) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notas recientes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...lastNotes.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "${dateFormat.format(t.date)}: ${t.note}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            )),
      ],
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
              color: t.type == TransactionType.income ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "${t.type == TransactionType.income ? "Ingreso" : "Gasto"}",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            "\$${t.amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: t.type == TransactionType.income ? Colors.green : Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
