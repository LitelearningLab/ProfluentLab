import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'ProcessLearningSub.dart';

class ProcessLearningMain implements Jsonable {
  String? id;
  String? category;
  bool? underconstruction;
  List<ProcessLearningSub>? subcategories;

  ProcessLearningMain({
    this.id,
    this.category,
    this.subcategories,
    this.underconstruction,
  });

  ProcessLearningMain.map(dynamic obj) {
    this.id = obj['id'];
    this.category = obj['category'];
    this.subcategories = obj['subcategoris'];
    this.underconstruction = obj['underconstruction'];
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
  ProcessLearningMain.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.category = map['category'];
    this.underconstruction = map['underconstruction'];

    this.subcategories = map['subcategoris'] != null
        ? (map['subcategoris'] as List)
            .map((i) => ProcessLearningSub.fromMap(i))
            .toList()
        : null;
  }

  factory ProcessLearningMain.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProcessLearningMain(
      id: doc.id,
      category: map['category'],
      underconstruction: map['underconstruction'],
      subcategories: map['subcategoris'] != null
          ? (map['subcategoris'] as List)
              .map((i) => ProcessLearningSub.fromMap(i))
              .toList()
          : null,
    );
  }
}
