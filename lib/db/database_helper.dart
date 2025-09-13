import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> database() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exchange_app.db');

    // For simplicity, we'll delete the database and recreate it if the schema changes.
    // In a real app, a proper migration strategy would be needed.
    await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            ownerId TEXT,
            title TEXT,
            description TEXT,
            imageUrl TEXT,
            category TEXT,
            status TEXT,
            createdAt TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Map<String, dynamic> _productToJson(Product product) {
    final json = product.toJson();
    json['createdAt'] = (json['createdAt'] as Timestamp).toDate().toIso8601String();
    return json;
  }

  static Product _productFromJson(Map<String, dynamic> json) {
    final newJson = Map<String, dynamic>.from(json);
    newJson['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    return Product.fromJson(newJson);
  }

  static Future<void> insertProduct(Product product) async {
    final db = await database();
    await db.insert(
      'products',
      _productToJson(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getProducts() async {
    final db = await database();
    final maps = await db.query('products');
    if (maps.isEmpty) return [];
    return maps.map((map) => _productFromJson(map)).toList();
  }

  static Future<void> updateProduct(Product product) async {
    final db = await database();
    await db.update(
      'products',
      _productToJson(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> deleteProduct(String id) async {
    final db = await database();
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearProducts() async {
    final db = await database();
    await db.delete('products');
  }
}
