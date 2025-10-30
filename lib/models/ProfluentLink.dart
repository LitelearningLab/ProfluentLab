import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';
import 'ProfluentSubLink.dart';

class ProfluentLink implements Jsonable {
  String? id;
  String? name;
  String? link;
  ProfluentSubLink? links;
  String? videoLink;
  List<SoundPracticeModel>? soundsPractice;
  String? ulr;

  ProfluentLink(
      {this.id,
      this.name,
      this.link,
      this.links,
      this.videoLink,
      this.soundsPractice,
      this.ulr});

  ProfluentLink.map(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.link = obj['link'];
    this.videoLink = obj['videoLink'];
    this.links = obj['links'];
    this.soundsPractice = obj['soundsPractice'];
    this.ulr = obj['ULR'];
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

    if (videoLink != null) {
      map['videoLink'] = videoLink;
    }
    if (links != null) {
      map['links'] = links;
    }
    if (soundsPractice != null) {
      map['soundsPractice'] = soundsPractice;
    }
    if (ulr != null) {
      map['ULR'] = ulr;
    }

    return map;
  }

  @override
  ProfluentLink.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];

    this.link = map['link'];
    this.links =
        map['links'] != null ? ProfluentSubLink.fromMap(map['links']) : null;
    this.videoLink = map['videoLink'];
    this.soundsPractice = map['soundsPractice'] != null
        ? (map['soundsPractice'] as List)
            .map((i) => SoundPracticeModel.fromMap(i))
            .toList()
        : null;
    this.ulr = map['ULR'];
  }

  factory ProfluentLink.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return ProfluentLink(
        id: doc.id,
        name: map['name'],
        link: map['link'],
        videoLink: map['videoLink'],
        links: map['links'] != null
            ? ProfluentSubLink.fromMap(map['links'])
            : null,
        soundsPractice: map['soundsPractice'] != null
            ? (map['soundsPractice'] as List)
                .map((i) => SoundPracticeModel.fromMap(i))
                .toList()
            : null,
        ulr: map['ULR']);
  }
}

class SoundPracticeModel implements Jsonable {
  String? file;
  String? pronun;
  String? syllabels;
  String? text;

  SoundPracticeModel({
    this.file,
    this.pronun,
    this.syllabels,
    this.text,
  });

  SoundPracticeModel.map(dynamic obj) {
    this.file = obj['file'];
    this.pronun = obj['pronun'];
    this.syllabels = obj['syllables'];
    this.text = obj['text'];
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (file != null) {
      map['file'] = file;
    }

    if (pronun != null) {
      map['pronun'] = pronun;
    }

    if (syllabels != null) {
      map['syllables'] = syllabels;
    }
    if (text != null) {
      map['text'] = text;
    }

    return map;
  }

  @override
  SoundPracticeModel.fromMap(Map<String, dynamic> map) {
    this.file = map['file'];
    this.pronun = map['pronun'];
    this.syllabels = map['syllables'];
    this.text = map['text'];
  }

  factory SoundPracticeModel.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return SoundPracticeModel(
      file: map['file'],
      pronun: map['pronun'],
      syllabels: map['syllabels'],
      text: map['text'],
    );
  }

  Map<String, dynamic> toJson() => {
        'file': file,
        'pronun': pronun,
        'syllables': syllabels,
        'text': text,
      };
}
