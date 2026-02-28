import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/services/database_helper.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier{
  List<Transaction> _transactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    notifyListeners();
  }

  List<Transaction> get transactions => _transactions;

  double get totalIncome => _transactions.where((t) => t.type == TransactionType.income).fold(0.00, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => t.type == TransactionType.expense).fold(0.00, (sum, t) => sum + t.amount);

  void addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions();
    notifyListeners();
  }

  void removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
    notifyListeners();
  }

  void updateTransaction(Transaction transaction) async{
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions();
    notifyListeners();
  }
}