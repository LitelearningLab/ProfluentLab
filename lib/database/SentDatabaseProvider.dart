import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'SentDao.dart';

class SentDatabaseProvider {
  static final _instance = SentDatabaseProvider._internal();
  static SentDatabaseProvider get = _instance;
  bool isInitialized = false;
  Database? _db;

  SentDatabaseProvider._internal();

  Future<Database?> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'sentences.db');

    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(SentDao().createTableQuery);
    });
  }
}
