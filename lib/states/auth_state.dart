import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/enums.dart';
import 'package:litelearninglab/main.dart';
import 'package:litelearninglab/models/Sentence.dart';
import 'package:litelearninglab/models/UserM.dart';
import 'package:litelearninglab/screens/dashboard/new_dashboard.dart';
import 'package:litelearninglab/screens/interactive_simulations/ar_call_simulations_screen.dart';
import 'package:litelearninglab/screens/interactive_simulations/interactive_screen.dart';
import 'package:litelearninglab/screens/performance_tracking/performance_tracking_screen.dart';
import 'package:litelearninglab/screens/process_learning/new_process_learning_screen.dart';
import 'package:litelearninglab/screens/process_learning/process_learning_screen.dart';
import 'package:litelearninglab/screens/profluent_english/new_profluent_english_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_english_modified_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_english_screen.dart';
import 'package:litelearninglab/screens/reports/call_flow_report.dart';
import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
import 'package:litelearninglab/screens/reports/speech_report.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/device_type.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../screens/reports/sound_wise_reports.dart';
import '../utils/auth_service.dart';
import '../utils/remote_config_service.dart';
import '../utils/utils.dart';

class AuthState with ChangeNotifier {
  User? _user;
  User? user1;
  UserM? _appUser;
  Status _status = Status.uninitialized;
  final streamController = StreamController<Status>();
  bool isShowCaseFinished = false;
  int subIndex = 0;
  bool checkAuth = false;
  bool isLoading = false;

  showCaseFunction() {
    isShowCaseFinished = true;
    notifyListeners();
  }

  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  final GlobalKey globalKeyFour = GlobalKey();
  final GlobalKey globalKeyFive = GlobalKey();
  final GlobalKey globalKeySix = GlobalKey();
  final GlobalKey globalKeySeven = GlobalKey();

  String? _eKey;
  final AuthService _authService = AuthService();
  RemoteConfigService? _remoteConfigService;

  AuthState() {
    streamController.add(_status);
    checkFunc();
  }

  checkFunc() async {
    print("check funcccc");
    await Future.delayed(Duration(milliseconds: 1700));

    // await Future.delayed(Duration(milliseconds: 1900), () {});
    checkAuthStatus();
  }

  FirebaseHelper db = new FirebaseHelper();

  bool get isLoggedIn => _user != null;

  Status get status => _status;

  User? get user => _user;

  UserM? get appUser => _appUser;

  String? get eKey => _eKey;

  User? get currentUser => _user;

  changingWalk() async {
    _status = Status.unauthenticated;
    streamController.add(_status);
    notifyListeners();
  }

  // Future<void> signInWithPhoneNumber(String phoneNumber, {required Function(String?) onVerificationId, required Function(String) onError}) async {
  //   await _authService.signInWithPhoneNumber(phoneNumber, onVerificationId: (val) {
  //     onVerificationId(val);
  //     if (_status == Status.unauthenticated || _status == Status.uninitialized || _status == Status.authenticating) {
  //       _status = Status.unauthenticated;
  //       streamController.add(_status);
  //       notifyListeners();
  //     }
  //   }, onError: onError);
  // }

  // Future<bool> signInWithSmsCode(String smsCode, String verificationId) async {
  //   bool result;
  //
  //   result = await _authService.signInWithSmsCode(smsCode, verificationId);
  //
  //   notifyListeners();
  //   return result;
  // }

  Stream<Status> get authStateChanges => streamController.stream;

  //----------------------------------------------------------------------
  bool isConnected = true;
  StreamSubscription? networkSubscription;
  Future<void> checkConnectivity(connectivityResult) async {
    print("d dpokdpjdk dd");
    connectivityResult = await (Connectivity().checkConnectivity());
    print("connectivoty res siresut : $connectivityResult");
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print("pisdi id u djd");
      isConnected = false;
    } else {
      print("dsld didu jidd");
      isConnected = true;
    }
    print('///////////////CONNECTION : : : $connectivityResult');
    print('///////////////CONNECTION : : : $isConnected');
    notifyListeners();
  }
  //----------------------------------------------------------------------

  void checkAuthStatus() async {
    print(" e eijii u ue yue");

    ///// dont delete below function
    /*await Connectivity().onConnectivityChanged.listen((result) async {
      print("dd idj iojjd uhdjda inside");
      print("prinit result : $result");
      await checkConnectivity(result);
      // _authService.authStateChanges.listen((User? user) async {
      checkAuth = await SharedPref.getSavedBool('checkingAuth');
      if (kDebugMode) {
        print("check auth checking");
        print(checkAuth);
      }
      _user = user;
      user1 = user;
      if (!isConnected) {
        print("d -d di jidj fuff dd dddddd");
        _status = Status.noNetwork;
      }
      else if (!checkAuth) {
        bool checking = await SharedPref.getSavedBool("walkthrough");
        if (checking) {
          print("d -d di jidj ssdd dsdsds");
          _status = Status.unauthenticated;
        } else {
          print("d -d di jidj dddddd");
          _status = Status.walkThrough;
        }
      }
      else {
        print("d -d di jidj fuff");
        _status = Status.authenticated;
        await login();
      }
      streamController.add(_status); // 9778795596
      notifyListeners();
      // });
    });*/

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      isConnected = true;
      notifyListeners();
      // _authService.authStateChanges.listen((User? user) async {
      checkAuth = await SharedPref.getSavedBool('checkingAuth');
      if (kDebugMode) {
        print("check auth checking");
        print(checkAuth);
      }
      _user = user;
      user1 = user;
      if (!isConnected) {
        print("d -d di jidj fuff dd dddddd");
        _status = Status.noNetwork;
      } else if (!checkAuth) {
        bool checking = await SharedPref.getSavedBool("walkthrough");
        bool isFirstTutorial = await SharedPref.getSavedBool("isFirstTutorial");
        if (!checking) {
          print("d -d di jidj dddddd");
          _status = Status.walkThrough;
        } else if (!isFirstTutorial) {
          print("d -d di jidj ssdd dsdsds");
          _status = Status.tutorial;
          //   await SharedPref.saveBool("isFirstTutorial", true);
        } else {
          print("d -d di jidj dddddd");
          _status = Status.unauthenticated;
        }
      } else {
        print("d -d di jidj fuff");
        _status = Status.authenticated;
        await login();
      }
      streamController.add(_status); // 9778795596
      notifyListeners();
      // });
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      print("dd idj iojjd uhdjda inside");
      isConnected = true;
      notifyListeners();
      // _authService.authStateChanges.listen((User? user) async {
      checkAuth = await SharedPref.getSavedBool('checkingAuth');
      if (kDebugMode) {
        print("check auth checking");
        print(checkAuth);
      }
      _user = user;
      user1 = user;
      if (!isConnected) {
        print("d -d di jidj fuff dd dddddd");
        _status = Status.noNetwork;
      } else if (!checkAuth) {
        bool checking = await SharedPref.getSavedBool("walkthrough");
        bool isFirstTutorial = await SharedPref.getSavedBool("isFirstTutorial");
        if (!checking) {
          print("d -d di jidj dddddd");
          _status = Status.walkThrough;
        } else if (!isFirstTutorial) {
          print("d -d di jidj ssdd dsdsds");
          _status = Status.tutorial;
          //  await SharedPref.saveBool("isFirstTutorial", true);
        } else {
          print("d -d di jidj dddddd");
          _status = Status.unauthenticated;
        }
      } else {
        print("d -d di jidj fuff");
        _status = Status.authenticated;
        await login();
      }
      streamController.add(_status); // 9778795596
      notifyListeners();
      // });
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      print("dd idj iojjd uhdjda inside");
      isConnected = true;
      notifyListeners();
      // _authService.authStateChanges.listen((User? user) async {
      checkAuth = await SharedPref.getSavedBool('checkingAuth');
      if (kDebugMode) {
        print("check auth checking");
        print(checkAuth);
      }
      _user = user;
      user1 = user;
      if (!isConnected) {
        print("d -d di jidj fuff dd dddddd");
        _status = Status.noNetwork;
      } else if (!checkAuth) {
        bool checking = await SharedPref.getSavedBool("walkthrough");
        bool isFirstTutorial = await SharedPref.getSavedBool("isFirstTutorial");
        if (!checking) {
          print("d -d di jidj dddddd");
          _status = Status.walkThrough;
        } else if (!isFirstTutorial) {
          print("d -d di jidj ssdd dsdsds");
          _status = Status.tutorial;
          // await SharedPref.saveBool("isFirstTutorial", true);
        } else {
          print("d -d di jidj dddddd");
          _status = Status.unauthenticated;
        }
      } else {
        print("d -d di jidj fuff");
        _status = Status.authenticated;
        await login();
      }
      streamController.add(_status); // 9778795596
      notifyListeners();
      // });
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      isConnected = false;
      notifyListeners();
    }

    await Connectivity().onConnectivityChanged.listen((result) async {
      print("dd idj iojjd uhdjda inside");
      print("prinit result : $result");
      await checkConnectivity(result);
      // _authService.authStateChanges.listen((User? user) async {
      checkAuth = await SharedPref.getSavedBool('checkingAuth');
      if (kDebugMode) {
        print("check auth checking");
        print(checkAuth);
      }
      _user = user;
      user1 = user;
      if (!isConnected) {
        print("d -d di jidj fuff dd dddddd");
        _status = Status.noNetwork;
      } else if (!checkAuth) {
        bool checking = await SharedPref.getSavedBool("walkthrough");
        bool isFirstTutorial = await SharedPref.getSavedBool("isFirstTutorial");
        if (!checking) {
          print("d -d di jidj dddddd");
          _status = Status.walkThrough;
        } else if (!isFirstTutorial) {
          print("d -d di jidj ssdd dsdsds");
          _status = Status.tutorial;
          //  await SharedPref.saveBool("isFirstTutorial", true);
        } else {
          print("d -d di jidj dddddd");
          _status = Status.unauthenticated;
        }
      } else {
        print("d -d di jidj fuff");
        _status = Status.authenticated;
        await login();
      }
      streamController.add(_status); // 9778795596
      notifyListeners();
      // });
    });
  }

  login() async {
    String phoneNo = await SharedPref.getSavedString("phoneNo");
    await getAppUser(phoneNo);
    String uid = await Utils.getUUID();
    if (_appUser == null && isConnected) {
      print("dd 90d 80 d8 yd8yd80yd");
      _status = Status.userNotExist;
    } else if ((_appUser!.imei == null || _appUser!.imei == uid || _appUser!.imei!.isEmpty) &&
            // _appUser!.status!.toLowerCase() == "active" ||
            _appUser!.status == "1"
        // _appUser!.status?.toLowerCase() == "1"

        ) {
      print("dd 90d 80 d8 dhdhdhdhdhd");
      String model = await DeviceScreenInfo.getModelName();

      await db.setUserImei(uid, model, _appUser!.id!);
      _appUser?.imei = uid;
      _appUser?.model = model;
      _status = Status.authenticated;

      _remoteConfigService = await RemoteConfigService.getInstance();
      await _remoteConfigService?.initialize();

      _eKey = _remoteConfigService?.getStringValue;
    } else if ((_appUser!.imei == null || _appUser!.imei == uid || _appUser!.imei!.isEmpty) &&
        // _appUser!.status!.toLowerCase() == "inactive" ||
        _appUser!.status == "2") {
      print("dd 90d 80 d8 dhd id id d d");
      _status = Status.userInactive;
    } else {
      print("dd 90d 80 d8  dk d djdbdhdii");
      _status = Status.deviceChanged;
    }
  }

  checkAuthChanging() async {
    // print("s dud hyd yd hyddhd hjyd hd");
    _status = Status.authenticated;
    // print("_status : $status");

    await SharedPref.saveBool('checkingAuth', true);
    streamController.add(_status);
    // checkAuthStatus();
    notifyListeners();
  }

  Future<void> tutorialCheck() async {
    print("tutorial Check function calleddd");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTimeUser = await prefs.getBool('firstTimeUser') ?? true;

    if (firstTimeUser) {
      _status = Status.tutorial;
      streamController.add(_status);
      // checkAuthStatus();

      await prefs.setBool('firstTimeUser', false);
      firstTimeUser = await prefs.getBool('firstTimeUser') ?? false;
      // checkAuthStatus();
    } else {
      _status = Status.authenticated;
      streamController.add(_status);
      // checkAuthStatus(); // Uncommented
    }
    notifyListeners();
  }

  setAppUser(UserM user) async {
    _appUser = user;
    notifyListeners();
  }

  setEKey(String key) async {
    _eKey = key;
    notifyListeners();
  }

  Future signOut() async {
    // await _authService.signOut();
    _status = Status.unauthenticated;
    print("status : $_status");
    try {
      _user = null;
      _appUser = null;
    } catch (e) {
      print("signout error : $e");
    }
    print("_user : $_user");
    print("_appUser : $_appUser");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await SharedPref.saveBool("walkthrough", true);
    await SharedPref.saveBool('isFirst', true);
    await SharedPref.saveBool('checkingAuth', false);
    await SharedPref.saveBool('firstTimeUser', false);

    // checkAuthStatus();
    print("sign out button clickeddd");
    streamController.add(_status);
    notifyListeners();
  }

  Future<UserM?> getAppUser(String phoneNo) async {
    _appUser = await db.getUser(phoneNo);
    if (kDebugMode) {
      log("app id showing");
      log("${_appUser!.id}");
    }
    await SharedPref.saveString("userId", _appUser?.id ?? "");
    log("iejfiig:${_appUser?.id ?? "revathi"}");
    return _appUser;
  }

  //---------------------------------------------------------

  bool? isAudioDone;
  bool? isDownloaded;

  /// BOTTOM NAVIGATION
  int currentIndex = 0;

  void changeIndex(int index) async {
    currentIndex = index;
    await stopTimerMainCategory();
    await stopTimerSubCategory();
    notifyListeners();
  }

  void changeSubIndex(int index) {
    subIndex = index;
    notifyListeners();
  }

  List<Widget> pages = [
    NewDashboardScreen(),
    NewProcessLearningScreen(iconKey: false),
    ARCallSimulationScreen(ARIconKey: false),
    ProfluentEnglishModifiedScreen(PEIconKey: false),
    //NewProfluentEnglishScreen(),
    PerformanceTrackingScreen(),
  ];

  int tabarIndex = 0;
  void changeTabarIndex(int index) {
    tabarIndex = index;
    notifyListeners();
  }

  List<Map<String, dynamic>> pronunciationLabList = [
    {
      'title': 'Days, Dates, Months & Numbers',
      'load': 'daysdates',
      'menuText': 'Days, Dates, Months & Numbers',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plDays,
      'bgColor': Color(0xFF5370D4),
    },
    {
      'title': 'Letters Of The English Alphabet',
      'load': 'Latters and NATO',
      'menuText': 'Letters Of The English Alphabet',
      'backgroundImage': AllAssets.back2,
      'image': AllAssets.plLetters,
      'bgColor': Color(0xFF3DBAD3),
    },
    {
      'title': 'US States & Cities',
      'load': 'States and Cities',
      'menuText': 'US States & Cities',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plUSState,
      'bgColor': Color(0xFF0190FE),
    },
    {
      'title': 'Common American Names',
      'load': 'ProcessWords',
      'menuText': 'Common American Names',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plCommon,
      'bgColor': Color(0xFFFF6548),
    },
    {
      'title': 'Most Commonly Used Words',
      'load': 'CommonWords',
      'menuText': 'Most Commonly Used Words',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plMostCommon,
      'bgColor': Color(0xFF8540C8),
    },
    {
      'title': 'US Healthcare - Revenue Cycle Management',
      'load': 'US Healthcare',
      'menuText': 'US Healthcare - Revenue Cycle Management',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plUSState,
      'bgColor': Color(0xFFFDA500),
    },
    {
      'title': 'Restaurant, Hotel & Travel',
      'load': 'Restaurant Hotel Travel',
      'menuText': 'Restaurant, Hotel & Travel',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plRestaurant,
      'bgColor': Color(0xFF5146FF),
    },
    {
      'title': 'Business Words',
      'load': 'Business Words',
      'menuText': 'Business Words',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plBusiness,
      'bgColor': Color(0xFF5370D4),
    },
    {
      'title': 'Information Technology',
      'load': 'Information Technology',
      'menuText': 'Information Technology',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.plIT,
      'bgColor': Color(0xFF3DBAD3),
    },
  ];

  List<Map<String, dynamic>> sentenceConstructionLabList = [
    {
      'title': 'Professional Call Procedures',
      'load': 'Professional Call Procedures',
      'menuText': 'Professional Call Procedures',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.slPcp,
      'bgColor': Color(0xFF5370D4),
    },
    {
      'title': 'Questions Lab',
      'load': 'Questions Lab',
      'menuText': 'Questions Lab',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.slQl,
      'bgColor': Color(0xFF3DBAD3),
    },
    {
      'title': 'Frequent Scenarios',
      'load': 'Samples for frequent scenarios',
      'menuText': 'Frequent Scenarios',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.slFs,
      'bgColor': Color(0xFF0190FE),
    },
  ];

  List<Map<String, dynamic>> callFlowPracticeLabList = [
    {
      'title': 'Denial Management',
      'load': 'Denial Management',
      'menuText': 'Denial Management',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.cflDm,
      'bgColor': Color(0xFF5370D4),
    },
    {
      'title': 'Non-Denials Follow-up',
      'load': 'Non Denials Follow up',
      'menuText': 'Non-Denials Follow-up',
      'backgroundImage': AllAssets.back1,
      'image': AllAssets.cflNdfu,
      'bgColor': Color(0xFF3DBAD3),
    },
  ];

  List<Map<String, dynamic>> labReports = [
    {'title': 'Pronunciation Lab report', 'icon': AllAssets.ptIcon, "page": PronunciationReport(), 'bgColor': Color(0xFF5370D4)},
    {'title': 'Sentence Lab report', 'icon': AllAssets.ptIcon, "page": SpeechReport(), 'bgColor': Color(0xFF3DBAD3)},
    {'title': 'Call flow practise report', 'icon': AllAssets.ptIcon, "page": CallFlowReport(), 'bgColor': Color(0xFFD6B140)},
    {'title': 'Sound-wise Report', 'icon': AllAssets.ptIcon, "page": SoundWiseReportScreen(), 'bgColor': Color(0xFFDC6379)},
  ];

  List<Map<String, dynamic>> softSkillData = [
    {'icon': AllAssets.corporate, 'color': Color(0xFF0190FE)},
    {'icon': AllAssets.arCalls, 'color': Color(0xFFFF6548)}, // icon needed
    {'icon': AllAssets.hipaa, 'color': Color(0xFF2CBBE7)}, // icon needed
    {'icon': AllAssets.ssBtg, 'color': Color(0xFF5146FF)},
    {'icon': AllAssets.ssEe, 'color': Color(0xFF5370D4)},
    {'icon': AllAssets.ssFtl, 'color': Color(0xFF2CBBE7)},
    {'icon': AllAssets.ssMe, 'color': Color(0xFFFF6548)},
    {'icon': AllAssets.ssSg, 'color': Color(0xFFFDA500)},
    {'icon': AllAssets.ssMsw, 'color': Color(0xFF5146FF)},
    {'icon': AllAssets.ssMsp, 'color': Color(0xFF5370D4)},
    {'icon': AllAssets.ssMse, 'color': Color(0xFF0190FE)},
    {'icon': AllAssets.ssBo, 'color': Color(0xFF2CBBE7)},
    {'icon': AllAssets.ssSm, 'color': Color(0xFFFF6548)},

    /* {'icon': AllAssets.ssBtg, 'color': Color(0xFF5146FF)},//newly added
    {'icon': AllAssets.ssBtg, 'color': Color(0xFF5146FF)}, // newly added
    {'icon': AllAssets.ssBtg, 'color': Color(0xFF5146FF)}, //1 // go to person
    {'icon': AllAssets.ssEe, 'color': Color(0xFF5370D4)}, //2  // effective emails
    {'icon': AllAssets.ssCtc, 'color': Color(0xFF0190FE)}, //3 // campus to corporate
    {'icon': AllAssets.ssFtl, 'color': Color(0xFF2CBBE7)}, //4  // first time leaders
    {'icon': AllAssets.ssMe, 'color': Color(0xFFFF6548)}, //5  // meeting etiquette
    {'icon': AllAssets.ssSg, 'color': Color(0xFFFDA500)}, //6  // smart goals
    {'icon': AllAssets.ssMsw, 'color': Color(0xFF5146FF)}, //7  // ms words basics
    {'icon': AllAssets.ssMsp, 'color': Color(0xFF5370D4)}, //8  // ms powerpoint basic
    {'icon': AllAssets.ssMse, 'color': Color(0xFF0190FE)}, //9  // ms excel basics
    {'icon': AllAssets.ssBo, 'color': Color(0xFF2CBBE7)}, //10  // being orgainised prompt
    {'icon': AllAssets.ssSm, 'color': Color(0xFFFF6548)}, //11  // stress management*/
  ];

  List<Map<String, dynamic>> grammarCheckLabList = [
    {
      'title': 'Parts of Speech',
      'load': 'Parts of Speech',
      'menuText': 'Parts of Speech',
      'backgroundImage': AllAssets.back1,
      'image': 'assets/images/Grammar_Lab_Main_Page_List_Icon.png',
      'bgColor': Color(0xFF5370D4),
    },
    {
      'title': 'Tenses',
      'load': 'Tenses',
      'menuText': 'Tenses',
      'backgroundImage': AllAssets.back1,
      'image': 'assets/images/Grammar_Lab_Main_Page_List_Icon.png',
      'bgColor': Color(0xFF3DBAD3),
    },
    {
      'title': 'Sentence Structure',
      'load': 'Sentence Structure',
      'menuText': 'Sentence Structure',
      'backgroundImage': AllAssets.back1,
      'image': 'assets/images/Grammar_Lab_Main_Page_List_Icon.png',
      'bgColor': Color(0xFF0190FE),
    },
  ];

  int expandedIndex = -1;

  void changeExpansion(bool expanded, int index) {
    print("indexcheck':${index}");
    expandedIndex = expanded ? index : -1;

    if (expanded) {
      expandedIndex = index;
      print("expandedINDex:${expandedIndex}");
    } else if (expandedIndex == index) {
      expandedIndex = -1;
    }
    notifyListeners();
  }

  bool isExpanded(int index) {
    print("index: ${index}");
    if (expandedIndex == index) {
      notifyListeners();
      return true;
    } else {
      // notifyListeners();
      return false;
    }
  }

  int selectedIndex = 0;
  changeIndexofCardSwipe(int? newIndex) {
    selectedIndex = newIndex ?? 0;
    notifyListeners();
  }

  //background download
  bool isconnected = true;
  bool isAllDownloaded = false;
  // bool isDownloading = false;
  List<Sentence> followUps = [];
  bool isDownloadError = false;
  setIsConnected({required bool isConnected}) {
    isconnected = isConnected;
    notifyListeners();
  }

  setIsAllDownloaded({required bool isallDownloaded}) {
    isAllDownloaded = isallDownloaded;
    notifyListeners();
  }

  // setIsDownloading({required bool isdownloading}) {
  //   isDownloading = isdownloading;
  //   notifyListeners();
  // }

  setIsDownloadError({required bool isDownloadedError}) {
    isDownloadError = isDownloadedError;
    notifyListeners();
  }
}
