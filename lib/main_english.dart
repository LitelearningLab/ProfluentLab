import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/fcm.dart';
import 'package:litelearninglab/utils/notificationHelper.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(Fcm.firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  if (!kIsWeb) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Color(0xFF293750)));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF293750),
        statusBarColor: Color(0xFF293750)));
  }

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);
  requestIOSPermissions(flutterLocalNotificationsPlugin);
  var configuredApp = new AppConfig(
      appName: 'Profluent English',
      flavorName: 'english',
      fcmKey: '',
      child: MyApp());
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: configuredApp,
    ),
  );
}
