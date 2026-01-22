class CategoryTotal {
  final String category;
  final double total;

  CategoryTotal({
    required this.category,
    required this.total,
  });

  factory CategoryTotal.fromMap(Map<String, dynamic> map) {
    return CategoryTotal(
      category: map['category'] as String,
      total: map['total'] as double,
    );
  }
}

class DailyTotal {
  final DateTime date;
  final double total;

  DailyTotal({
    required this.date,
    required this.total,
  });

  factory DailyTotal.fromMap(Map<String, dynamic> map) {
    return DailyTotal(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      total: map['total'] as double,
    );
  }
}
