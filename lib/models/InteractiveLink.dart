import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class InteractiveLink implements Jsonable {
  String? id;
  String? name;
  String? link1;
  String? link2;
  String? link3;
  String? link4;

  InteractiveLink({
    this.id,
    this.name,
    this.link4,
    this.link2,
    this.link1,
    this.link3,
  });

  InteractiveLink.map(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.link3 = obj['link3'];
    this.link1 = obj['link1'];
    this.link2 = obj['link2'];
    this.link4 = obj['link4'];
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
    if (link4 != null) {
      map['link4'] = link4;
    }

    if (link2 != null) {
      map['link2'] = link2;
    }
    if (link1 != null) {
      map['link1'] = link1;
    }
    if (link3 != null) {
      map['link3'] = link3;
    }

    return map;
  }

  @override
  InteractiveLink.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];

    this.link3 = map['link3'];
    this.link1 = map['link1'];
    this.link2 = map['link2'];
    this.link4 = map['link4'];
  }

  factory InteractiveLink.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return InteractiveLink(
      id: doc.id,
      name: map['name'],
      link4: map['link4'],
      link2: map['link2'],
      link1: map['link1'],
      link3: map['link3'],
    );
  }
}
