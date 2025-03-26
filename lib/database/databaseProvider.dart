import 'package:litelearninglab/database/WordsDao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider get = _instance;
  bool isInitialized = false;
  Database? _db;

  DatabaseProvider._internal();

  Future<Database?> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'wordsTest.db');

    _db = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute(WordsDao().createTableQuery);
    });
  }
}
