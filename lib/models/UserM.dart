import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:litelearninglab/utils/FirestoreService.dart';

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
  String? lastLogin;
  String? companyId;
  String? firstTImeLogin;

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
      this.fcmKey,
      this.lastLogin,
      this.companyId,
      this.firstTImeLogin});

  Map<String, dynamic> toJson() {
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
      "lastLogin": lastLogin,
      "companyid": companyId,
      'firstTimeLogin': firstTImeLogin
      // Consistent lowercase
    };
  }

  UserM.map(dynamic obj) {
    this.id = obj['id'];
    this.company = obj['company'];
    this.lastLogin = obj['lastLogin'];
    this.companyId = obj['companyid']; // Consistent lowercase
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
    this.firstTImeLogin = obj['firstTimeLogin'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) map['id'] = id;
    if (companyId != null) map['companyid'] = companyId; // Consistent lowercase
    if (company != null) map['company'] = company;
    if (lastLogin != null) map['lastLogin'] = lastLogin;
    if (fcmID != null) map['fcmID'] = fcmID;
    if (email != null) map['email'] = email;
    if (access != null) map['access'] = access;
    if (imei != null) map['imei'] = imei;
    if (mobile != null) map['mobile'] = mobile;
    if (model != null) map['model'] = model;
    if (profile != null) map['profile'] = profile;
    if (city != null) map['city'] = city;
    if (team != null) map['team'] = team;
    if (status != null) map['status'] = status;
    if (UserMname != null) map['username'] = UserMname;
    if (fcmKey != null) map['fcmKey'] = fcmKey;
    if (firstTImeLogin != null) map['firstTimeLogin'];
    return map;
  }

  factory UserM.fromJson(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    print('Firestore Document Fields: ${map.keys}'); // Debugging

    return UserM(
        id: doc.id,
        company: map['company'],
        lastLogin: map['lastLogin'],
        email: map['email'],
        companyId: map['companyid'] ?? '', // Consistent name with fallback
        imei: map['imei'],
        fcmID: map['fcmID'],
        access: map['access'],
        mobile: map['mobile'],
        city: map['city'] is List
            ? (map['city'] as List).join(', ')
            : map['city'],
        model: map['model'],
        team: map['team'] is List
            ? (map['team'] as List).join(', ')
            : map['team'],
        profile: map['profile'],
        status: map['status'],
        UserMname: map['username'],
        fcmKey: map['fcmKey'],
        firstTImeLogin: map['firstTimeLogin']);
  }

  UserM.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        company = map['company'],
        lastLogin = map['lastLogin'],
        email = map['email'],
        imei = map['imei'],
        mobile = map['mobile'],
        model = map['model'],
        profile = map['profile'],
        fcmID = map['fcmID'],
        city = map['city'] is List
            ? (map['city'] as List).join(', ')
            : map['city'],
        team = map['team'] is List
            ? (map['team'] as List).join(', ')
            : map['team'],
        status = map['status'],
        access = map['access'],
        UserMname = map['username'],
        fcmKey = map['fcmKey'],
        companyId = map['companyid'] ?? '',
        firstTImeLogin = map['firstTimeLogin'] ?? '';
  // Consistent with fallback

  // Helper method to update active users count
  static Future<void> incrementActiveUsers(String companyId) async {
    if (companyId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('userNode')
          .doc(companyId)
          .update({
        'activeusers': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing active users: $e');
      // Handle error or rethrow if needed
    }
  }
}
