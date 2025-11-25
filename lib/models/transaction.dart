enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String? note;
  final String? ticketPhotoUrl;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
    this.note,
    this.ticketPhotoUrl,
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      amount: (data['amount'] ?? 0).toDouble(),
      date: DateTime.parse(data['date']),
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: data['categoryId'] ?? '',
      note: data['note'],
      ticketPhotoUrl: data['ticketPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'note': note,
      'ticketPhotoUrl': ticketPhotoUrl,
    };
  }
}
