enum TransactionType {
  income,
  expense
}

class Transaction{
  final String id;
  final String category;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;

  Transaction({ required this.id, required this.category, required this.amount, this.description = '', required this.type, required this.date});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'date': date.toIso8601String()
    };
  }
}