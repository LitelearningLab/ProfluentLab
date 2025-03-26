import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'database/databaseProvider.dart';
import 'database/staticWordsDatabase/StaticWordsDatebaseProvider.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  StaticDatabaseProvider sdd = StaticDatabaseProvider.get;
  sdd.db();

  if (!kIsWeb) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Color(0xFF293750), statusBarColor: Color(0xFF293750)));
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Color(0xFF293750), statusBarColor: Color(0xFF293750)));
  }

  var configuredApp = new AppConfig(appName: 'PF DEV', flavorName: 'dev', fcmKey: '', child: MyApp());

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: configuredApp,
    ),
  );
}
