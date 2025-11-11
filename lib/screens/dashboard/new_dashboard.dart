import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/InteracticeSimulationMain.dart';
import 'package:litelearninglab/models/ProcessLearningMain.dart';
// import 'package:litelearninglab/screens/call_flow/call_flow_cat_screen.dart';
import 'package:litelearninglab/screens/dashboard/showcase_model.dart';
import 'package:litelearninglab/screens/dashboard/widgets/first_row_menu.dart';
import 'package:litelearninglab/screens/dashboard/widgets/quick_links_tile.dart';
import 'package:litelearninglab/screens/process_learning/process_cat_screen.dart';
import 'package:litelearninglab/screens/profluent_english/lab_screen.dart';
import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
import 'package:litelearninglab/screens/reports/speech_report.dart';
import 'package:litelearninglab/screens/sentences/sentences_screen.dart';
import 'package:litelearninglab/screens/softskills/new_softskills_screen.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:toast/toast.dart';
import 'package:upgrader/upgrader.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_drawer.dart';
import '../../hiveDb/hiveDb.dart';
import '../../hiveDb/new_interactive_simulator_hivedb.dart';
import '../../models/InteractiveLink.dart';
import '../../models/ProcessLearningLink.dart';
import '../../utils/bottom_navigation.dart';
import '../../utils/firebase_helper.dart';
import '../call_flow/follow_up_screen.dart';
import '../interactive_simulations/interactive_cat_screen.dart';
import '../reports/call_flow_report.dart';
import '../sentences/sentence_screen.dart';
import '../webview/webview_screen.dart';

class NewDashboardScreen extends StatefulWidget {
  NewDashboardScreen({Key? key}) : super(key: key);

  @override
  _NewDashboardScreenState createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen>
    with AfterLayoutMixin<NewDashboardScreen> {
  bool OneTimeShowCase = false;
  bool isFirstTimeUserDashboard = true;

  bool isLoadingShowCase = false;
  bool _isProMenuOpen = false;
  bool _isSentMenuOpen = false;
  bool _isCallMenuOpen = false;
  bool _isPerMenuOpen = false;
  bool _isProcessLearningFromDScreen = false;
  List<ProcessLearningMain> _processLeaning = [];
  FirebaseHelper db = new FirebaseHelper();
  bool _isLoading = true;
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _menuBarKey = GlobalKey();
  final GlobalKey _lastPageKey = GlobalKey();
  final GlobalKey _processLearningKey = GlobalKey();
  final GlobalKey _arCallKey = GlobalKey();
  final GlobalKey _proFluentEnglishKey = GlobalKey();
  final GlobalKey _performanceTracking = GlobalKey();

  ScrollController _scrollController = new ScrollController();
  late AuthState user;
  List<InteracticeSimulationMain> _categories = [];

  Future<void> _checkFirstTimeUser() async {
    _isLoading = true;
    print("check first time user function calleddsffef");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTimeUserDashboard') ?? true;
    print("isFirtTimefee:$isFirstTime");
    if (!isFirstTime) {
      print("sdjgdvdevij");
      setState(() {
        isFirstTimeUserDashboard = false;
        print("isFirstTimeUserDashboard:${isFirstTimeUserDashboard}");
      });
    }
    _isLoading = false;
  }

  Future<void> _setFirstTimeUser() async {
    print("set First Time User Functicfvdvvon called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeUserDashboard', false);
    setState(() {
      isFirstTimeUserDashboard = false;
      print("isFirstTimeUserDashboard updated: $isFirstTimeUserDashboard");
    });
  }

  @override
  void initState() {
    super.initState();
    user = Provider.of<AuthState>(context, listen: false);

    print("blackkk screenn");
    getAppUser();
    print("grey screenn");
    //_checkFirstTimeUser();
    /* WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        ShowCaseWidget.of(context).startShowCase([
          _profileKey,
          _menuBarKey,
          _homeKey,
          _processLearningKey,
        ]);
      });
    });*/
  }

  getAppUser() async {
    _isLoading = true;
    setState(() {});

    String userId = await SharedPref.getSavedString("userId");

    if (userId == "") {
      await user.login();
    }
    await _getWords();
  }

  refresh() {
    print("dkd di jdi diddhduh");
    user = Provider.of<AuthState>(context, listen: false);
    _getWords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void dispose() {
    super.dispose();
  }

  String capitalizeFirstLetter(String? s) {
    if (s == null || s.isEmpty) {
      return '';
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  void exitPopup(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        var controller = Provider.of<AuthState>(context, listen: false);
        return AlertDialog(
          insetPadding:
              EdgeInsets.only(left: kWidth / 32.35, right: kWidth / 32.75),
          actionsPadding: EdgeInsets.only(
              right: kWidth / 26.2,
              left: kWidth / 26.2,
              bottom: kHeight / 28.4),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            'Exit',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          content: Text(
            'Are you sure want to exit from app?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          actions: [
            SizedBox(
              width: kWidth / 2.5,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: kText.scale(15)),
                  )),
            ),
            SizedBox(
              width: kWidth / 2.5,
              child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.white),
                      side: MaterialStatePropertyAll(
                          BorderSide(width: 1, color: Colors.green))),
                  child: Text('Exit',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: kText.scale(15)))),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Color(0XFF293750),
        );
      },
    );
  }

  _getWords() async {
    print("getWords Calleddd");
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getInteractiveSimuations();
    _categories = _categories.reversed.toList();
    _processLeaning = [];
    _processLeaning = await db.getProcessLearning();
    _processLeaning = _processLeaning.reversed.toList();
    // isPlaying = List.generate(_processLeaning.length, (index) => false);
    _isLoading = false;
    setState(() {});
  }

  List<Map<String, dynamic>> decodeListFromJson(String jsonString) {
    List<Map<String, dynamic>> decodedList =
        List<Map<String, dynamic>>.from(jsonDecode(jsonString));

    // Convert hex color strings back to Color objects
    return decodedList.map((map) {
      return map.map((key, value) {
        if (value is String && RegExp(r'^ff[0-9a-fA-F]{6}$').hasMatch(value)) {
          return MapEntry(key, Color(int.parse(value, radix: 16)));
        } else {
          return MapEntry(key, value);
        }
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final authController = Provider.of<AuthState>(context, listen: false);
    final isDashboardScreen =
        Provider.of<AuthState>(context, listen: false).currentIndex == 0;
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        exitPopup(context);
      },
      child: UpgradeAlert(
        dialogStyle: kIsWeb
            ? UpgradeDialogStyle.material
            : Platform.isAndroid
                ? UpgradeDialogStyle.material
                : UpgradeDialogStyle.cupertino,
        showReleaseNotes: false,
        showIgnore: false,
        shouldPopScope: () => true,
        upgrader: Upgrader(
          messages: UpgraderMessages(),
        ),
        child: _isLoading == false
            ? ShowCaseWidget(
                autoPlay: false,
                builder: (BuildContext context) {
                  return BackgroundWidget(
                      scaffoldKey: _scaffoldKey,
                      drawer: CommonDrawer(),
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: getWidgetWidth(width: 20),
                              right: getWidgetWidth(width: 20),
                              top: isSplitScreen
                                  ? getFullWidgetHeight(height: 20)
                                  : getWidgetHeight(height: 20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SPH(displayHeight(context) / 81.2),
                              SizedBox(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 11)
                                    : getWidgetHeight(height: 11),
                              ),
                              Container(
                                // height: size.height / 5,
                                // width: size.width,
                                // color: Colors.grey,
                                // height: isSplitScreen ? getFullWidgetHeight(height: 106) : getWidgetHeight(height: 106),
                                // padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("PROFLUENT",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: kText.scale(26),
                                                fontFamily: "Quicksand",
                                                letterSpacing: 2)),
                                        // SizedBox(width: 5),
                                        Container(
                                            height: 40,
                                            child: Image.asset(
                                                "assets/images/profluent_ar_icon.png",
                                                height: isSplitScreen
                                                    ? getFullWidgetHeight(
                                                        height: 35)
                                                    : getWidgetHeight(
                                                        height: 35),
                                                width: kIsWeb
                                                    ? 45
                                                    : getWidgetWidth(
                                                        width: 35))),
                                        const Spacer(),
                                        ShowCaseView(
                                          globalKey: _menuBarKey,
                                          title: '',
                                          description: 'Dashboard',
                                          child: InkWell(
                                              onTap: () {
                                                _scaffoldKey.currentState
                                                    ?.openEndDrawer();
                                              },
                                              child: Image.asset(
                                                AllAssets.drawerIcon,
                                                height: isSplitScreen
                                                    ? getFullWidgetHeight(
                                                        height: 24)
                                                    : getWidgetHeight(
                                                        height: 24),
                                                width: kIsWeb
                                                    ? 30
                                                    : getWidgetWidth(width: 24),
                                                fit: BoxFit.fill,
                                              )
                                              // Icon(
                                              //   Icons.menu,
                                              //   size: 30,
                                              //   color: Colors.white,
                                              // ),
                                              ),
                                        ),
                                      ],
                                    ),
                                    /*SizedBox(
                                height: isSplitScreen ? getFullWidgetHeight(height: 11) : getWidgetHeight(height: 11),
                              ),*/
                                    SPH(displayHeight(context) / 58),
                                    SizedBox(
                                        height: isSplitScreen
                                            ? getFullWidgetHeight(height: 46)
                                            : getWidgetHeight(height: 46),
                                        child: TextFormField(
                                          readOnly: true,
                                          keyboardType: TextInputType.text,
                                          //controller: controller,
                                          style: TextStyle(
                                            fontFamily: Keys.fontFamily,
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            letterSpacing: 0.3334423928571427,
                                          ),
                                          decoration: new InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide.none,
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide.none,
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: ShowCaseView(
                                              globalKey: _lastPageKey,
                                              title: '',
                                              description:
                                                  'Click here For Go to Last Accessed Content',
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                    height: kHeight / 54.1,
                                                    width: kIsWeb
                                                        ? 80
                                                        : kWidth / 6.2,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFF6C63FE),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        SharedPreferences
                                                            prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String
                                                            lastAccessContent =
                                                            await prefs.getString(
                                                                    'lastAccess') ??
                                                                "";
                                                        var hiveBox =
                                                            await Hive.openBox(
                                                                'lastAccess');
                                                        print(
                                                            "last access content : $lastAccessContent");
                                                        if (lastAccessContent ==
                                                            'FollowUpScreen') {
                                                          List followupString =
                                                              await prefs.getStringList(
                                                                      'FollowUpScreen') ??
                                                                  [];
                                                          print(
                                                              "follow up String : $followupString");
                                                          print(
                                                              "last search content FollowUpScreen");
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FollowUpScreen(
                                                                            user:
                                                                                Provider.of<AuthState>(context, listen: false),
                                                                            title:
                                                                                followupString[0],
                                                                            load:
                                                                                followupString[1],
                                                                            main:
                                                                                followupString[2],
                                                                          )));
                                                        } else if (lastAccessContent ==
                                                            'NewSoftSkillsScreen') {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          NewSoftSkillsScreen()));
                                                        } else if (lastAccessContent ==
                                                            'LabScreen') {
                                                          List labScreenString =
                                                              await prefs.getStringList(
                                                                      'LabScreen') ??
                                                                  [];
                                                          List<dynamic>
                                                              decodedList =
                                                              jsonDecode(
                                                                  labScreenString[
                                                                      1]);

                                                          final List<
                                                                  Map<String,
                                                                      dynamic>>
                                                              originalDataList =
                                                              decodedList
                                                                  .map((map) {
                                                            return (map as Map<
                                                                    String,
                                                                    dynamic>)
                                                                .map((key,
                                                                    value) {
                                                              if (key ==
                                                                      'bgColor' &&
                                                                  value
                                                                      is String) {
                                                                return MapEntry(
                                                                    key,
                                                                    Color(int.parse(
                                                                        value))); // Convert back to Color object
                                                              } else {
                                                                return MapEntry(
                                                                    key, value);
                                                              }
                                                            });
                                                          }).toList();
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) => LabScreen(
                                                                  pLIconKey: labScreenString[
                                                                              2] ==
                                                                          'true'
                                                                      ? true
                                                                      : false,
                                                                  user: user,
                                                                  title:
                                                                      labScreenString[
                                                                          0],
                                                                  itemList:
                                                                      originalDataList),
                                                            ),
                                                          );
                                                        } else if (lastAccessContent ==
                                                            'ProcessCatScreen') {
                                                          String
                                                              processCatScreenScreenString =
                                                              await prefs.getString(
                                                                      'ProcessCatScreen') ??
                                                                  "";
                                                          final box = await Hive
                                                              .openBox<
                                                                      ProcessLearningLinkHive>(
                                                                  'newProcessLearningBox');
                                                          ProcessLearningLinkHive?
                                                              getPr = box.get(
                                                                  'ProcessCatScreen');
                                                          List<ProcessLearningLink>?
                                                              ans = getPr!.item;
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProcessCatScreen(
                                                                          linkCats:
                                                                              ans!,
                                                                          title:
                                                                              processCatScreenScreenString,
                                                                        )),
                                                          );
                                                        } else if (lastAccessContent ==
                                                            'CallFlowCatScreen') {
                                                          List
                                                              CallFlowCatScreenString =
                                                              await prefs.getStringList(
                                                                      'CallFlowCatScreen') ??
                                                                  [];
                                                          print(
                                                              "process cat screen : $CallFlowCatScreenString");
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //         builder:
                                                          //             (context) =>
                                                          //                 CallFlowCatScreen(
                                                          //                   user:
                                                          //                       user,
                                                          //                   title:
                                                          //                       CallFlowCatScreenString[0],
                                                          //                   load:
                                                          //                       CallFlowCatScreenString[1],
                                                          //                 )));
                                                        } else if (lastAccessContent ==
                                                            'InAppWebViewPage') {
                                                          List
                                                              inAppWebViewPageString =
                                                              await prefs.getStringList(
                                                                      'InAppWebViewPage') ??
                                                                  [];
                                                          print(
                                                              "InAppWebViewPage screen : $inAppWebViewPageString");
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => inAppWebViewPageString
                                                                              .length >
                                                                          1
                                                                      ? InAppWebViewPage(
                                                                          isLandscape: inAppWebViewPageString[0] == 'false'
                                                                              ? false
                                                                              : true,
                                                                          isMeetingEtiquite: inAppWebViewPageString[0] == 'false'
                                                                              ? false
                                                                              : true,
                                                                          url: inAppWebViewPageString[
                                                                              0],
                                                                        )
                                                                      : InAppWebViewPage(
                                                                          url: inAppWebViewPageString[
                                                                              0])));
                                                        } else if (lastAccessContent ==
                                                            'InteracticeCatScreen') {
                                                          String
                                                              interacticeCatScreenString =
                                                              await prefs.getString(
                                                                      'InteracticeCatScreen') ??
                                                                  "";
                                                          final box = await Hive
                                                              .openBox<
                                                                      InteractiveLinkHive>(
                                                                  'InteractiveLinkBox');
                                                          InteractiveLinkHive?
                                                              getPr = box.get(
                                                                  'InteracticeCatScreen');
                                                          List<InteractiveLink>?
                                                              ans = getPr!.item;
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  InteracticeCatScreen(
                                                                linkCats: ans!,
                                                                title:
                                                                    interacticeCatScreenString,
                                                              ),
                                                            ),
                                                          );
                                                        } else if (lastAccessContent ==
                                                            'SentenceScreen') {
                                                          List
                                                              SentenceScreenString =
                                                              await prefs.getStringList(
                                                                      'SentenceScreen') ??
                                                                  [];
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SentenceScreen(
                                                                            user:
                                                                                user,
                                                                            title:
                                                                                SentenceScreenString[0],
                                                                            load:
                                                                                SentenceScreenString[1],
                                                                            main:
                                                                                SentenceScreenString[2],
                                                                          )));
                                                        } else if (lastAccessContent ==
                                                            'SentencesScreen') {
                                                          List
                                                              SentencesScreenString =
                                                              await prefs.getStringList(
                                                                      'SentencesScreen') ??
                                                                  [];
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SentencesScreen(
                                                                            title:
                                                                                SentencesScreenString[0],
                                                                            user:
                                                                                user,
                                                                            load:
                                                                                SentencesScreenString[1],
                                                                          )));
                                                        } else if (lastAccessContent ==
                                                            'WordScreen') {
                                                          List
                                                              WordScreenString =
                                                              await prefs.getStringList(
                                                                      'WordScreen') ??
                                                                  [];
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          WordScreen(
                                                                            title:
                                                                                WordScreenString[0],
                                                                            load:
                                                                                WordScreenString[1],
                                                                          )));
                                                        } else if (lastAccessContent ==
                                                            'PronunciationReport') {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          PronunciationReport()));
                                                        } else if (lastAccessContent ==
                                                            'SpeechReport') {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SpeechReport()));
                                                        } else if (lastAccessContent ==
                                                            'CallFlowReport') {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CallFlowReport()));
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                  backgroundColor:
                                                                      Color(
                                                                          0xff34445F),
                                                                  content: Text(
                                                                    'No recent activity found. Dive into your learning journey now!',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                  margin: EdgeInsets.only(
                                                                      bottom: getWidgetHeight(
                                                                          height:
                                                                              550))));
                                                        }
                                                      },
                                                      child: Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          color: Colors.white,
                                                          size: kHeight / 40.6),
                                                    )),
                                              ),
                                            ),
                                            hintText:
                                                "Go To Last Accessed Content",
                                            hintStyle: TextStyle(
                                              fontFamily: Keys.fontFamily,
                                              color: Colors.white38,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            contentPadding:
                                                EdgeInsets.only(left: 22),
                                            filled: true,
                                            fillColor: Color(0xff34445F),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              // SPH(displayHeight(context)/31.23),
                              // SPH(20),
                              SizedBox(
                                height: kIsWeb
                                    ? 26
                                    : isSplitScreen
                                        ? getFullWidgetHeight(height: 26)
                                        : getWidgetHeight(height: 26),
                              ),
                              Container(
                                // height: displayHeight(context) / 2.59,
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 313.39)
                                    : getWidgetHeight(height: 313.39),
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    FirstRowMenu(
                                      onTap: () {
                                        //------>>> first point
                                        mianCategoryTitile = "Process Learning";
                                        context
                                            .read<AuthState>()
                                            .changeSubIndex(0);
                                        context
                                            .read<AuthState>()
                                            .changeIndex(1);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => NewProcessLearningScreen(iconKey: true)));
                                        print(
                                            "_isProcessLearningFromDScreen:${_isProcessLearningFromDScreen}");
                                      },
                                      backgroundImage: AllAssets.process,
                                      menuImage: AllAssets.processLearning,
                                      menu: "Process Learning",
                                      size: size,
                                    ),
                                    SPW(kIsWeb
                                        ? 20
                                        : displayWidth(context) / 18.75),
                                    FirstRowMenu(
                                      onTap: () {
                                        mianCategoryTitile =
                                            "AR Call Simulation";
                                        context
                                            .read<AuthState>()
                                            .changeSubIndex(0);
                                        context
                                            .read<AuthState>()
                                            .changeIndex(2);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => ARCallSimulationScreen(ARIconKey: true)));
                                      },
                                      backgroundImage: AllAssets.ameri,
                                      menuImage: AllAssets.arCallSimulation,
                                      menu: "AR Call Simulation",
                                      size: size,
                                    ),
                                    SPW(kIsWeb
                                        ? 20
                                        : displayWidth(context) / 18.75),
                                    FirstRowMenu(
                                      onTap: () {
                                        mianCategoryTitile =
                                            "Profluent English";
                                        context
                                            .read<AuthState>()
                                            .changeSubIndex(0);
                                        context
                                            .read<AuthState>()
                                            .changeIndex(3);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => ProfluentEnglishModifiedScreen(PEIconKey: true)));
                                      },
                                      backgroundImage: AllAssets.ameri,
                                      menuImage: AllAssets.profluentEnglish,
                                      menu: "Profluent English",
                                      size: size,
                                    ),
                                    SPW(kIsWeb
                                        ? 20
                                        : displayWidth(context) / 18.75),
                                    FirstRowMenu(
                                      onTap: () async {
                                        mianCategoryTitile = "Soft Skills";
                                        print("dhndijhdbd dg");
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString('lastAccess',
                                            'NewSoftSkillsScreen');
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewSoftSkillsScreen()))
                                            .then((value) => refresh());
                                        ;
                                      },
                                      backgroundImage: AllAssets.soft,
                                      menuImage: AllAssets.softSkill,
                                      menu: "Soft Skills",
                                      size: size,
                                    ),
                                  ],
                                ),
                              ),
                              // SPH(displayHeight(context) * 0.0246),
                              SizedBox(
                                height: kIsWeb
                                    ? 15
                                    : isSplitScreen
                                        ? getFullWidgetHeight(height: 15)
                                        : getWidgetHeight(height: 15),
                              ),
                              Text(
                                "Quick Links",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: kText.scale(16),
                                  letterSpacing: 0,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              // SPH(displayHeight(context) * 0.0123),
                              SizedBox(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 10)
                                    : getWidgetHeight(height: 10),
                              ),
                              Column(
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      print("PF CLICKED");
                                      mianCategoryTitile = "Pronunciation Lab";
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'lastAccess', 'LabScreen');
                                      final jsonCompatibleList = authController
                                          .pronunciationLabList
                                          .map((map) {
                                        return map.map((key, value) {
                                          if (value is Color) {
                                            return MapEntry(
                                                key,
                                                value.value
                                                    .toString()); // Convert Color to integer value string
                                          } else {
                                            return MapEntry(key, value);
                                          }
                                        });
                                      }).toList();

                                      String jsonString =
                                          jsonEncode(jsonCompatibleList);
                                      await prefs.setStringList('LabScreen', [
                                        'Pronunciation Lab' ?? "",
                                        jsonString,
                                        'true'
                                      ]);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LabScreen(
                                            user: user,
                                            title: 'Pronunciation Lab',
                                            itemList: authController
                                                .pronunciationLabList,
                                            pLIconKey: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: QuickLinksTile(
                                      title: 'Pronunciation Lab',
                                      subTitle: 'Profluent English',
                                      imageUrl: AllAssets.quickLinkPL,
                                      bgColor: Color(0xFF5370D4),
                                      onTap: () {},
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      mianCategoryTitile = "Denial Management";
                                      print("DM CLICKED");
                                      print(_processLeaning[1]
                                              .subcategories![2]
                                              .linkCats ??
                                          []);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'lastAccess', 'ProcessCatScreen');
                                      await prefs.setString('ProcessCatScreen',
                                          "Denial Management");
                                      final box = await Hive.openBox<
                                              ProcessLearningLinkHive>(
                                          'newProcessLearningBox');
                                      //processLearningBox =await Hive.box<ProcessLearningLinkHive>('processLearningLinkBox');
                                      ProcessLearningLinkHive prHive =
                                          ProcessLearningLinkHive(
                                              item: _processLeaning[1]
                                                  .subcategories![2]
                                                  .linkCats);
                                      box.put('ProcessCatScreen', prHive);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProcessCatScreen(
                                                    linkCats: _processLeaning[1]
                                                            .subcategories![2]
                                                            .linkCats ??
                                                        [],
                                                    title: "Denial Management",
                                                  )));
                                      /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CallFlowCatScreen(
                                      user: user,
                                      title: "Denial Management",
                                      load: "Denial Management",
                                    ),
                                  ),
                                );*/
                                    },
                                    child: QuickLinksTile(
                                      title: 'Denial Management',
                                      subTitle:
                                          'Process Learning > AR & Denial Mgmt',
                                      imageUrl: AllAssets.quickLinkDM,
                                      bgColor: Color(0xFF3DBAD3),
                                      onTap: () {},
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      mianCategoryTitile =
                                          "AR Follow Up (Non-Denials)";
                                      if (_categories[0].subcategories !=
                                          null) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString('lastAccess',
                                            'InteracticeCatScreen');
                                        await prefs.setString(
                                            'InteracticeCatScreen',
                                            _categories[0].category ?? "");
                                        final box = await Hive.openBox<
                                                InteractiveLinkHive>(
                                            'InteractiveLinkBox');
                                        InteractiveLinkHive prHive =
                                            InteractiveLinkHive(
                                                item: _categories[0]
                                                    .subcategories!);
                                        box.put('InteracticeCatScreen', prHive);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InteracticeCatScreen(
                                              linkCats:
                                                  _categories[0].subcategories!,
                                              title:
                                                  _categories[0].category ?? "",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Toast.show("Work in progress",
                                            duration: Toast.lengthShort,
                                            gravity: Toast.bottom,
                                            backgroundColor: AppColors.white,
                                            textStyle: TextStyle(
                                                color: AppColors.black),
                                            backgroundRadius: 10);
                                      }
                                    },
                                    child: QuickLinksTile(
                                      title: 'AR Follow Up (Non-Denials)',
                                      subTitle: 'AR Call Simulations',
                                      imageUrl: AllAssets.quickLinkNDFU,
                                      bgColor: Color(0xFFF0C644),
                                      onTap: () {},
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      mianCategoryTitile =
                                          "Interactive Learning";
                                      if (_categories[1].subcategories !=
                                          null) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setString('lastAccess',
                                            'InteracticeCatScreen');
                                        await prefs.setString(
                                            'InteracticeCatScreen',
                                            _categories[1].category ?? "");
                                        final box = await Hive.openBox<
                                                InteractiveLinkHive>(
                                            'InteractiveLinkBox');
                                        InteractiveLinkHive prHive =
                                            InteractiveLinkHive(
                                                item: _categories[0]
                                                    .subcategories!);
                                        box.put('InteracticeCatScreen', prHive);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InteracticeCatScreen(
                                              linkCats:
                                                  _categories[1].subcategories!,
                                              title:
                                                  _categories[1].category ?? "",
                                            ),
                                          ),
                                        );
                                      } else {
                                        Toast.show("Work in progress",
                                            duration: Toast.lengthShort,
                                            gravity: Toast.bottom,
                                            backgroundColor: AppColors.white,
                                            textStyle: TextStyle(
                                                color: AppColors.black),
                                            backgroundRadius: 10);
                                      }
                                      /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CallFlowCatScreen(
                                      user: user,
                                      title: "Denial Management",
                                      load: "Denial Management",
                                    ),
                                  ),
                                );*/
                                    },
                                    child: QuickLinksTile(
                                      title: 'Denial Management',
                                      subTitle: 'AR Call Simulations',
                                      imageUrl: AllAssets.quickLinkNDFU,
                                      bgColor: Color(0xFFe67e21),
                                      onTap: () async {
                                        if (_categories[3].subcategories !=
                                            null) {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setString('lastAccess',
                                              'InteracticeCatScreen');
                                          await prefs.setString(
                                              'InteracticeCatScreen',
                                              _categories[3].category ?? "");
                                          final box = await Hive.openBox<
                                                  InteractiveLinkHive>(
                                              'InteractiveLinkBox');
                                          InteractiveLinkHive prHive =
                                              InteractiveLinkHive(
                                                  item: _categories[3]
                                                      .subcategories!);
                                          box.put(
                                              'InteracticeCatScreen', prHive);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InteracticeCatScreen(
                                                linkCats: _categories[3]
                                                    .subcategories!,
                                                title: _categories[3]
                                                        .category ??
                                                    "", //4822126141 , 4911567682
                                              ),
                                            ),
                                          );
                                        } else {
                                          Toast.show("Work in progress",
                                              duration: Toast.lengthShort,
                                              gravity: Toast.bottom,
                                              backgroundColor: AppColors.white,
                                              textStyle: TextStyle(
                                                  color: AppColors.black),
                                              backgroundRadius: 10);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              )
            : Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
