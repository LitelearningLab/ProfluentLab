import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class ProcessLearningLink implements Jsonable {
  String? id;
  String? name;
  String? faq;
  String? video;
  String? simulation;
  String? knowledge;
  String? eLearning;

  ProcessLearningLink({
    this.id,
    this.name,
    this.knowledge,
    this.video,
    this.faq,
    this.simulation,
    this.eLearning,
  });

  ProcessLearningLink.map(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.simulation = obj['simulation'];
    this.faq = obj['faq'];
    this.video = obj['video'];
    this.knowledge = obj['knowledge'];
    this.eLearning = obj['eLearning'];
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
    if (knowledge != null) {
      map['knowledge'] = knowledge;
    }
    if (eLearning != null) {
      map['eLearning'] = eLearning;
    }
    if (video != null) {
      map['video'] = video;
    }
    if (faq != null) {
      map['faq'] = faq;
    }
    if (simulation != null) {
      map['simulation'] = simulation;
    }

    return map;
  }

  @override
  ProcessLearningLink.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];

    this.simulation = map['simulation'];
    this.faq = map['faq'];
    this.video = map['video'];
    this.knowledge = map['knowledge'];
    this.eLearning = map['eLearning'];
  }

  factory ProcessLearningLink.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProcessLearningLink(
      id: doc.id,
      name: map['name'],
      knowledge: map['knowledge'],
      video: map['video'],
      faq: map['faq'],
      simulation: map['simulation'],
      eLearning: map['eLearning'],
    );
  }
}
