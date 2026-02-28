import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:expense_managment/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pdevtransactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pdevtransactions(
            id TEXT PRIMARY KEY,
            amount REAL,
            description TEXT,
            category TEXT,
            type TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'pdevtransactions', 
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pdevtransactions');
    return List.generate(maps.length, (i) {
      return Transaction(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        type: maps[i]['type'] == 'income' ? TransactionType.income : TransactionType.expense,
        date: DateTime.parse(maps[i]['date'])
      );
    });
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'pdevtransactions',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update(
      'pdevtransactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}