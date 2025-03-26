import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'ProfluentLink.dart';

class ProfluentEnglish implements Jsonable {
  String? id;
  String? category;
  String? link;
  List<ProfluentLink>? subcategories;

  ProfluentEnglish({
    this.id,
    this.category,
    this.link,
    this.subcategories,
  });

  ProfluentEnglish.map(dynamic obj) {
    this.id = obj['id'];
    this.category = obj['category'];
    this.link = obj['link'];
    this.subcategories = obj['subcategories'];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (category != null) {
      map['category'] = category;
    }

    if (link != null) {
      map['link'] = link;
    }
    if (subcategories != null) {
      map['subcategories'] = subcategories;
    }

    return map;
  }

  @override
  ProfluentEnglish.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.category = map['category'];
    this.link = map['link'];
    this.subcategories = map['subcategories'] != null
        ? (map['subcategoris'] as List)
            .map((i) => ProfluentLink.fromMap(i))
            .toList()
        : null;
  }

  factory ProfluentEnglish.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProfluentEnglish(
      id: doc.id,
      category: map['category'],
      link: map['link'],
      subcategories: map['subcategories'] != null
          ? (map['subcategories'] as List)
              .map((i) => ProfluentLink.fromMap(i))
              .toList()
          : null,
    );
  }
}
