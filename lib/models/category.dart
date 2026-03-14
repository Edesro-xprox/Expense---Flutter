import 'package:expense_managment/models/transaction.dart';

enum CategoryType{
  income,
  expense
}

class Category {
  final String id;
  final String name;
  final CategoryType type;

  Category({required this.id, required this.name, required this.type});

  Map<String, dynamic> toMapCategory() {
    return {
      'id': id,
      'name': name,
      'type': type == CategoryType.income ? 'income' : 'expense',
    };
  }
}
