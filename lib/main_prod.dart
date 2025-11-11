import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/fcm.dart';
import 'package:litelearninglab/utils/notificationHelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'hiveDb/hiveDb.dart';
import 'hiveDb/new_interactive_simulator_hive_model.dart';
import 'hiveDb/new_interactive_simulator_hivedb.dart';
import 'hiveDb/new_process_hive_adapter.dart';
import 'main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails? notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("dkopdj d du");
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDGyQDDDN3dt7-jr3gSmCy12Ij24c25_Xs',
        appId: '1:620147953805:web:7e001c3a9822dc5cb752c4',
        messagingSenderId: '620147953805',
        projectId: 'lite-learning-lab',
        authDomain: 'lite-learning-lab.firebaseapp.com',
        databaseURL: 'https://lite-learning-lab.firebaseio.com',
        storageBucket: 'lite-learning-lab.appspot.com',
      ),
    );
    await Hive.initFlutter();
  } else {
    await Firebase.initializeApp();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    Hive.registerAdapter(ProcessLearningLinkAdapter());
    Hive.registerAdapter(ProcessLearningLinkHiveAdapter());
    Hive.registerAdapter(InteractiveLinkHiveAdapter());
    Hive.registerAdapter(InteractiveLinkAdapter());
  }

  FirebaseMessaging.onBackgroundMessage(Fcm.firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  if (!kIsWeb) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    /* SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top]);*/
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    /*SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xFF293750)));*/
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF293750),
        statusBarColor: Color(0xFF293750)));
  }

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);
  requestIOSPermissions(flutterLocalNotificationsPlugin);
  var configuredApp = new AppConfig(
      appName: 'Profluent AR', flavorName: 'prod', fcmKey: '', child: MyApp());
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: false);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: configuredApp,
    ),
  );
}
