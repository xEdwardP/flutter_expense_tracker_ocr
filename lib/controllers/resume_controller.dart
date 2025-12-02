import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction.dart';

class ResumeController {
  /// Stream de transacciones del mes actual, limitado a `limit` documentos
  Stream<List<TransactionModel>> getTransactionsStream({int limit = 50}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => TransactionModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }


  double getTotalIncome(List<TransactionModel> transactions) {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0, (s, t) => s + t.amount);
  }

  double getTotalExpense(List<TransactionModel> transactions) {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0, (s, t) => s + t.amount);
  }


    List<TransactionModel> getLastNotes(List<TransactionModel> transactions, {int limit = 5}) {
    final withNotes = transactions.where((t) => t.note != null && t.note!.isNotEmpty).toList();
    withNotes.sort((a, b) => b.date.compareTo(a.date)); // Orden descendente por fecha
    return withNotes.take(limit).toList();
  }
}
