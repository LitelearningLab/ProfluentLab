import 'package:litelearninglab/models/Word.dart';

import 'Dao.dart';

class WordsDao implements Dao<Word> {
  final tableName = 'words';
  final columnId = 'id';
  final key = 'key';
  final _columnFile = 'file';
  final _columnPronun = 'pronun';
  final _columnSyllables = 'syllables';
  final _columnText = 'text';
  final columnCat = 'cat';
  final columnIsFav = 'isFav';
  final columnLocalPath = 'localPath';
  final isPriority = 'isPriority';

  @override
  String get createTableQuery =>
      "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY,"
      " $key TEXT,"
      " $_columnFile TEXT,"
      " $_columnPronun TEXT,"
      " $_columnSyllables TEXT,"
      " $columnCat TEXT,"
      " $columnIsFav INTEGER,"
      " $columnLocalPath TEXT,"
      " $_columnText TEXT,"
      " $isPriority TEXT)";

  @override
  Word fromMap(Map<dynamic, dynamic> query) {
    Word word = Word();
    word.id = query[columnId];
    word.cat = query[columnCat];
    word.key = query[key];
    word.file = query[_columnFile];
    word.isFav = query[columnIsFav];
    word.localPath = query[columnLocalPath];
    word.pronun = query[_columnPronun];
    word.syllables = query[_columnSyllables];
    word.text = query[_columnText];
    word.isPriority = query[isPriority];

/*    print("Pronunciation Labbbb>>>>>>>>>>>>>>>>>>>>>>>>.");
    print("word id : ${word.id}");
    print("word cat : ${word.cat}");
    print("word key : ${word.key}");
    print("word file : ${word.file}");
    print("word isfav : ${word.isFav}");
    print("word localpath : ${word.localPath}");
    print("word pronun : ${word.pronun}");
    print("word syllables : ${word.syllables}");
    print("word text : ${word.text}");*/
    return word;
  }

  @override
  Map<String, dynamic> toMap(Word object) {
    return <String, dynamic>{
      _columnText: object.text,
      columnIsFav: object.isFav,
      _columnSyllables: object.syllables,
      columnCat: object.cat,
      columnLocalPath: object.localPath,
      _columnPronun: object.pronun,
      _columnFile: object.file,
      key: object.key,
      isPriority: object.isPriority
    };
  }

  Map<String, dynamic> toFav(int fav, String localPath) {
    return <String, dynamic>{columnIsFav: fav, columnLocalPath: localPath};
  }

  Map<String, dynamic> toLocalPath(String localPath) {
    return <String, dynamic>{columnLocalPath: localPath};
  }

  @override
  List<Word> fromList(List<Map<dynamic, dynamic>> query) {
    List<Word> notes = [];
    for (Map map in query) {
      notes.add(fromMap(map));
    }
    return notes;
  }
}
