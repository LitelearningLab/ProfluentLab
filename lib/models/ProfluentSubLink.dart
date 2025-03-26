import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'Word.dart';

class ProfluentSubLink implements Jsonable {
  String? id;
  String? v1;
  String? v2;
  String? v3;
  String? v4;
  String? v5;
  List<Word>? words;

  ProfluentSubLink({
    this.id,
    this.v1,
    this.v2,
    this.v3,
    this.v4,
    this.v5,
    this.words,
  });

  ProfluentSubLink.map(dynamic obj) {
    this.id = obj['id'];
    this.v1 = obj['v1'];
    this.v2 = obj['v2'];
    this.v3 = obj['v3'];
    this.v4 = obj['v4'];
    this.v5 = obj['v5'];
    this.words = obj['words'];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (v1 != null) {
      map['v1'] = v1;
    }

    if (v2 != null) {
      map['v2'] = v2;
    }

    if (v3 != null) {
      map['v3'] = v3;
    }

    if (v4 != null) {
      map['v4'] = v4;
    }
    if (v5 != null) {
      map['v5'] = v5;
    }

    if (words != null) {
      map['words'] = words;
    }

    return map;
  }

  @override
  ProfluentSubLink.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.v1 = map['v1'];

    this.v2 = map['v2'];
    this.v3 = map['v3'];
    this.v4 = map['v4'];
    this.v5 = map['v5'];
    this.words = map['words'] != null
        ? (map['words'] as List).map((i) => Word.fromMap(i)).toList()
        : null;
  }

  factory ProfluentSubLink.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProfluentSubLink(
      id: doc.id,
      v1: map['v1'],
      v2: map['v2'],
      v3: map['v3'],
      v4: map['v4'],
      v5: map['v5'],
      words: map['words'] != null
          ? (map['words'] as List).map((i) => Word.fromMap(i)).toList()
          : null,
    );
  }
}
