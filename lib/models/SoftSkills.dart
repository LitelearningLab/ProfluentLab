import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class SoftSkills implements Jsonable {
  String? id;
  String? name;
  String? link;

  SoftSkills({
    this.id,
    this.name,
    this.link,
  });

  SoftSkills.map(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.link = obj['link'];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (name != null) {
      map['name'] = name;
    }

    if (link != null) {
      map['link'] = link;
    }

    return map;
  }

  @override
  SoftSkills.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.link = map['link'];
  }

  factory SoftSkills.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return SoftSkills(
      id: doc.id,
      name: map['name'],
      link: map['link'],
    );
  }
}
