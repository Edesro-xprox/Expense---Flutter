import 'package:expense_managment/models/category.dart';
import 'package:expense_managment/services/database_helper.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Category> get categories => _categories;

  List<Category> categoriesByType(CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  Future<void> loadCategories() async {
    _categories = await _dbHelper.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _dbHelper.insertCategory(category);
    await loadCategories();
  }

  Future<void> removeCategory(String id) async {
    await _dbHelper.deleteCategory(id);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _dbHelper.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _dbHelper.deleteCategory(id);
    await loadCategories();
  }
}
