import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/FirestoreService.dart';

class UserM implements Jsonable {
  String? id;
  String? company;
  String? email;
  String? imei;
  String? mobile;
  String? model;
  String? profile;
  String? team;
  String? status;
  String? UserMname;
  String? city;
  String? encryptionKey;
  String? fcmID;
  String? access;
  String? fcmKey;

  UserM(
      {this.company,
      this.email,
      this.imei,
      this.id,
      this.mobile,
      this.model,
      this.profile,
      this.team,
      this.fcmID,
      this.access,
      this.status,
      this.city,
      this.encryptionKey,
      this.UserMname,
      this.fcmKey});

  toJson() {
    return {
      "company": company,
      "email": email,
      "imei": imei,
      "mobile": mobile,
      "model": model,
      "profile": profile,
      "city": city,
      "team": team,
      "status": status,
      "fcmID": fcmID,
      "encryptionKey": encryptionKey,
      "username": UserMname,
      "access": access,
      "fcmKey": fcmKey,
    };
  }

  UserM.map(dynamic obj) {
    this.id = obj['id'];
    this.company = obj['company'];

    this.email = obj['email'];
    this.imei = obj['imei'];
    this.mobile = obj['mobile'];

    this.model = obj['model'];
    this.profile = obj['profile'];
    this.city = obj['city'];
    this.team = obj['team'];
    this.status = obj['status'];
    this.UserMname = obj['username'];
    this.access = obj['access'];
    this.fcmKey = obj['fcmKey'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    if (company != null) {
      map['company'] = company;
    }
    if (fcmID != null) {
      map['fcmID'] = fcmID;
    }
    if (email != null) {
      map['email'] = email;
    }
    if (access != null) {
      map['access'] = access;
    }
    if (imei != null) {
      map['imei'] = imei;
    }
    if (mobile != null) {
      map['mobile'] = mobile;
    }
    if (model != null) {
      map['model'] = model;
    }
    if (profile != null) {
      map['profile'] = profile;
    }
    if (city != null) {
      map['city'] = city;
    }
    if (team != null) {
      map['team'] = team;
    }
    if (status != null) {
      map['status'] = status;
    }
    if (UserMname != null) {
      map['username'] = UserMname;
    }
    if (fcmKey != null) {
      map['fcmKey'] = fcmKey;
    }
    return map;
  }

  factory UserM.fromJson(DocumentSnapshot doc) {
    Map map = doc.data() as Map;
    return UserM(
      id: doc.id,
      company: map['company'],
      email: map['email'],
      imei: map['imei'],
      fcmID: map['fcmID'],
      access: map['access'],
      mobile: map['mobile'],
      city: map['city'] is List ? (map['city'] as List).join(', ') : map['city'],
      model: map['model'],
      team: map['team'] is List ? (map['team'] as List).join(', ') : map['team'],
      profile: map['profile'],
      status: map['status'],
      UserMname: map['username'],
      fcmKey: map['fcmKey'],
    );
  }

  UserM.fromMap(Map<String, dynamic> map)
      : this.id = map['id'],
        this.company = map['company'],
        this.email = map['email'],
        this.imei = map['imei'],
        this.mobile = map['mobile'],
        this.model = map['model'],
        this.profile = map['profile'],
        this.fcmID = map['fcmID'],
        this.city = map['city'] is List ? (map['city'] as List).join(', ') : map['city'],
        this.team = map['team'] is List ? (map['team'] as List).join(', ') : map['team'],
        this.status = map['status'],
        this.access = map['access'],
        this.UserMname = map['username'],
        this.fcmKey = map['fcmKey'];

// UserM.fromMap(Map<String, dynamic> map) {
//   this.key = map['key'];
//   this.company = map['company'];
//
//   this.email = map['email'];
//   this.imei = map['imei'];
//
//   this.mobile = map['mobile'];
//   this.model = map['model'];
//   this.profile = map['profile'];
//   this.city = map['city'];
//   this.team = map['team'];
//   this.status = map['status'];
//   this.UserMname = map['username'];
// }
}
