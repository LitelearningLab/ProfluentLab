import 'package:litelearninglab/models/Word.dart';

import 'databaseProvider.dart';

abstract class WordsRepository {
  DatabaseProvider? databaseProvider;

  Future<Word> insert(Word word);

  Future<Word> update(Word word);

  Future<Word> delete(Word id);

  // Future<bool> isBookingAvailable(String bookingRefNo);

  Future<List<Word>> getWords();

  Future<List<Word>> getFav();

  Future<bool> setFav(int wordId, int fav, String localPath);
  Future<bool> setDownloadPath(int wordId, String localPath);
}
