import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class SqliteDB {
  static int databaseVersion = 1;

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'ybo_approval.db'), version: databaseVersion, onCreate: (db, version) {
      var batch = db.batch();
      _createTables(batch);
    }, onUpgrade: (db, int oldVersion, int newVersion) async {
      var batch = db.batch();

      _onUpgrade(batch, db);
    });
  }

  static void _createTables(Batch batch) {
    // Sample table only
    batch.execute('CREATE TABLE IF NOT EXISTS user_accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT)');
    batch.commit();
  }

  static void _onUpgrade(Batch batch, Database db) async {
    _createTables(batch);
    await upgradeTables(db, batch);
    batch.commit();
  }

  static closeDB() async {
    final db = await SqliteDB.database();
    await db.close();
  }

  static upgradeTables(Database db, Batch batch) async {}
  static Future<bool> columnExists(Database db, var tableName, var columnName) async {
    var count = await db.rawQuery("${"PRAGMA table_info ('" + tableName}')");
    bool isExist = false;
    for (var u in count) {
      if (u["name"] == columnName) {
        isExist = true;
      }
    }
    return isExist;
  }

  static Future<bool> clearAllTables() async {
    final db = await SqliteDB.database();
    try {
      List<Map<String, dynamic>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

      for (var table in tables) {
        String tableName = table['name'];
        await db.execute("DELETE FROM $tableName");
      }

      return true;
    } catch (e) {
      Logger().e(e);
      return false;
    }
  }
}
