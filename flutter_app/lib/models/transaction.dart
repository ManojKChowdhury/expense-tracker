enum TransactionType {
  income,
  expense,
}

class Transaction {
  final int? id;
  final double amount;
  final String category;
  final TransactionType type;
  final String paymentMethod;
  final DateTime date;
  final String notes;
  final String? receiptPhotoUri;

  Transaction({
    this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.paymentMethod,
    required this.date,
    this.notes = '',
    this.receiptPhotoUri,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': type == TransactionType.income ? 'INCOME' : 'EXPENSE',
      'paymentMethod': paymentMethod,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'receiptPhotoUri': receiptPhotoUri,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      category: map['category'] as String,
      type: map['type'] == 'INCOME' ? TransactionType.income : TransactionType.expense,
      paymentMethod: map['paymentMethod'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String? ?? '',
      receiptPhotoUri: map['receiptPhotoUri'] as String?,
    );
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? category,
    TransactionType? type,
    String? paymentMethod,
    DateTime? date,
    String? notes,
    String? receiptPhotoUri,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receiptPhotoUri: receiptPhotoUri ?? this.receiptPhotoUri,
    );
  }
}
