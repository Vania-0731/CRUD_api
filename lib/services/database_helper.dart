import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT,
        category TEXT
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toJsonForDB());
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'id DESC');
    return result.map((json) => Product.fromJsonDB(json)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Product.fromJsonDB(result.first);
    }
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toJsonForDB(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isEmpty() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    final count = result.first['count'] as int;
    return count == 0;
  }

  Future<void> insertMultipleProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    for (var product in products) {
      batch.insert('products', product.toJsonForDB());
    }
    await batch.commit();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
