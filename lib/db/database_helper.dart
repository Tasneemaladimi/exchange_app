import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> database() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exchange_app.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id TEXT PRIMARY KEY,
            ownerId TEXT,
            title TEXT,
            description TEXT,
            imageUrl TEXT,
            category TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<void> insertItem(Item item) async {
    final db = await database();
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Item>> getItems() async {
    final db = await database();
    final maps = await db.query('items');
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  static Future<void> updateItem(Item item) async {
    final db = await database();
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<void> deleteItem(String id) async {
    final db = await database();
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
