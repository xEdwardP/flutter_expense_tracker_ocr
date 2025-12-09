import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/resume_controller.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/colors.dart';
import 'package:flutter_expense_tracker_ocr/models/transaction.dart';
import 'package:intl/intl.dart';

class ResumePage extends StatelessWidget {
  ResumePage({super.key});
  final ResumeController controller = ResumeController();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
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
                        context: context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        label: "Gastos",
                        amount: totalExpense,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                        context: context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  "Transacciones recientes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? tWhiteColor : tDarkColor,
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

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 6),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "L. ${balance.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
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
    required BuildContext context,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? tWhiteColor : Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "L. ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
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
        title: Text(
          t.type == TransactionType.income ? "Ingreso" : "Gasto",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "${dateFormat.format(t.date)}${t.note != null && t.note!.isNotEmpty ? " - ${t.note}" : ""}",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Text(
          "L. ${t.amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: t.type == TransactionType.income ? Colors.green : Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
