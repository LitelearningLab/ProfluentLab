import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import '../main_prod.dart';
import 'notificationHelper.dart';

class Fcm {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // static final Fcm _instance = Fcm._(_context);
  //
  // Fcm._(BuildContext context);
  //
  // static Fcm get instance => _instance;
  // Fcm({this.mContext});
  //
  // static Fcm getInstance({context}) {
  //   if (_instance == null) {
  //     _instance = Fcm(context);
  //     return _instance;
  //   }
  //   return _instance;
  // }
  //
  final BuildContext? mContext;

  Fcm(
    this.mContext,
  );

  static Fcm? _instance;

  static Fcm? getInstance(BuildContext context) {
    if (_instance == null) {
      _instance = Fcm(context);
      return _instance;
    }
    return _instance;
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  Future<void> initConfigure() async {
    // _context = context;
    if (Platform.isIOS) _iosPermission();

    _fcm.requestPermission();
    _fcm.setAutoInitEnabled(true);
    _fcm.getInitialMessage().then((value) => print(value));

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print("getInitialMessage");
      print("fcm message : $message");
      // Provider.of<GlobalState>(mContext!, listen: false)
      //     .getNotifications(mContext!);
    });
    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage");
      print(message.data);
      showNotification(flutterLocalNotificationsPlugin,
          message.notification?.title ?? "", message.notification?.body ?? "");
      // Provider.of<GlobalState>(mContext!, listen: false)
      //     .getNotifications(mContext!);
    });*/

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage");
      print(message.data);
      print("messageTitle:${message.notification?.title}");
      print("messageNotificationBody: ${message.notification?.body}");
      print("messageImageUrl: ${message.data["image"]}");
      showNotification(
          flutterLocalNotificationsPlugin, message.notification?.title ?? "", message.notification?.body ?? "",
          imageUrl: message.data["image"]);
      // Provider.of<GlobalState>(mContext!, listen: false)
      //     .getNotifications(mContext!);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    try {
      await _fcm.getToken().then((String? token) async {
        assert(token != null);
        // var context = NavigationService.navigatorKey.currentContext!;
        // var state = Provider.of<GlobalState>(context, listen: false);
        // state.fcmToken = token;
        // String savedFcm = await MyPreference.getStringToSF(MyPreference.fcmId);
        // if (kDebugMode) {
        //   print(token);
        // }
        // if (token != null && savedFcm != token) {
        //   await MyPreference.addStringToSF(MyPreference.fcmId, token);
        //   state.saveToken(token);
        // } else if (token != null) {
        //   await MyPreference.addStringToSF(MyPreference.fcmId, token);
        // }
      });
    } catch (error, stacktrace) {
      print(error);
      // ErrorReporter.recordError(error, stacktrace, reason: ' _fcm.getToken()');
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {}

  static _iosPermission() {
    _fcm.requestPermission(
        // IosNotificationSettings(sound: true, badge: true, alert: true)
        );
  }
}
