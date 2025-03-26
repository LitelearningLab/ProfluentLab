import 'package:litelearninglab/models/Sentence.dart';

import 'Dao.dart';

class SentDao implements Dao<Sentence> {
  final tableName = 'sentences';
  final columnId = 'id';
  final key = 'key';
  final _columnFile = 'file';
  final _columnText = 'text';
  final columnCat = 'cat';
  final columnIsFav = 'isFav';
  final columnLocalPath = 'localPath';
  final columnPriority = 'isPriority';

  @override
  String get createTableQuery => "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY,"
      " $key TEXT,"
      " $_columnFile TEXT,"
      " $columnCat TEXT,"
      " $columnIsFav INTEGER,"
      " $columnLocalPath TEXT,"
      " $_columnText TEXT,"
      " $columnPriority TEXT)";

  @override
  Sentence fromMap(Map<dynamic, dynamic> query) {
    Sentence sentence = Sentence();
    sentence.id = query[columnId];
    sentence.cat = query[columnCat];
    sentence.key = query[key];
    sentence.file = query[_columnFile];
    sentence.isFav = query[columnIsFav];
    sentence.text = query[_columnText];
    sentence.localPath = query[columnLocalPath];
    sentence.isPriority = query[columnPriority];
    return sentence;
  }

  @override
  Map<String, dynamic> toMap(Sentence object) {
    return <String, dynamic>{
      _columnText: object.text,
      columnIsFav: object.isFav,
      columnCat: object.cat,
      _columnFile: object.file,
      key: object.key,
      columnPriority: object.isPriority
    };
  }

  Map<String, dynamic> toFav(int fav, String localPath) {
    return <String, dynamic>{columnIsFav: fav, columnLocalPath: localPath};
  }

  Map<String, dynamic> toLocalPath(String localPath) {
    return <String, dynamic>{columnLocalPath: localPath};
  }

  @override
  List<Sentence> fromList(List<Map<dynamic, dynamic>> query) {
    List<Sentence> notes = [];
    for (Map map in query) {
      notes.add(fromMap(map));
    }
    return notes;
  }
}
