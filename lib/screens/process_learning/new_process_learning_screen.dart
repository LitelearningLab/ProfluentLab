import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:after_layout/after_layout.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/screens/process_learning/indicator_controller.dart';
import 'package:litelearninglab/screens/process_learning/learning_screen.dart';
import 'package:litelearninglab/screens/process_learning/process_cat_screen.dart';
import 'package:litelearninglab/screens/softskills/new_softskills_screen.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/rect_rounded_swiper_pagination_builder.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipe_deck/swipe_deck.dart';
import 'package:toast/toast.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../hiveDb/hiveDb.dart';
import '../../main.dart';
import '../../models/ProcessLearningMain.dart';
import '../../models/ProcessLearningSub.dart';
import '../../states/auth_state.dart';
import '../../utils/firebase_helper.dart';
import '../../utils/shared_pref.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

String pTitle = "";

class NewProcessLearningScreen extends StatefulWidget {
  NewProcessLearningScreen({Key? key, required this.iconKey}) : super(key: key);
  final bool iconKey;

  @override
  _NewProcessLearningScreenState createState() {
    return _NewProcessLearningScreenState();
  }
}

class _NewProcessLearningScreenState extends State<NewProcessLearningScreen> with AfterLayoutMixin<NewProcessLearningScreen>, WidgetsBindingObserver {
  FirebaseHelper db = new FirebaseHelper();
  List<ProcessLearningMain> _processLeaning = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  List<String> processLearningLinks = [];
  String? _selectedWordOnClick;
  int activeLinkCountPL = 0;
  int activeSimulationCountPL = 0;
  int activeVideoCountPL = 0;
  int activeFAQCountPL = 0;
  int activeKnowledgePL = 0;
  int totalActiveLinkCountPL = 0;
  double kHeight = 0.0;
  double kWidth = 0.0;
  late TextScaler kText;
  late AuthState authStateController;
  List<Map<String, dynamic>> swipperList = [
    {"tileColor": Color(0xFFEAE5FF), "tileImage": AllAssets.plRevenueCircle, 'heading': 'US HEALTHCARE'},
    {"tileColor": Color(0xFFFFDEDD), "tileImage": "", 'heading': ''},
    {"tileColor": Color(0xFFFFC9C8), "tileImage": AllAssets.plAutoInsurance, 'heading': 'LIABILITY INSURANCE'},
    {"tileColor": Color(0xFFEAE5FF), "tileImage": AllAssets.plWorkersCompensation, 'heading': 'LIABILITY INSURANCE'},
    {"tileColor": Color(0xFFFFDEDD), "tileImage": AllAssets.plFederalInsurance, 'heading': 'US HEALTHCARE'},
    {"tileColor": Color(0xFFFFC9C8), "tileImage": AllAssets.plBLueCross, 'heading': 'US HEALTHCARE'},
  ];

  @override
  void initState() {
    super.initState();
    startTimerMainCategory("Process Learning");
    // Add the observer for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    log("here start to listening the process learning spend time");
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical);

    _getWords();
    authStateController = Provider.of<AuthState>(context, listen: false);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    // This method will be called after the first layout is complete
    print("First layout is complete. Performing initial setup...");
    // You can add any initialization logic here that needs to run after the first layout
  }

  Future<void> createDocumentWithSpecificIdPL() async {
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");

    for (int i = 0; i < _processLeaning.length; i++) {
      if (_processLeaning[i].subcategories != null) {
        print("title name : ${_processLeaning[i].category}");
        print("categories name: ${_processLeaning[i].subcategories}");
        for (int j = 0; j < _processLeaning[i].subcategories!.length; j++) {
          print("processLearning Subcategoreis length:${_processLeaning[i].subcategories!.length}");
          if (_processLeaning[i].subcategories![j].link != null) {
            if (_processLeaning[i].subcategories![j].link!.isNotEmpty) {
              print("linkCheckkkk:${_processLeaning[i].subcategories![j].link!.isNotEmpty}");
              print("linkkkkkkk:${_processLeaning[i].subcategories![j].link}");
              activeLinkCountPL += 1;
            }
          }
          if (_processLeaning[i].subcategories![j].linkCats != null) {
            print("sdmkmgmrgmv");
            for (int z = 0; z < _processLeaning[i].subcategories![j].linkCats!.length; z++) {
              print("samkdmv");
              if (_processLeaning[i].subcategories![j].linkCats![z].simulation != null) {
                if (_processLeaning[i].subcategories![j].linkCats![z].simulation!.isNotEmpty) {
                  print("simulationLink:${_processLeaning[i].subcategories![j].linkCats![z].simulation!}");
                  print("dfdjj");
                  activeSimulationCountPL += 1;
                  print("activeSimulationCountPL:${activeSimulationCountPL}");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].video != null) {
                if (_processLeaning[i].subcategories![j].linkCats![z].video!.isNotEmpty) {
                  print("videoLinkkkk:${_processLeaning[i].subcategories![j].linkCats![z].video!}");
                  activeVideoCountPL += 1;
                  print("activeVideoCountPl:$activeVideoCountPL");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].faq != null) {
                if (_processLeaning[i].subcategories![j].linkCats![z].faq!.isNotEmpty) {
                  print("faqLink:${_processLeaning[i].subcategories![j].linkCats![z].faq!}");
                  activeFAQCountPL += 1;
                  print("activeFAQCountPl:$activeFAQCountPL");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].knowledge != null) {
                if (_processLeaning[i].subcategories![j].linkCats![z].knowledge!.isNotEmpty) {
                  print("knowledgeLink:${_processLeaning[i].subcategories![j].linkCats![z].knowledge!}");
                  activeKnowledgePL += 1;
                  print("activeKnowledgePL:$activeKnowledgePL");
                }
              }
            }
          }
        }
        totalActiveLinkCountPL = activeLinkCountPL + activeSimulationCountPL + activeVideoCountPL + activeFAQCountPL + activeKnowledgePL;
        print("activeLinkCountPL:${activeLinkCountPL}");
        print('activeSimulationCountPl:$activeSimulationCountPL');
        print('activeVideoCountPL:$activeVideoCountPL');
        print('activeFAQCountPL:$activeFAQCountPL');
        print('activeKnowledgePL:$activeKnowledgePL');
        print('activeSimulationCountPl:$activeSimulationCountPL');
        print("totalActiveLinkCountpl:$totalActiveLinkCountPL");
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference processLearningReport = firestore.collection('processLearningReports').doc(userId);

    DocumentSnapshot snapshot = await processLearningReport.get();

    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExists");
      setState(() {
        processLearningLinks = List<String>.from(snapshot['isLink']);
      });
    }
    await processLearningReport.set({
      'activeLink': totalActiveLinkCountPL,
      'isLink': processLearningLinks,
      'userId': userId,
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  hiveFuntion() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    await Hive.openBox('myBox');
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);

    setState(() {});
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _processLeaning = [];
    _processLeaning = await db.getProcessLearning();
    _processLeaning = _processLeaning.reversed.toList();
    print("process learning : $_processLeaning");
    print("process learning length : ${_processLeaning.length}");
    // isPlaying = List.generate(_processLeaning.length, (index) => false);
    _isLoading = false;
    await createDocumentWithSpecificIdPL();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;

    PageController controller = PageController();
    _processLeaning.forEach((element) {
      print('=============/////////// ${element.category}');
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        context.read<AuthState>().changeIndex(0);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
      },
      child: BackgroundWidget(
          appBar: widget.iconKey
              ? CommonAppBar(
                  title: "Process Learning",
                )
              : CommonAppBar(
                  appbarIcon: AllAssets.quickLinkDM,
                  title: "Process Learning",
                ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _processLeaning.length == 0 && !_isLoading
                  ? Center(
                      child: Text(
                        "List is empty",
                        style: TextStyle(color: AppColors.white),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: isSplitScreen ? getFullWidgetHeight(height: 330) : getWidgetHeight(height: 330),
                            width: displayWidth(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Swiper(
                                          curve: Curves.linear,
                                          indicatorLayout: PageIndicatorLayout.SLIDE,
                                          itemCount: _processLeaning.length - 1,

                                          itemBuilder: (context, index) {
                                            int adjustedIndex;
                                            if (index < 1) {
                                              adjustedIndex = index;
                                            } else {
                                              adjustedIndex = index + 1;
                                            }
                                            print('//////////// INDEX : $adjustedIndex');

                                            return Transform(
                                              transform: Matrix4.identity()..translate(-22.0, 0.0, 0.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  print("adgvifjb;$adjustedIndex");
                                                  if (_processLeaning[adjustedIndex].underconstruction == true &&
                                                      _processLeaning[adjustedIndex].underconstruction != null) {
                                                    print("dsnvikfjiv");
                                                    Toast.show("Work in progress",
                                                        duration: Toast.lengthShort,
                                                        gravity: Toast.bottom,
                                                        backgroundColor: AppColors.white,
                                                        textStyle: TextStyle(color: AppColors.black),
                                                        backgroundRadius: 10);
                                                  } else if (adjustedIndex == 0) {
                                                    print("sucesss");
                                                    print("d did : ${_processLeaning.length}");
                                                    print("dpdid d  : ${_processLeaning}");
                                                    print("adjusted index:${adjustedIndex}");
                                                    print("indexdfff:$index");

                                                    print('ifirejvg:${_processLeaning[adjustedIndex].subcategories![0].name}');
                                                    /*SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    await prefs.setString('lastAccess', 'ProcessCatScreen');
                                                    await prefs.setString(
                                                        'ProcessCatScreen',
                                                        _processLeaning[adjustedIndex].subcategories![index].name ??
                                                            "");
                                                    final box = await Hive.openBox<ProcessLearningLinkHive>(
                                                        'newProcessLearningBox');
                                                    //processLearningBox =await Hive.box<ProcessLearningLinkHive>('processLearningLinkBox');
                                                    ProcessLearningLinkHive prHive = ProcessLearningLinkHive(
                                                        item: _processLeaning[adjustedIndex]
                                                            .subcategories!
                                                            .first
                                                            .linkCats);
                                                    box.put('ProcessCatScreen', prHive);*/
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => ProcessCatScreen(
                                                                linkCats: _processLeaning[adjustedIndex].subcategories!.first.linkCats ?? [],
                                                                title: _processLeaning[adjustedIndex].subcategories!.first.name ?? "",
                                                              )),
                                                    );
                                                  } else {
                                                    print("sucesss111");
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                      return LearningScreen(
                                                        title: _processLeaning[adjustedIndex].subcategories!.first.name ?? "",
                                                        linkCats: _processLeaning[adjustedIndex].subcategories!.first.linkCats ?? [],
                                                      );
                                                    }));
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: isSplitScreen ? getFullWidgetHeight(height: 16) : getWidgetHeight(height: 16)),
                                                  decoration: BoxDecoration(
                                                    color: swipperList[adjustedIndex]['tileColor'],
                                                    borderRadius: BorderRadius.circular(7),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          swipperList[adjustedIndex]['heading'],
                                                          style: TextStyle(
                                                            fontFamily: 'Roboto',
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: kText.scale(12),
                                                            color: adjustedIndex == 0 || adjustedIndex == 4
                                                                ? Color(0xFF6A60FB)
                                                                : adjustedIndex == 5
                                                                    ? Color(0xFF26BFFF)
                                                                    : Color(0xFFFF1A1A),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        // height: displayHeight(context) * 0.224,
                                                        height: 182.04,
                                                        width: displayWidth(context) * 0.685,
                                                        child: Image.asset(
                                                          swipperList[adjustedIndex]['tileImage'],
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.bottomLeft,
                                                        child: Text(
                                                          _processLeaning[adjustedIndex].category!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontFamily: 'Roboto',
                                                              letterSpacing: 0,
                                                              color: Color(0xFF535353),
                                                              fontSize: 16.5,
                                                              fontWeight: FontWeight.w600
                                                              // fontWeight:
                                                              //     FontWeight.w600,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          pagination: SwiperPagination(
                                            margin: EdgeInsets.only(
                                              top: isSplitScreen ? getFullWidgetHeight(height: 5) : getWidgetHeight(height: 5),
                                            ),
                                            builder: RectRoundedSwiperPaginationBuilder(
                                              color: Color(0xFF9D97FF),
                                              activeColor: Color(0xFF6C63FE),
                                              size: Size(15, 12),
                                              activeSize: Size(30, 12),
                                            ),
                                          ),
                                          controller: SwiperController(),
                                          // itemHeight: displayHeight(context) / 2.829,

                                          itemHeight: isSplitScreen ? getFullWidgetHeight(height: 287) : getWidgetHeight(height: 287),
                                          itemWidth: getWidgetWidth(width: 290),
                                          layout: SwiperLayout.STACK,

                                          loop: true,
                                          scrollDirection: Axis.horizontal,
                                          axisDirection: AxisDirection.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(width: 20,)
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: getWidgetWidth(width: 335),
                            height: getWidgetHeight(height: 258),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 9)),
                                    height: getWidgetHeight(height: 90),
                                    width: getWidgetWidth(width: 335),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _processLeaning[1].category!,
                                            style: TextStyle(fontFamily: 'Roboto', letterSpacing: 0, fontSize: kText.scale(17), fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          child: SvgPicture.asset(
                                            AllAssets.plAccounts,
                                            height: isSplitScreen ? getFullWidgetHeight(height: 86) : getWidgetHeight(height: 86),
                                            // scale: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          if (_processLeaning[1].subcategories![index].link != null) {
                                            print("arManagementTappeddd");
                                            String? arManagementLinks = _processLeaning[1].subcategories![index].link;
                                            processLearningLinks.add(arManagementLinks!);
                                            FirebaseFirestore firestore = FirebaseFirestore.instance;
                                            String userId = await SharedPref.getSavedString('userId');
                                            DocumentReference softSkills = firestore.collection('processLearningReports').doc(userId);

                                            await softSkills.update({
                                              'isLink': FieldValue.arrayUnion([_processLeaning[1].subcategories![index].link]),
                                            }).then((_) {
                                              print('Link added to Firestore: ${_processLeaning[1].subcategories![index].link}');
                                            }).catchError((e) {
                                              print('Error updating Firestore: $e');
                                            });
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            await prefs.setStringList('InAppWebViewPage', [_processLeaning[1].subcategories![index].link!]);
                                            await prefs.setString('lastAccess', 'InAppWebViewPage');
                                            await prefs.setString("lastYes", processLearning);
                                            startTimerSubCategory(processLearning, _processLeaning[1].subcategories![index].name ?? "");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => InAppWebViewPage(
                                                  // title: _processLeaning[1].subcategories![index].name ?? "",
                                                  url: _processLeaning[1].subcategories![index].link!,
                                                ),
                                              ),
                                            );
                                          } else if (_processLeaning[1].subcategories![index].linkCats != null &&
                                              _processLeaning[1].subcategories![index].linkCats!.isNotEmpty) {
                                            print('denial managementtt>>>>>');
                                            print("checkk:${_processLeaning[1].subcategories![index].linkCats ?? []}");
                                            print("check1 : ${_processLeaning[1].subcategories![index].name ?? ""}");
                                            print("indexCheck;$index");

                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            await prefs.setString('lastAccess', 'ProcessCatScreen');
                                            await prefs.setString('ProcessCatScreen', _processLeaning[1].subcategories![index].name ?? "" ?? "");
                                            // final box = await Hive.openBox<ProcessLearningLinkHive>('newProcessLearningBox');
                                            // // processLearningBox = await Hive.box<ProcessLearningLinkHive>('processLearningLinkBox');
                                            // ProcessLearningLinkHive prHive = ProcessLearningLinkHive(item: _processLeaning[1].subcategories![index].linkCats);
                                            // box.put('ProcessCatScreen', prHive);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProcessCatScreen(
                                                  linkCats: _processLeaning[1].subcategories![index].linkCats ?? [],
                                                  title: _processLeaning[1].subcategories![index].name ?? "",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          // color: Colors.red,
                                          // height: displayHeight(context) / 15.61,
                                          padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 18)),
                                          height: isSplitScreen ? getFullWidgetHeight(height: 40) : getWidgetHeight(height: 40),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _processLeaning[1].subcategories![index].name!,
                                                style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: kText.scale(15),
                                                  color: Color(0xFF4F4F4F),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: Color(0xFFD3D3D3),
                                                size: displayWidth(context) / 11,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => Divider(
                                          color: Color(0xFFE4E4E4),
                                        ),
                                    itemCount: _processLeaning[1].subcategories!.length),
                                SizedBox(
                                  height: isSplitScreen ? getFullWidgetHeight(height: 5) : getWidgetHeight(height: 5),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: isSplitScreen ? getFullWidgetHeight(height: 20) : getWidgetHeight(height: 20),
                          ),
                        ],
                      ),
                    )),
    );
  }
}
