import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'StaticWordsDao.dart';
import 'StaticWordsDataModel.dart';

class StaticDatabaseProvider {
  static final _instance = StaticDatabaseProvider._internal();
  StaticText text = StaticText(id: 1, content: 'Helloocheckkkkkk');
  static StaticDatabaseProvider get = _instance;
  //StaticTextDao staticTextDao = StaticTextDao();
  bool isInitialized = false;
  Database? _db;
  StaticDatabaseProvider._internal();

  Future<Database?> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'staticWords.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE StaticTexts (
            id INTEGER PRIMARY KEY,
            content TEXT
          )
        ''');
      },
      /*  onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE StaticTexts (
              id INTEGER PRIMARY KEY,
              content TEXT
            )
          ''');
        }
      },*/
    );

    isInitialized = true;
    StaticText text = StaticText(id: 1, content: 'Helloocheckkkkkk');
    await insertStaticText(text);
  }

  Future<void> insertStaticText(StaticText text) async {
    await _db!.insert(
      'StaticTexts',
      text.toMap(),
    );
  }
}
