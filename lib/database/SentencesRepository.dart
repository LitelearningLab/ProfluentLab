import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/models/Sentence.dart';

abstract class SentenceRepository {
  SentDatabaseProvider? databaseProvider;

  Future<Sentence> insert(Sentence sentence);

  Future<Sentence> update(Sentence sentence);

  Future<Sentence> delete(Sentence id);

  // Future<bool> isBookingAvailable(String bookingRefNo);

  Future<List<Sentence>> getWords();

  Future<List<Sentence>> getFav();

  Future<bool> setFav(int sentenceId, int fav, String localPath);

  Future<bool> setDownloadPath(int wordId, String localPath);
}
