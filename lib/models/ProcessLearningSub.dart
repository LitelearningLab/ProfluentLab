import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'ProcessLearningLink.dart';

class ProcessLearningSub implements Jsonable {
  String? id;
  String? name;
  String? link;
  List<ProcessLearningLink>? linkCats;

  ProcessLearningSub({
    this.id,
    this.name,
    this.link,
    this.linkCats,
  });

  ProcessLearningSub.map(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.link = obj['link'];
    this.linkCats = obj['link_cats'];
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
    if (linkCats != null) {
      map['link_cats'] = linkCats;
    }
    if (link != null) {
      map['link'] = link;
    }

    return map;
  }

  @override
  ProcessLearningSub.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.link = map['link'];

    this.linkCats = map['link_cats'] != null
        ? (map['link_cats'] as List)
            .map((i) => ProcessLearningLink.fromMap(i))
            .toList()
        : null;
  }

  factory ProcessLearningSub.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProcessLearningSub(
      id: doc.id,
      name: map['name'],
      link: map['link'],
      linkCats: map['link_cats'] != null
          ? (map['link_cats'] as List)
              .map((i) => ProcessLearningLink.fromMap(i))
              .toList()
          : null,
    );
  }
}
