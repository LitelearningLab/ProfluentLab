import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class ProLab implements Jsonable {
  String? id;
  String? load;
  String? title;
  String? userId;
  String? word;
  String? date;
  String? lastAttempt;
  int? correct;
  int? listatt;
  int? pracatt;
  int? time;
  int? timeCal;
  String? batch;
  String? companyId;

  ProLab(
      {this.id,
      this.correct,
      this.listatt,
      this.pracatt,
      this.load,
      this.lastAttempt,
      this.userId,
      this.date,
      this.title,
      this.word,
      this.time,
      this.timeCal,
      this.batch,
      this.companyId});

  ProLab.map(dynamic obj) {
    this.id = obj['id'];
    this.correct = obj['correct'];
    this.title = obj['title'];
    this.userId = obj['userId'];
    this.lastAttempt = obj['lastAttempt'];
    this.batch = obj['batch'];
    this.companyId = obj['companyId'];

    this.listatt = obj['listatt'];
    this.pracatt = obj['pracatt'];
    this.load = obj['load'];
    this.time = obj['gcm_regId'];
    this.word = obj['word'];
    this.timeCal = obj['timeCal'];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (companyId != null) {
      map['companyId'] = companyId;
    }
    if (batch != null) {
      map['batch'] = batch;
    }
    if (correct != null) {
      map['correct'] = correct;
    }
    if (userId != null) {
      map['userId'] = userId;
    }
    if (date != null) {
      map['date'] = date;
    }
    if (listatt != null) {
      map['listatt'] = listatt;
    }
    if (title != null) {
      map['title'] = title;
    }
    if (pracatt != null) {
      map['pracatt'] = pracatt;
    }
    if (load != null) {
      map['load'] = load;
    }
    if (time != null) {
      map['time'] = time;
    }
    if (word != null) {
      map['word'] = word;
    }
    if (lastAttempt != null) {
      map['lastAttempt'] = lastAttempt;
    }
    if (timeCal != null) {
      map['timeCal'] = timeCal;
    }

    return map;
  }

  @override
  ProLab.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.correct = map['correct'];

    this.listatt = map['listatt'];
    this.pracatt = map['pracatt'];
    this.title = map['title'];
    this.userId = map['userId'];
    this.lastAttempt = map['lastAttempt'];
    this.date = map['date'];
    this.load = map['load'];
    this.batch = map['batch'];
    this.companyId = map['companyId'];
    this.time = map['time'];
    this.word = map['word'];
    this.timeCal = map['timeCal'];
  }

  factory ProLab.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProLab(
        id: doc.id,
        correct: map['correct'],
        listatt: map['listatt'],
        title: map['title'],
        pracatt: map['pracatt'],
        lastAttempt: map['lastAttempt'],
        batch: map['batch'],
        companyId: map['companyId'],
        userId: map['userId'],
        date: map['date'],
        load: map['load'],
        word: map['word'],
        time: map['time'],
        timeCal: map['timeCal']);
  }
}
