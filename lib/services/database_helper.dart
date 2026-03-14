import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import 'package:expense_managment/models/transaction.dart';
import 'package:expense_managment/models/category.dart';

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
    String path = join(await getDatabasesPath(), 'transactions.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE pdevcategory(
            id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE pdevtransactions(
            id TEXT PRIMARY KEY,
            amount REAL,
            description TEXT,
            category_id TEXT,
            date TEXT,
            is_paid INTEGER DEFAULT 0,
            FOREIGN KEY(category_id) REFERENCES pdevcategory(id)
          )
        ''');

        await _insertDefaultCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE pdevtransactions ADD COLUMN is_paid INTEGER DEFAULT 0');
        }
      },
    );
  }

  List<Category> _defaultCategories() {
    return [
      Category(id: DateTime.now().toString(), name: 'Sueldo', type: CategoryType.income),
      Category(id: DateTime.now().toString(), name: 'Venta', type: CategoryType.income),
      Category(id: DateTime.now().toString(), name: 'Otros', type: CategoryType.income),
      Category(id: DateTime.now().toString(), name: 'Transporte', type: CategoryType.expense),
      Category(id: DateTime.now().toString(), name: 'Salud', type: CategoryType.expense),
      Category(id: DateTime.now().toString(), name: 'Otros', type: CategoryType.expense),
    ];
  }

  Future<void> _insertDefaultCategories(Database db) async {
    for (final category in _defaultCategories()) {
      await db.insert(
        'pdevcategory',
        category.toMapCategory(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
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
        categoryId: maps[i]['category_id'],
        date: DateTime.parse(maps[i]['date']),
        isPaid: maps[i]['is_paid'] == 1,
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

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'pdevcategory', 
      category.toMapCategory(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pdevcategory');
    if (maps.isEmpty) {
      await _insertDefaultCategories(db);
    }
    final List<Map<String, dynamic>> mapsWithDefaults = await db.query('pdevcategory');
    return List.generate(mapsWithDefaults.length, (i) {
      return Category(
        id: mapsWithDefaults[i]['id'],
        name: mapsWithDefaults[i]['name'],
        type: mapsWithDefaults[i]['type'] == 'income' ? CategoryType.income : CategoryType.expense
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete(
      'pdevcategory',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'pdevcategory',
      category.toMapCategory(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
}
