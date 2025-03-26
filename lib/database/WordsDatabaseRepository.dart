import 'package:litelearninglab/models/Word.dart';

import 'WordsDao.dart';
import 'WordsRepository.dart';
import 'databaseProvider.dart';

class WordsDatabaseRepository implements WordsRepository {
  final dao = WordsDao();

  @override
  DatabaseProvider? databaseProvider;

  WordsDatabaseRepository(this.databaseProvider);

  @override
  Future<Word> insert(Word word) async {
    final db = await databaseProvider?.db();
    final existingWord = await getWordById(word.id);

    if (existingWord != null) {
      return existingWord;
    }
    final int? insertedId = await db?.insert(dao.tableName, dao.toMap(word));
    if (insertedId != null && insertedId > 0) {
      word.id = insertedId;

      return word;
    } else {
      throw Exception("Failed to insert word into the database");
    }
  }

  Future<Word?> getWordById(int? id) async {
    if (id == null) return null;
    final db = await databaseProvider?.db();
    final List<Map<String, dynamic>>? results = await db?.query(
      dao.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results != null && results.isNotEmpty) {
      return dao.fromMap(results.first);
    }
    return null;
  }

/*  Future<Word> insert(Word word) async {
    print("storing double time1111111>>>>>");
    final db = await databaseProvider?.db();
    word.id = await db?.insert(dao.tableName, dao.toMap(word));
    print("Inserting word: ${word.id}");
    return word;
  }*/

  @override
  Future<Word> delete(Word word) async {
    final db = await databaseProvider?.db();
    await db?.delete(dao.tableName, where: dao.columnId + " = ?", whereArgs: [word.id]);
    return word;
  }

  @override
  Future<Word> update(Word word) async {
    final db = await databaseProvider?.db();
    await db?.update(dao.tableName, dao.toMap(word), where: dao.columnId + " = ?", whereArgs: [word.id]);
    return word;
  }

  // @override
  // Future<bool> isBookingAvailable(String bookingRefNo) async {
  //   final db = await databaseProvider.db();
  //   String query = "Select * from " +
  //       dao.tableName +
  //       " where " +
  //       dao.key +
  //       " = " +
  //       bookingRefNo;
  //   db.rawQuery(query, null).then((cursor) {
  //     if (cursor.length <= 0) {
  //       return false;
  //     }
  //   });
  //   return true;
  // }

  @override
  Future<List<Word>> getWords() async {
    final db = await databaseProvider?.db();
    // List<Map> maps = await db.query("Select * from " +
    //     dao.tableName +
    //     " where " +
    //     dao.columnCat +
    //     " = " +
    //     cat);

    List<Map> maps = await db!.query(dao.tableName);
    print("table name:${dao.tableName.length}");
    print("table name:${dao.tableName}");
    print("maps : ${maps.length}");

    return dao.fromList(maps);
  }

  @override
  Future<List<Word>> getFav() async {
    final db = await databaseProvider?.db();
    List<Map> maps = await db!.query("Select * from " + dao.tableName + " where " + dao.columnIsFav + " = 1");
    return dao.fromList(maps);
  }

  @override
  Future<bool> setFav(int wordId, int fav, String localPath) async {
    final db = await databaseProvider?.db();
    await db!.update(dao.tableName, dao.toFav(fav, localPath), where: dao.columnId + " = ?", whereArgs: [wordId]);

    return true;
  }

  @override
  Future<bool> setDownloadPath(int wordId, String localPath) async {
    final db = await databaseProvider?.db();
    await db!.update(dao.tableName, dao.toLocalPath(localPath), where: dao.columnId + " = ?", whereArgs: [wordId]);

    return true;
  }
}
