import 'package:litelearninglab/database/staticWordsDatabase/StaticWordsDataModel.dart';
import 'package:litelearninglab/database/staticWordsDatabase/StaticWordsDatebaseProvider.dart';
import 'package:sqflite/sqflite.dart';

class StaticTextDao {
  final StaticDatabaseProvider _staticDatabaseProvider;

  StaticTextDao(this._staticDatabaseProvider);

  StaticText text = StaticText(id: 1, content: 'Helloocheckkkkkk');

  Future<List<StaticText>> getStaticTexts() async {
    final db = await _staticDatabaseProvider.db();
    final List<Map<String, dynamic>> maps = await db!.query('StaticTexts');

    return List.generate(maps.length, (i) {
      return StaticText.fromMap(maps[i]);
    });
  }

  Future<void> updateStaticText(StaticText staticText) async {
    final db = await _staticDatabaseProvider.db();
    await db!.update(
      'StaticTexts',
      staticText.toMap(),
      where: 'id = ?',
      whereArgs: [staticText.id],
    );
  }

  Future<void> deleteStaticText(int id) async {
    final db = await _staticDatabaseProvider.db();
    await db!.delete(
      'StaticTexts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
