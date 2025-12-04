enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? note;
  final String? ticketPhotoUrl;
  final String userId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
    this.ticketPhotoUrl,
    required this.userId,
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
      note: data['note'],
      ticketPhotoUrl: data['ticketPhotoUrl'],
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'ticketPhotoUrl': ticketPhotoUrl,
      'userId': userId,
    };
  }
}
