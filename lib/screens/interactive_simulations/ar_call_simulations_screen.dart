import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/hiveDb/new_interactive_simulator_hivedb.dart';
import 'package:litelearninglab/models/InteracticeSimulationMain.dart';
import 'package:litelearninglab/screens/interactive_simulations/widgets/ar_grid_tile.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../utils/firebase_helper.dart';
import '../../utils/shared_pref.dart';
import 'interactive_cat_screen.dart';

class ARCallSimulationScreen extends StatefulWidget {
  ARCallSimulationScreen({Key? key, required this.ARIconKey}) : super(key: key);
  final bool ARIconKey;

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

class _ProcessLearningScreenState extends State<ARCallSimulationScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<InteracticeSimulationMain> _categories = [];
  List<String> arCallSimulationsLinks = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  String? _selectedWordOnClick;
  int activeLink1Count = 0;
  int activeLink2Count = 0;
  int activeLink3Count = 0;
  int TotalActiveLinkCount = 0;

  List<Map<String, dynamic>> gridTileDatas = [
    {
      'tileColor': Color(0xFF009991),
      'title': 'AR Follow Up (Non-denials)',
      'image': AllAssets.arFollowUp,
      'ellipse': AllAssets.argreenEllipse
    },
    {
      'tileColor': Color(0xFF4040CA),
      'title': 'Denial Management',
      'image': AllAssets.arDenialMang,
      'ellipse': AllAssets.arblueEllipse
    },
    {
      'tileColor': Color(0xFFDC6379),
      'title': 'Auto\nInsurance',
      'image': AllAssets.arAutoInsure,
      'ellipse': AllAssets.arpinkEllipse
    },
    {
      'tileColor': Color(0xFF8540C8),
      'title': 'Workers Compensation',
      'image': AllAssets.arWorkersComp,
      'ellipse': AllAssets.arpurpleEllipse
    },
  ];

  @override
  void initState() {
    super.initState();
    // startTimerMainCategory("AR Call Simulation");
    mianCategoryTitile = "AR Call Simulation";
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _getWords();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  Future<void> createDocumentWithSpecificId() async {
    print("sdjfijeijfiejfi");
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");
    print("categories:${_categories}");
    for (int i = 0; i < _categories.length; i++) {
      print(":sjfdjkif");
      if (_categories[i].subcategories != null) {
        print("categories name: ${_categories[i].category}");
        print("categories after:${_categories}");
        for (int j = 0; j < _categories[i].subcategories!.length; j++) {
          if (_categories[i].subcategories![j].link1!.isNotEmpty) {
            print("Link1 is active:");
            print(_categories[i].subcategories![j].link1!);
            activeLink1Count += 1;
            print("activeLink1Count: $activeLink1Count");
          }
          if (_categories[i].subcategories![j].link2!.isNotEmpty) {
            print("Link2 is active:");
            activeLink2Count += 1;
            print("activeLink2Count: $activeLink2Count");
          }
          if (_categories[i].subcategories![j].link3!.isNotEmpty) {
            print("Link3 is active:");
            activeLink3Count += 1;
            print("activeLink3Count: $activeLink3Count");
          }
        }
        TotalActiveLinkCount =
            activeLink1Count + activeLink2Count + activeLink3Count;
        print("totalActivelinkCount: ${TotalActiveLinkCount}");
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference arCallSimulations =
        firestore.collection('arCallSimulationsReport').doc(userId);

    DocumentSnapshot snapshot = await arCallSimulations.get();

    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExists");
      setState(() {
        arCallSimulationsLinks = List<String>.from(snapshot['isLink']);
      });
    }
    await arCallSimulations.set({
      'activeLink': TotalActiveLinkCount,
      'isLink': arCallSimulationsLinks,
      'userId': userId,
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getInteractiveSimuations();
    _categories = _categories.reversed.toList();
    // isPlaying = List.generate(_categories.length, (index) => false);
    await createDocumentWithSpecificId();
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        context.read<AuthState>().changeIndex(0);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomNavigation()));
      },
      child: BackgroundWidget(
        appBar: widget.ARIconKey
            ? CommonAppBar(
                title: "AR Call Simulations",
                // height: displayHeight(context) / 12.6875,
              )
            : CommonAppBar(
                appbarIcon: AllAssets.bottomIS,
                title: "AR Call Simulations",
                //  height: displayHeight(context)/12.6875,
              ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _categories.length == 0 && !_isLoading
                ? Center(
                    child: Text(
                      "List is empty",
                      style: TextStyle(color: AppColors.white),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: displayWidth(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: isSplitScreen
                                ? getFullWidgetHeight(height: 24)
                                : getWidgetHeight(height: 24),
                          ),
                          // Text(
                          //   'Indulge in Lifelike Immersive Learning!',
                          //   style: TextStyle(
                          //       fontFamily: 'Roboto',
                          //       fontWeight: FontWeight.w500,
                          //       color: Colors.white,
                          //       letterSpacing: 0,
                          //       fontSize: kText.scale(16)),
                          // ),
                          // Text(
                          //   'Be Ready & Confident For AR Calls.',
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.white,
                          //     fontSize: kText.scale(15),
                          //     fontFamily: 'Roboto',
                          //     letterSpacing: 0,
                          //   ),
                          // ),
                          // SizedBox(
                          //     height: isSplitScreen
                          //         ? getFullWidgetHeight(height: 10)
                          //         : getWidgetHeight(height: 10)),
                          // Text(
                          //   'Practice Fearlessly...',
                          //   style: TextStyle(
                          //       fontWeight: FontWeight.w400,
                          //       color: Color(0xFF6C63FF),
                          //       fontSize: kText.scale(31),
                          //       fontFamily: 'Kaushan',
                          //       letterSpacing: 0),
                          // ),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Indulge in Lifelike Immersive Learning! ',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: 0,
                                      fontSize: kText.scale(16),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Be Ready & Confident For AR Calls. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: kText.scale(15),
                                      fontFamily: 'Roboto',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Practice Fearlessly...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF6C63FF),
                                      fontSize: kText.scale(31),
                                      fontFamily: 'Kaushan',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          SizedBox(
                            height: isSplitScreen
                                ? getFullWidgetHeight(height: 20)
                                : getWidgetHeight(height: 20),
                          ),
                          SizedBox(
                            width: displayWidth(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    ARGridTile(
                                      height: kWidth > 500
                                          ? displayHeight(context) * 0.30
                                          : null,
                                      width: kWidth > 500
                                          ? displayWidth(context) * 0.35
                                          : null,
                                      onTap: () async {
                                        print(
                                            '================////// ${_categories[0].category}');
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
                                          box.put(
                                              'InteracticeCatScreen', prHive);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InteracticeCatScreen(
                                                linkCats: _categories[0]
                                                    .subcategories!,
                                                title:
                                                    _categories[0].category ??
                                                        "",
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
                                        // } else if (val) {
                                        _selectedWordOnClick =
                                            _categories[0].category;
                                        setState(() {});
                                        // }
                                      },
                                      tileColor: gridTileDatas[0]['tileColor'],
                                      title: gridTileDatas[0]['title']!,
                                      icon: gridTileDatas[0]['image'],
                                      ellipse: gridTileDatas[0]['ellipse'],
                                    ),
                                    // SPH(displayHeight(context) * 0.0246),
                                    SizedBox(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 20)
                                          : getWidgetHeight(height: 20),
                                    ),
                                    ARGridTile(
                                      height: kWidth > 500
                                          ? displayHeight(context) * 0.30
                                          : null,
                                      width: kWidth > 500
                                          ? displayWidth(context) * 0.35
                                          : null,
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
                                        // } else if (val) {
                                        _selectedWordOnClick =
                                            _categories[3].category;
                                        setState(() {});
                                        // }
                                      },
                                      tileColor: gridTileDatas[3]['tileColor'],
                                      title: gridTileDatas[3]['title']!,
                                      icon: gridTileDatas[3]['image'],
                                      ellipse: gridTileDatas[3]['ellipse'],
                                    ),
                                  ],
                                ),
                                SPW(displayWidth(context) * 0.046),
                                // Spacer(),
                                // SizedBox(
                                //   width: getWidgetWidth(width: 16),
                                // ),
                                Column(
                                  children: [
                                    // SPH(displayHeight(context) * 0.05),
                                    SizedBox(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 40)
                                          : getWidgetHeight(height: 40),
                                    ),
                                    ARGridTile(
                                      height: kWidth > 500
                                          ? displayHeight(context) * 0.30
                                          : null,
                                      width: kWidth > 500
                                          ? displayWidth(context) * 0.35
                                          : null,
                                      onTap: () async {
                                        print(
                                            '================////// ${_categories[1].category}');
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
                                                  item: _categories[1]
                                                      .subcategories!);
                                          box.put(
                                              'InteracticeCatScreen', prHive);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InteracticeCatScreen(
                                                linkCats: _categories[1]
                                                    .subcategories!,
                                                title:
                                                    _categories[1].category ??
                                                        "",
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
                                        // } else if (val) {
                                        _selectedWordOnClick =
                                            _categories[1].category;
                                        setState(() {});
                                        // }
                                      },
                                      tileColor: gridTileDatas[1]['tileColor'],
                                      title: gridTileDatas[1]['title']!,
                                      icon: gridTileDatas[1]['image'],
                                      ellipse: gridTileDatas[1]['ellipse'],
                                    ),
                                    // SPH(displayHeight(context) * 0.0246),
                                    SizedBox(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 20)
                                          : getWidgetHeight(height: 20),
                                    ),
                                    ARGridTile(
                                      height: kWidth > 500
                                          ? displayHeight(context) * 0.30
                                          : null,
                                      width: kWidth > 500
                                          ? displayWidth(context) * 0.35
                                          : null,
                                      onTap: () async {
                                        print(
                                            '================////// ${_categories[2].category}');
                                        if (_categories[2].subcategories !=
                                            null) {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setString('lastAccess',
                                              'InteracticeCatScreen');
                                          await prefs.setString(
                                              'InteracticeCatScreen',
                                              _categories[2].category ?? "");
                                          final box = await Hive.openBox<
                                                  InteractiveLinkHive>(
                                              'InteractiveLinkBox');
                                          InteractiveLinkHive prHive =
                                              InteractiveLinkHive(
                                                  item: _categories[2]
                                                      .subcategories!);
                                          box.put(
                                              'InteracticeCatScreen', prHive);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InteracticeCatScreen(
                                                linkCats: _categories[2]
                                                    .subcategories!,
                                                title:
                                                    _categories[2].category ??
                                                        "",
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
                                        // } else if (val) {
                                        _selectedWordOnClick =
                                            _categories[2].category;
                                        setState(() {});
                                        // }
                                      },
                                      tileColor: gridTileDatas[2]['tileColor'],
                                      title: gridTileDatas[2]['title']!,
                                      icon: gridTileDatas[2]['image'],
                                      ellipse: gridTileDatas[2]['ellipse'],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: isSplitScreen
                                ? getFullWidgetHeight(height: 20)
                                : getWidgetHeight(height: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
