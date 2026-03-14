class Transaction {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final DateTime date;
  final bool isPaid;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.description = '',
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
    };
  }
}
