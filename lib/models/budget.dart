class Budget {
  final int? id;
  final String category; // "OVERALL" for monthly budget
  final double amount;
  final int month; // 1-12
  final int year;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: map['amount'] as double,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  Budget copyWith({
    int? id,
    String? category,
    double? amount,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
