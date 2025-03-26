import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class SpeechLab implements Jsonable {
  String? id;
  int? correct;
  int? listatt;
  int? pracatt;
  int? time;
  String? lastAttempt;
  double? lastScore;
  double? score;
  String? sentence;
  String? userId;
  String? dateTime;
  String? title;
  String? load;
  String? main;
  int? timeCal;
  Map<String, dynamic>? focusWord;

  SpeechLab({
    this.id,
    this.correct,
    this.listatt,
    this.pracatt,
    this.time,
    this.lastAttempt,
    this.lastScore,
    this.sentence,
    this.focusWord,
    this.dateTime,
    this.userId,
    this.score,
    this.title,
    this.load,
    this.main,
    this.timeCal,
  });

  SpeechLab.map(dynamic obj) {
    id = obj['id'];
    correct = obj['correct'];

    listatt = obj['listatt'];
    pracatt = obj['pracatt'];
    score = double.parse(obj['score'].toString());
    time = obj['time'];
    sentence = obj['sentence'];
    lastAttempt = obj['lastAttempt'];
    lastScore = double.parse(obj['lastScore'].toString());
    dateTime = obj['dateTime'];
    userId = obj['userId'];
    title = obj['title'];
    load = obj['load'];
    main = obj['main'];
    timeCal = obj['timeCal'];
    // focusWord = obj['focusWord'];
    focusWord = focusWord;
    // obj['focusWords'] != null ? new List.from(obj['focusWords']) : null;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['correct'] = correct;

    map['listatt'] = listatt;
    map['score'] = score;
    map['pracatt'] = pracatt;
    map['time'] = time;
    map['userId'] = userId;
    map['sentence'] = sentence;
    map['lastAttempt'] = lastAttempt;
    map['lastScore'] = lastScore;
    map['focusWord'] = focusWord;
    map['dateTime'] = dateTime;
    map['title'] = title;
    map['load'] = load;
    map['main'] = main;
    map['timeCal'] = timeCal;

    return map;
  }

  SpeechLab.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    correct = map['correct'];

    listatt = map['listatt'];
    pracatt = map['pracatt'];
    userId = map['userId'];
    score = double.parse(map['score'].toString());

    time = map['time'];
    lastAttempt = map['lastAttempt'];
    lastScore = double.parse(map['lastScore'].toString());
    sentence = map['sentence'];
    dateTime = map['dateTime'];
    title = map['title'];
    load = map['load'];
    main = map['main'];
    timeCal = map['timeCal'];
    // focusWord = map['focusWord'];
    focusWord = focusWord;
    // map['focusWords'] != null ? new List.from(map['focusWords']) : null;
  }

  @override
  factory SpeechLab.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return SpeechLab(
      id: doc.id,
      correct: map['correct'],
      listatt: map['listatt'],
      pracatt: map['pracatt'],
      userId: map['userId'],
      score: double.parse(map['score'].toString()),
      time: map['time'],
      lastAttempt: map['lastAttempt'],
      lastScore: double.parse(map['lastScore'].toString()),
      sentence: map['sentence'],
      dateTime: map['dateTime'],
      title: map['title'],
      load: map['load'],
      main: map['main'],
      timeCal: map['timeCal'],
      // focusWord : map['focusWord'],
      focusWord: map['focusWord'] != null ? Map<String, List>.from(map['focusWord']) : null,
    );
    // map['focusWords'] != null ? new List.from(map['focusWords']) : null);
  }
}
