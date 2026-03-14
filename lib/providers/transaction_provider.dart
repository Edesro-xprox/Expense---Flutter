import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/services/database_helper.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier{
  List<Transaction> _transactions = [];
  List<Category> _categories = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _dbHelper.getCategories();
    notifyListeners();
  }

  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;

  String totalIncome() {
    return _transactions
      .where((t) => categories.where((c) => c.type == CategoryType.income).map((c) => c.id).contains(t.categoryId))
      .fold(0.00, (sum, t) => sum + t.amount).toStringAsFixed(2);
  }

  String totalExpense() {
    return _transactions
      .where((t) => categories.where((c) => c.type == CategoryType.expense).map((c) => c.id).contains(t.categoryId))
      .fold(0.00, (sum, t) => sum + t.amount).toStringAsFixed(2);
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async{
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions();
    notifyListeners();
  }
}