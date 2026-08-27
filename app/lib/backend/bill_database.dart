import 'package:sqflite/sqflite.dart';

class BillDatabase {
  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final path = '${await getDatabasesPath()}/pricepilot_bill.db';
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          contact TEXT NOT NULL,
          balance REAL NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          sku TEXT NOT NULL,
          category TEXT NOT NULL,
          stock INTEGER NOT NULL DEFAULT 0,
          price REAL NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          number TEXT NOT NULL,
          customer TEXT NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          status TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          account TEXT NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL
        )
      ''');
    });
  }

  Future<List<Map<String, Object?>>> read(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  Future<void> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    await db.insert(table, values);
  }
}
