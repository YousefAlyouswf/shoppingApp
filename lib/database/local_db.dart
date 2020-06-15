import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(
      path.join(
        dbPath,
        'shopping.db',
      ),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE cart(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price TEXT, image TEXT, des TEXT, q TEXT)");
        await db.execute(
            "CREATE TABLE address(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, userAddress TEXT)");
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db
        .insert(
      table,
      data,
    )
        .catchError((e) {
      print(e);
    });
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> updateData(
      String table, Map<String, Object> data, int itemID) async {
    final db = await DBHelper.database();
    db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [itemID],
    );
  }

  static Future<List<Map<String, dynamic>>> itemtCount(String table) async {
    final db = await DBHelper.database();

    return db.query(
      table,
    );
  }

  static Future<void> deleteItem(String table, int id) async {
    final db = await DBHelper.database();

    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  ///----------------- USER ADDRESS

  static Future<void> insertAddress(
      String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db
        .insert(
      table,
      data,
    )
        .catchError((e) {
      print(e);
    });
  }

  static Future<List<Map<String, dynamic>>> getDataAddress(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> deleteAddress(String table, int id) async {
    final db = await DBHelper.database();

    db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}