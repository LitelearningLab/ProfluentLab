import 'dart:developer';

import 'package:litelearninglab/models/Sentence.dart';

import 'SentDao.dart';
import 'SentDatabaseProvider.dart';
import 'SentencesRepository.dart';

class SentencesDatabaseRepository implements SentenceRepository {
  final dao = SentDao();

  @override
  SentDatabaseProvider? databaseProvider;

  SentencesDatabaseRepository(this.databaseProvider);

  @override
  Future<Sentence> insert(Sentence sentence) async {
    final db = await databaseProvider?.db();
    sentence.id = await db?.insert(dao.tableName, dao.toMap(sentence));
    return sentence;
  }

  @override
  Future<Sentence> delete(Sentence sentence) async {
    final db = await databaseProvider?.db();
    await db?.delete(dao.tableName, where: dao.columnId + " = ?", whereArgs: [sentence.id]);
    return sentence;
  }

  Future<void> clearSentenceTable() async {
    print("************CLEARING ALL DATA ******************");
    final db = await databaseProvider?.db();
    await db?.delete(dao.tableName);
  }

  @override
  Future<Sentence> update(Sentence sentence) async {
    final db = await databaseProvider?.db();
    await db?.update(dao.tableName, dao.toMap(sentence), where: dao.columnId + " = ?", whereArgs: [sentence.id]);
    return sentence;
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
  Future<List<Sentence>> getWords() async {
    final db = await databaseProvider?.db();

    // List<Map> maps = await db.query("Select * from " +
    //     dao.tableName +
    //     " where " +
    //     dao.columnCat +
    //     " = " +
    //     cat);

    List<Map> maps = await db!.query(dao.tableName);
    // int i = 0;
    // maps.forEach((element) {
    //   log("map inside the sentences database>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    //   log("${element[i].toString()}");
    //   i++;
    // });
    for (int i = 0; i < maps.length; i++) {
      log("${maps[i].toString()}");
    }
    return dao.fromList(maps);
  }

  @override
  Future<List<Sentence>> getFav() async {
    final db = await databaseProvider?.db();
    List<Map> maps = await db!.query("Select * from " + dao.tableName + " where " + dao.columnIsFav + " = 1");
    return dao.fromList(maps);
  }

  @override
  Future<List<Sentence>> getSearch({required String searchText}) async {
    final db = await databaseProvider?.db();
    // List<Map> maps = await db!.query("Select * from " + dao.tableName + " where " + dao.columnText + " like %$searchText%");
    // List<Map> maps = await db!.rawQuery("Select * from " + dao.tableName + " where " + dao.columnText + " like %$searchText%");
    List<Map> maps = await db!.rawQuery('SELECT * FROM sentences WHERE text LIKE ?', ['%$searchText%']);
    return dao.fromList(maps);
  }

  @override
  Future<bool> setFav(int wordId, int fav, String localPath) async {
    final db = await databaseProvider?.db();
    await db!.update(dao.tableName, dao.toFav(fav, localPath), where: dao.columnId + " = ?", whereArgs: [wordId]);

    return true;
  }

  @override
  Future<bool> setDownloadPath(int sentence, String localPath) async {
    final db = await databaseProvider?.db();
    await db!.update(dao.tableName, dao.toLocalPath(localPath), where: dao.columnId + " = ?", whereArgs: [sentence]);
    return true;
  }

  Future<String?> getDownloadPath(int sentenceId) async {
    final db = await databaseProvider?.db();
    List<Map<String, dynamic>> results = await db!.query(
      dao.tableName,
      columns: [dao.columnLocalPath], // Assuming `columnLocalPath` is the column for the path
      where: "${dao.columnId} = ?",
      whereArgs: [sentenceId],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first[dao.columnLocalPath] as String?;
    }
    return null; // Return null if no path is found
  }
}
