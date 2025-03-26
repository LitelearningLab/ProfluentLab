import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'InteractiveLink.dart';

class InteracticeSimulationMain implements Jsonable {
  String? id;
  String? category;
  bool? underconstruction;
  List<InteractiveLink>? subcategories;

  InteracticeSimulationMain({
    this.id,
    this.category,
    this.subcategories,
    this.underconstruction,
  });

  InteracticeSimulationMain.map(dynamic obj) {
    this.id = obj['id'];
    this.category = obj['category'];
    this.underconstruction = obj['underconstruction'];
    this.subcategories = obj['subcategoris'];
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
    if (subcategories != null) {
      map['subcategoris'] = subcategories;
    }
    if (underconstruction != null) {
      map['underconstruction'] = underconstruction;
    }

    return map;
  }

  @override
  InteracticeSimulationMain.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.category = map['category'];
    this.underconstruction = map['underconstruction'];

    this.subcategories = map['subcategoris'] != null
        ? (map['subcategoris'] as List)
            .map((i) => InteractiveLink.fromMap(i))
            .toList()
        : null;
  }

  factory InteracticeSimulationMain.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return InteracticeSimulationMain(
      id: doc.id,
      category: map['category'],
      underconstruction: map['underconstruction'],
      subcategories: map['subcategoris'] != null
          ? (map['subcategoris'] as List)
              .map((i) => InteractiveLink.fromMap(i))
              .toList()
          : null,
    );
  }
}
