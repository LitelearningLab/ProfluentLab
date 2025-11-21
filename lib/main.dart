import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:litelearninglab/hiveDb/hiveDb.dart';
import 'package:litelearninglab/hiveDb/new_interactive_simulator_hive_model.dart';
import 'package:litelearninglab/hiveDb/new_interactive_simulator_hivedb.dart';
import 'package:litelearninglab/hiveDb/new_process_hive_adapter.dart';
import 'package:litelearninglab/screens/dashboard/school_dashboard.dart';
import 'package:litelearninglab/screens/login/new_login_screen.dart';
import 'package:litelearninglab/screens/login/unauth_screen.dart';
import 'package:litelearninglab/screens/process_learning/indicator_controller.dart';
import 'package:litelearninglab/screens/slpash_screens/splash_screen.dart';
import 'package:litelearninglab/screens/tutorial/tutorial_screen.dart';
import 'package:litelearninglab/screens/walkthrough_screens/walkthrough_screens.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/fcm.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'config/app_config.dart';
import 'constants/enums.dart';
import 'constants/keys.dart';

const Map<int, Color> colorSwatch = {
  50: Color(0xFF293750),
  100: Color(0xFF293750),
  200: Color(0xFF293750),
  300: Color(0xFF293750),
  400: Color(0xFF293750),
  500: Color(0xFF293750),
  600: Color(0xFF293750),
  700: Color(0xFF293750),
  800: Color(0xFF293750),
  900: Color(0xFF293750),
};
List<String> loadsFrom = [];
final MaterialColor customColor = MaterialColor(0xFF293750, colorSwatch);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("hejeo e hh uh ");
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

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF293750),
      statusBarColor: Color(0xFF293750)));
  var configuredApp = new AppConfig(
      appName: 'Profluent', flavorName: 'prod', fcmKey: '', child: MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => IndiactorController()),
      ],
      child: configuredApp,
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (count > 0) {
        recordTiming("Paused");
      }
      log("User navigated to another app or attended a call.${count}");
    } else if (state == AppLifecycleState.resumed) {
      startTimings = DateTime.now();
      resume = true;
      subResume = true;
      log("User returned to the app.");
    }
  }

  Widget build(BuildContext context) {
    Fcm.getInstance(context)?.initConfigure();
    // checkUserAndCompanyStatus(context);
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Color(0xFF293750)));
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profluent AR',
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFF293750),
          fontFamily: Keys.fontFamily,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
          primaryColor: Color(0xFF293750),
          primaryIconTheme:
              Theme.of(context).primaryIconTheme.copyWith(color: Colors.black),
          primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
                bodyColor: Colors.black,
                fontFamily: Keys.fontFamily,
              ),
          textTheme: TextTheme(
            bodyLarge: Theme.of(context).textTheme.bodyLarge?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            bodyMedium: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            labelLarge: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            displayLarge: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            displayMedium: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            displaySmall: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            headlineMedium: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            headlineSmall: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            titleLarge: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            titleMedium: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            titleSmall: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            bodySmall: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
            labelSmall: Theme.of(context).textTheme.bodyMedium?.merge(
                  TextStyle(
                    fontFamily: Keys.fontFamily,
                  ),
                ),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: customColor)
              .copyWith(secondary: customColor),
          scrollbarTheme: ScrollbarThemeData().copyWith(
            thumbColor: WidgetStateProperty.all(Colors.white),
            thumbVisibility: WidgetStateProperty.all<bool>(true),
          )),
      home: AuthWrapper(),
      scrollBehavior: RemoveGlowEffect(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppConfig? config = AppConfig.of(context);
    final authProvider = Provider.of<AuthState>(context);
    ToastContext().init(context);
    return StreamBuilder<Status>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen if the authentication state is still unknown
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: Colors.white)));
        } else {
          print("shdofofaoufaf : ${snapshot.data}");

          switch (snapshot.data) {
            case Status.authenticated:
              return config?.flavorName == "english"
                  ? SchoolDashboard()
                  : BottomNavigation();
            case Status.tutorial:
              return TutorialScreen(
                url: 'assets/mp4_video/video_20241022_115109_check.mp4',
              );
            case Status.walkThrough:
              return !kIsWeb ? WalkThroughView() : NewLoginScreen();
            case Status.unauthenticated:
              return NewLoginScreen();
            case Status.userNotExist:
              return UnauthScreen(
                text:
                    'USER NOT EXISTS!, Please contact administrator for more details.',
              );
            case Status.userInactive:
              return UnauthScreen(
                text:
                    'USER NOT ACTIVE!, Please contact administrator for more details',
              );
            case Status.deviceChanged:
              return UnauthScreen(
                text:
                    'DEVICE NOT AUTHORIZED!, Please login from the registered device. \nOR \nIf you are unable to access from the registered device, your account is probably disabled, please contact administrator for more details.',
              );
            case Status.noNetwork:
              return UnauthScreen(
                text: 'Please Check Your Network Connection',
              );
            default:
              return SplashScreen();
          }
        }
      },
    );
  }
}

class RemoveGlowEffect extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
