import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProfluentEnglish.dart';
import 'package:litelearninglab/models/ProfluentLink.dart';
import 'package:litelearninglab/models/Word.dart';
import 'package:litelearninglab/screens/fast_track_pronunciation/fast_track_pronunciation_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/top_catetgories_card.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';

import '../../utils/shared_pref.dart';
import 'lab_screen.dart';

class ProfluentEnglishModifiedScreen extends StatefulWidget {
  const ProfluentEnglishModifiedScreen({key, required this.PEIconKey});
  final bool PEIconKey;

  @override
  State<ProfluentEnglishModifiedScreen> createState() =>
      _ProfluentEnglishModifiedScreenState();
}

class _ProfluentEnglishModifiedScreenState
    extends State<ProfluentEnglishModifiedScreen> {
  int _selectedTabIndex = 0;
  FirebaseHelper db = new FirebaseHelper();
  List<ProfluentEnglish> _categories = [];
  List<ProfluentEnglish> vowels = [];
  List<ProfluentEnglish> consonants = [];
  ProfluentEnglish arFAs = ProfluentEnglish();
  late ProfluentEnglish importantSounds;
  List<ProfluentEnglish> importantSounds1 = [];
  List<ProfluentEnglish> importantSounds2 = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  late AuthState user;
  List<bool> expanded = [true, false, false];
  List<Color> colorList = [
    Color(0XFF3F51B5),
    Color(0XFF03A9F4),
    Color(0XFF5AB963),
    Color(0XFFDDD639),
    Color(0XFFFF9800),
  ];
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  List<String> WordsLink = [];
  List<String> SentencesLink = [];
  final soundsWordsdb = new FirebaseHelperRTD();

  void initState() {
    super.initState();
    // startTimerMainCategory("Profluent English");
    mianCategoryTitile = "Profluent English";
    user = Provider.of<AuthState>(context, listen: false);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _getWords();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController3.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  void getImportantSoundsAndVowels() {
    int count = 0;
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].category == 'Important Sounds') {
        importantSounds = _categories[i];
      } else if (_categories[i].category == 'Long Vowels' ||
          _categories[i].category == 'Short Vowel' ||
          _categories[i].category == "Diphthong") {
        print("categories name : ${_categories[i].subcategories!.first.name}");
        vowels.add(_categories[i]);
        importantSounds1.add(_categories[i]);
        //  count++;
        // log('${count}');
        //importantSounds1 = _categories[i];
      } else if (_categories[i].category!.startsWith('Consonants')) {
        consonants.add(_categories[i]);
        importantSounds2.add(_categories[i]);
      } else if (_categories[i].category == 'Fast Track Pronunciation For AR') {
        arFAs = _categories[i];
        print("count>>>>>>>>>>>>>>>>>>");
        print(arFAs.category);
      }
    }
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getProfluentEnglish();
    _categories = _categories.reversed.toList();
    print("categoires length : ${_categories.length}");
    print("categories list: $_categories");
    getImportantSoundsAndVowels();
    _isLoading = false;
    await createDocumentWithSpecificIdPE();
    setState(() {});
  }

  Future<void> createDocumentWithSpecificIdPE() async {
    print("sdjfijeijfiejfi");
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");
    //print("categories:${_categories}");

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference proFluentEnglish =
        firestore.collection('proFluentEnglishReport').doc(userId);

    DocumentSnapshot snapshot = await proFluentEnglish.get();

    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExists");
      setState(() {
        WordsLink = List<String>.from(snapshot['WordsTapped']);
        SentencesLink = List<String>.from(snapshot['SentencesTapped']);
        print("wordLink:${WordsLink}");
        print("SentecesLink:${SentencesLink}");
      });
    }
    await proFluentEnglish.set({
      'WordsTapped': WordsLink,
      'SentencesTapped': SentencesLink,
      'userId': userId,
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  void _scrollToItem(int index) {
    print("sdignjirjeti");
    final double itemHeight = 100.0; // Adjust based on your item height
    final position = index * itemHeight;
    final viewportHeight = _scrollController3.position.viewportDimension;
    final offset = _scrollController3.offset;
    print("position:$position");
    print("viewportHeight:$viewportHeight");
    print("offset:$offset");

    if (position < offset || position + itemHeight > offset + viewportHeight) {
      print("dgoikjrog");
      _scrollController3.animateTo(
        position,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToItemForVowels(int index) {
    print("sdignjirjeti");
    final double itemHeight = 100.0; // Adjust based on your item height
    final position = index * itemHeight;
    final viewportHeight = _scrollController2.position.viewportDimension;
    final offset = _scrollController2.offset;
    print("position:$position");
    print("viewportHeight:$viewportHeight");
    print("offset:$offset");

    if (position < offset || position + itemHeight > offset + viewportHeight) {
      print("dgoikjrog");
      _scrollController2.animateTo(
        position,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  int _currentlyOpenIndex = -1;

  void _handleExpansion(int index, bool isExpanded) {
    print(isExpanded);
    print("expanded>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    setState(() {
      if (isExpanded) {
        _currentlyOpenIndex = -1; // Close the current tile
      } else {
        _currentlyOpenIndex = index; // Open the clicked tile
      }
    });
  }

  int selected = -1;

  int expansionTileIndex1 = -1;
  int expansionTileIndex2 = -1;

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final controller = Provider.of<AuthState>(context, listen: false);
    controller.tabarIndex = 0;
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        context.read<AuthState>().changeIndex(0);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomNavigation()));
      },
      child: BackgroundWidget(
        appBar: widget.PEIconKey
            ? CommonAppBar(
                title: "Profluent English",
                // height: displayHeight(context) / 12.6875,
              )
            : CommonAppBar(
                appbarIcon: AllAssets.quickLinkPL,
                title: "Profluent English",
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
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  )
                : DefaultTabController(
                    length: 3,
                    child: Builder(builder: (context) {
                      final tabController = DefaultTabController.of(context);
                      tabController.addListener(() {
                        if (kDebugMode) {
                          print("New tab index: ${tabController.index}");
                        }
                        //  FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          expansionTileIndex1 = -1;
                          expansionTileIndex2 = -1;
                          _selectedTabIndex = tabController.index;
                          print("selected tabbar index : $_selectedTabIndex");
                        });
                      });
                      return Padding(
                        padding: EdgeInsets.only(
                            left: getWidgetWidth(width: 20),
                            right: getWidgetWidth(width: 20),
                            top: isSplitScreen
                                ? getFullWidgetHeight(height: 20)
                                : getWidgetHeight(height: 20)),
                        child: Column(
                          children: [
                            Container(
                              height: kIsWeb
                                  ? 250
                                  : isSplitScreen
                                      ? getFullWidgetHeight(height: 142)
                                      : getWidgetHeight(height: 142),
                              width: displayWidth(context),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  PETopCategoriesCard(
                                    height: isSplitScreen
                                        ? getFullWidgetHeight(height: 88.28)
                                        : getWidgetHeight(height: 88.28),
                                    width: kIsWeb
                                        ? 100
                                        : getWidgetWidth(width: 96.11),
                                    title: 'Pronunciation Lab',
                                    imageUrl: AllAssets.pePl,
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'lastAccess', 'LabScreen');
                                      final jsonCompatibleList = controller
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
                                            itemList:
                                                controller.pronunciationLabList,
                                            pLIconKey: true,
                                          ),
                                        ),
                                      );
                                    },
                                    cardColor: Color(0xFF398480),
                                  ),
                                  // SPW(10),
                                  SizedBox(
                                    width:
                                        kIsWeb ? 20 : getWidgetWidth(width: 14),
                                  ),
                                  PETopCategoriesCard(
                                    height: isSplitScreen
                                        ? getFullWidgetHeight(height: 88.47)
                                        : getWidgetHeight(height: 88.47),
                                    width: getWidgetWidth(width: 103.76),
                                    title: 'Sentence Lab',
                                    imageUrl: AllAssets.peScl,
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'lastAccess', 'LabScreen');
                                      final jsonCompatibleList = controller
                                          .sentenceConstructionLabList
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
                                        'Sentence Lab' ?? "",
                                        jsonString,
                                        'true'
                                      ]);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LabScreen(
                                            user: user,
                                            title: 'Sentence Lab',
                                            itemList: controller
                                                .sentenceConstructionLabList,
                                            pLIconKey: true,
                                          ),
                                        ),
                                      );
                                    },
                                    cardColor: Color(0xFF445EA9),
                                  ),
                                  // SPW(10),
                                  SizedBox(
                                    width:
                                        kIsWeb ? 20 : getWidgetWidth(width: 14),
                                  ),
                                  PETopCategoriesCard(
                                    height: isSplitScreen
                                        ? getFullWidgetHeight(height: 88.65)
                                        : getWidgetHeight(height: 88.65),
                                    width: getWidgetWidth(width: 106.03),
                                    title: 'Call Flow Lab',
                                    imageUrl: AllAssets.peCfpl,
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'lastAccess', 'LabScreen');
                                      final jsonCompatibleList = controller
                                          .callFlowPracticeLabList
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
                                        'Call Flow Lab' ?? "",
                                        jsonString,
                                        'true'
                                      ]);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LabScreen(
                                            user: user,
                                            title: 'Call Flow Lab',
                                            itemList: controller
                                                .callFlowPracticeLabList,
                                            pLIconKey: true,
                                          ),
                                        ),
                                      );
                                    },
                                    cardColor: Color(0xFF636CFF),
                                  ),
                                  // SPW(10),
                                  SizedBox(
                                    width:
                                        kIsWeb ? 20 : getWidgetWidth(width: 14),
                                  ),
                                  PETopCategoriesCard(
                                    height: isSplitScreen
                                        ? getFullWidgetHeight(height: 88)
                                        : getWidgetHeight(height: 88),
                                    width: getWidgetWidth(width: 130.04),
                                    title: 'Grammer Lab',
                                    imageUrl: AllAssets.peGl,
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      final jsonCompatibleList = controller
                                          .grammarCheckLabList
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
                                        'Grammer Lab' ?? "",
                                        jsonString,
                                        'true'
                                      ]);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LabScreen(
                                            user: user,
                                            title: 'Grammer Lab',
                                            itemList:
                                                controller.grammarCheckLabList,
                                            pLIconKey: true,
                                          ),
                                        ),
                                      );
                                      /*  Navigator.push(
        context, MaterialPageRoute(builder: (context) => GrammerCheckScreen()));*/
                                    },
                                    cardColor: Color(0xFFDC6379),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 20)
                                  : getWidgetHeight(height: 20),
                            ),
                            InkWell(
                              onTap: () async {
                                subCategoryTitile =
                                    "Fast Track\nPronunciation For AR";
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          fastTrackPronunciationScreen(
                                            title: arFAs,
                                          )),
                                );
                              },
                              child: Container(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 96)
                                    : getWidgetHeight(height: 96),
                                // width: getWidgetWidth(width: 335),
                                decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: getWidgetWidth(width: 10),
                                    right: getWidgetWidth(width: 5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        //height: size.height * 0.054,
                                        width: displayWidth(context) * 0.5,
                                        child: Text(
                                          'Fast Track\nPronunciation For AR',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: kText.scale(17),
                                            fontFamily: "Roboto",
                                            letterSpacing: 0,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: SizedBox(
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 86)
                                              : getWidgetHeight(height: 86),
                                          width: getWidgetWidth(width: 131.19),
                                          child:
                                              Image.asset(AllAssets.peFtpfar),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 24)
                                    : getWidgetHeight(height: 24)),
                            InkWell(
                              onTap: () async {
                                print("djd d di di d");
                                DocumentSnapshot documentSnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('SoundsKnowMore')
                                        .doc(
                                            'bkE3wd4gItN0U94otgrY') // specify the document ID
                                        .get();
                                String url = documentSnapshot.get('link');
                                print("sounds know more url : $url");
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs
                                    .setStringList('InAppWebViewPage', [url]);
                                await prefs.setString(
                                    'lastAccess', 'InAppWebViewPage');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => InAppWebViewPage(
                                              url: url,
                                            )));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sounds',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                      letterSpacing: 0,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: getWidgetWidth(width: 7),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '( Know more... )',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Roboto',
                                          letterSpacing: 0,
                                          fontSize: 13,
                                          wordSpacing: 2,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 2),
                                        height: isSplitScreen
                                            ? getFullWidgetHeight(height: 2)
                                            : getWidgetHeight(height: 2),
                                        color: Colors.white,
                                        width: getWidgetWidth(width: 80),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 14)
                                    : getWidgetHeight(height: 14)),
                            TabBar(
                              padding: EdgeInsets.zero,
                              splashFactory: InkSplash.splashFactory,
                              splashBorderRadius: BorderRadius.circular(30),
                              enableFeedback: false,
                              indicatorPadding: EdgeInsets.symmetric(
                                  vertical: kIsWeb
                                      ? 2
                                      : isSplitScreen
                                          ? getFullWidgetHeight(height: 9)
                                          : getWidgetHeight(height: 9)),
                              onTap: (int) async {
                                print('/////////// $int');
                                _onTabChanged(int);
                                setState(() {
                                  _selectedTabIndex = int;
                                  expansionTileIndex1 = -1;
                                  expansionTileIndex2 = -1;
                                });
                              },
                              labelPadding: EdgeInsets.only(
                                  right: getWidgetWidth(width: 12)),
                              dividerColor: Colors.transparent,
                              tabAlignment: TabAlignment.start,
                              labelColor: Colors.white,
                              isScrollable: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              unselectedLabelColor: Color(0xFF99A0AE),
                              indicatorColor: Color(0xFF6C63FE),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFF6C63FE)),
                              unselectedLabelStyle:
                                  TextStyle(fontSize: kText.textScaleFactor),
                              tabs: [
                                Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              getWidgetWidth(width: 20)),
                                      child: Text(
                                        'Important Sounds',
                                        style: TextStyle(
                                            color: _selectedTabIndex == 0
                                                ? Colors.white
                                                : Color(0xFF99A0AE),
                                            fontSize: kText.scale(12),
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              getWidgetWidth(width: 20)),
                                      child: Text(
                                        'Vowels',
                                        style: TextStyle(
                                            color: _selectedTabIndex == 1
                                                ? Colors.white
                                                : Color(0xFF99A0AE),
                                            fontSize: kText.scale(12),
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              getWidgetWidth(width: 20)),
                                      child: Text(
                                        'Consonants',
                                        style: TextStyle(
                                            color: _selectedTabIndex == 2
                                                ? Colors.white
                                                : Color(0xFF99A0AE),
                                            fontSize: kText.scale(12),
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // ColorfulTabBar(
                            //   verticalTabPadding: 5,
                            //   alignment: TabAxisAlignment.end,
                            //   labelColor: Colors.white,
                            //   unselectedLabelColor: Color(0XFF99A0AE),
                            //   selectedHeight: 32,
                            //   unselectedHeight: 32,
                            //   tabShape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(200)),
                            //   indicatorHeight: 0,
                            //   tabs: [
                            //     TabItem(
                            //         title: Text(
                            //           "10 Important Sounds",
                            //           style: TextStyle(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w500),
                            //         ),
                            //         color: Color(0XFF6C63FE),
                            //         unselectedColor: Color(0XFF34425D)),
                            //     TabItem(
                            //         title: Text(
                            //           "Vowels",
                            //           style: TextStyle(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w500),
                            //         ),
                            //         color: Color(0XFF6C63FE),
                            //         unselectedColor: Color(0XFF34425D)),
                            //     TabItem(
                            //         title: Text(
                            //           "Consonants",
                            //           style: TextStyle(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w500),
                            //         ),
                            //         color: Color(0XFF6C63FE),
                            //         unselectedColor: Color(0XFF34425D)),
                            //   ],
                            //   //  controller: _tabController,
                            // ),
                            SizedBox(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 18)
                                  : getWidgetHeight(height: 18),
                            ),
                            Expanded(
                              // height: MediaQuery.of(context).size.height * 0.3,
                              child: TabBarView(
                                //physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Scrollbar(
                                    controller: _scrollController1,
                                    thickness: 2,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      // physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: isSplitScreen
                                                      ? getFullWidgetHeight(
                                                          height: 3)
                                                      : getWidgetHeight(
                                                          height: 3),
                                                  bottom: isSplitScreen
                                                      ? getFullWidgetHeight(
                                                          height: 3)
                                                      : getWidgetHeight(
                                                          height: 3),
                                                  right:
                                                      getWidgetWidth(width: 5)),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () async {
                                                  subCategoryTitile =
                                                      "Important Sounds";
                                                  sessionName = importantSounds
                                                      .subcategories![index]
                                                      .name!;
                                                  print(
                                                      "title check:${importantSounds.subcategories![index].name}");
                                                  print(
                                                      "subcateogries text :${importantSounds.subcategories![index].soundsPractice!.first.syllabels}");
                                                  List<SoundPracticeModel>?
                                                      soundsPractice =
                                                      importantSounds
                                                          .subcategories![index]
                                                          .soundsPractice;

                                                  List<Word> soundPractice =
                                                      soundsPractice
                                                              ?.map((sound) {
                                                            print(
                                                                "sps is is : ${sound.file}");
                                                            print(
                                                                "sps is is : ${sound.pronun}");
                                                            print(
                                                                "sps is is : ${sound.syllabels}");
                                                            print(
                                                                "sps is is : ${sound.text}");
                                                            return Word(
                                                              file: sound.file,
                                                              pronun:
                                                                  sound.pronun,
                                                              syllables: sound
                                                                  .syllabels, // Make sure to use the correct spelling
                                                              text: sound.text,
                                                            );
                                                          }).toList() ??
                                                          [];
                                                  List<Word> words =
                                                      await soundsWordsdb
                                                          .getWordsForSounds(
                                                              importantSounds
                                                                  .subcategories![
                                                                      index]
                                                                  .name!,
                                                              soundPractice);
                                                  print(
                                                      "sound practice : $words");
                                                  print(
                                                      "sound practice length: ${words.length}");
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfluentSubScreen(
                                                        ulr: importantSounds
                                                            .subcategories![
                                                                index]
                                                            .ulr,
                                                        title:
                                                            _categories[index]
                                                                .category!,
                                                        load: importantSounds
                                                            .subcategories![
                                                                index]
                                                            .name!,
                                                        links: importantSounds
                                                            .subcategories![
                                                                index]
                                                            .links!,
                                                        soundPractice: words,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          getWidgetWidth(
                                                              width: 12)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '${importantSounds.subcategories![index].name}',
                                                        style: TextStyle(
                                                          letterSpacing: 0,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: Keys
                                                              .lucidaFontFamily,
                                                          fontSize:
                                                              kText.scale(15),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Icon(
                                                        Icons
                                                            .chevron_right_rounded,
                                                        size: 30,
                                                        color: Color(
                                                          0xFF34445F,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: getWidgetWidth(
                                                      width: 10)),
                                              child: Divider(
                                                color: Color(0xFF34425D),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      itemCount:
                                          importantSounds.subcategories!.length,
                                    ),
                                  ),
                                  Scrollbar(
                                    controller: _scrollController2,
                                    thickness: 2,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      // physics: NeverScrollableScrollPhysics(),
                                      key: Key(
                                          'builder1 ${expansionTileIndex1.toString()}'),
                                      controller: _scrollController2,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: vowels.length,
                                      itemBuilder: (context, index) {
                                        //  controller.expandedIndex = -1;
                                        return Card(
                                          margin: EdgeInsets.only(
                                              bottom: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 14)
                                                  : getWidgetHeight(height: 14),
                                              right: getWidgetWidth(width: 5)),
                                          elevation: 0,
                                          color: Color(0xFF34425D),
                                          child: Theme(
                                            data: ThemeData(
                                              splashColor: Colors.transparent,
                                              dividerColor: Colors.transparent,
                                            ),
                                            child: Consumer<AuthState>(builder:
                                                (context, expansionController,
                                                    _) {
                                              return ExpansionTile(
                                                // key: Key(index.toString()),
                                                //maintainState: expanded[index],
                                                initiallyExpanded:
                                                    expansionTileIndex1 ==
                                                        index,
                                                onExpansionChanged: (expand) {
                                                  // expanded.clear();
                                                  //   expanded = List.generate(3, (index) => false);
                                                  //  expanded[index] = true;
                                                  setState(() {
                                                    print("djfijj");
                                                    expansionTileIndex1 = index;
                                                  });
                                                  if (vowels.length - 2 <=
                                                      index) {
                                                    print(
                                                        "function calleddddd");
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      _scrollToItemForVowels(
                                                          index);
                                                    });
                                                  }
                                                  setState(() {
                                                    for (int i = 0;
                                                        i < expanded.length;
                                                        i++) {
                                                      if (index == i) {
                                                        expanded[i] = expand;
                                                      } else {
                                                        expanded[i] = false;
                                                      }
                                                    }
                                                  });
                                                  subCategoryTitile =
                                                      vowels[index].category!;
                                                  log("expanded:${expanded}");
                                                  // _handleExpansion(index, expanded);
                                                  // setState(() {
                                                  //   print("checkkkk");
                                                  //   expansionController.changeExpansion(expanded, index);
                                                  // });
                                                  //  expansionController. expandedIndex = expanded == true ? index : -1;
                                                },
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      colorList[index],
                                                  child: Image.asset(
                                                    AllAssets.quickLinkPL,
                                                    scale: kIsWeb
                                                        ? 3
                                                        : displayWidth(
                                                                context) /
                                                            101.5,
                                                  ),
                                                ),
                                                title: Text(
                                                  "${vowels[index].category == 'Diphthong' ? '''Diphthong's''' : vowels[index].category}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: kText.scale(14),
                                                      fontFamily: 'Roboto',
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                iconColor: Colors.white,
                                                collapsedIconColor:
                                                    Color(0xFF64748B),
                                                children: [
                                                  ListView.separated(
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(
                                                      indent: 10,
                                                      endIndent: 10,
                                                      color: Color(0xFF617397),
                                                    ),
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: vowels[index]
                                                        .subcategories!
                                                        .length,
                                                    itemBuilder:
                                                        (context, subIndex) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            3)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            3)),
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onTap: (() async {
                                                                /*if (vowels[index].subcategories![subIndex].link != null) {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => InAppWebViewPage(
                                                                                  url: vowels[index]
                                                                                      .subcategories![subIndex]
                                                                                      .link!,
                                                                                )));
                                                                  }*/
                                                                print(
                                                                    "title check:${importantSounds.subcategories![index].name}");
                                                                print(
                                                                    "subcateogries text :${importantSounds1[index].subcategories![subIndex].soundsPractice!.first.text}");
                                                                List<SoundPracticeModel>?
                                                                    soundsPractice =
                                                                    importantSounds1[
                                                                            index]
                                                                        .subcategories![
                                                                            subIndex]
                                                                        .soundsPractice;

                                                                List<Word>
                                                                    soundPractice =
                                                                    soundsPractice
                                                                            ?.map((sound) {
                                                                          print(
                                                                              "sps is is : ${sound.file}");
                                                                          print(
                                                                              "sps is is : ${sound.pronun}");
                                                                          print(
                                                                              "sps is is : ${sound.syllabels}");
                                                                          print(
                                                                              "sps is is : ${sound.text}");
                                                                          return Word(
                                                                            file:
                                                                                sound.file,
                                                                            pronun:
                                                                                sound.pronun,
                                                                            syllables:
                                                                                sound.syllabels, // Make sure to use the correct spelling
                                                                            text:
                                                                                sound.text,
                                                                          );
                                                                        }).toList() ??
                                                                        [];
                                                                List<Word> words = await soundsWordsdb.getWordsForSounds(
                                                                    vowels[index]
                                                                        .subcategories![
                                                                            subIndex]
                                                                        .name!,
                                                                    soundPractice);
                                                                print(
                                                                    "sjdijf:${words}");
                                                                print(
                                                                    "djigjidjg:${vowels[index].subcategories![subIndex].name!}");
                                                                print(
                                                                    "sound practice : $soundPractice");
                                                                print(
                                                                    "sound practice length: ${soundPractice.length}");
                                                                sessionName = vowels[
                                                                        index]
                                                                    .subcategories![
                                                                        subIndex]
                                                                    .name!;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProfluentSubScreen(
                                                                      ulr: vowels[
                                                                              index]
                                                                          .subcategories![
                                                                              subIndex]
                                                                          .ulr,
                                                                      title: vowels[
                                                                              index]
                                                                          .subcategories![
                                                                              subIndex]
                                                                          .name!,
                                                                      load: vowels[
                                                                              index]
                                                                          .subcategories![
                                                                              subIndex]
                                                                          .name!,
                                                                      links: importantSounds1[
                                                                              index]
                                                                          .subcategories![
                                                                              subIndex]
                                                                          .links!,
                                                                      soundPractice:
                                                                          soundPractice,
                                                                    ),
                                                                  ),
                                                                );
                                                              }),
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: kIsWeb
                                                                        ? 20
                                                                        : getWidgetWidth(
                                                                            width:
                                                                                20),
                                                                    vertical: isSplitScreen
                                                                        ? getFullWidgetHeight(
                                                                            height:
                                                                                5)
                                                                        : getWidgetHeight(
                                                                            height:
                                                                                5)),
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          kIsWeb
                                                                              ? 0
                                                                              : getWidgetWidth(width: 12)),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        vowels[index]
                                                                            .subcategories![subIndex]
                                                                            .name!,
                                                                        style:
                                                                            TextStyle(
                                                                          letterSpacing:
                                                                              0,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontFamily:
                                                                              Keys.lucidaFontFamily,
                                                                          fontSize:
                                                                              kText.scale(14),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          if (vowels[index]
                                                                      .subcategories!
                                                                      .length -
                                                                  1 ==
                                                              subIndex)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                bottom: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            20)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            20),
                                                              ),
                                                              child: Divider(
                                                                color: Color(
                                                                    0xFF617397),
                                                                endIndent: 20,
                                                                indent: 20,
                                                              ),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Scrollbar(
                                    controller: _scrollController3,
                                    thickness: 2,
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      controller: _scrollController3,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      key: Key(
                                          'builder2 ${expansionTileIndex2.toString()}'),
                                      // physics: NeverScrollableScrollPhysics(),
                                      itemCount: consonants.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          margin: EdgeInsets.only(
                                              bottom: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 14)
                                                  : getWidgetHeight(height: 14),
                                              right: getWidgetWidth(width: 5)),
                                          elevation: 0,
                                          color: Color(0xFF34425D),
                                          child: Theme(
                                            data: ThemeData(
                                              splashColor: Colors.transparent,
                                              dividerColor: Colors.transparent,
                                            ),
                                            child: Consumer<AuthState>(builder:
                                                (context, expansionController,
                                                    _) {
                                              return ExpansionTile(
                                                initiallyExpanded:
                                                    expansionTileIndex2 ==
                                                        index,
                                                onExpansionChanged: (expanded) {
                                                  log("checking");
                                                  subCategoryTitile = consonants[
                                                          index]
                                                      .category!
                                                      .replaceFirst(
                                                          'Consonants Sounds: ',
                                                          '');
                                                  setState(() {
                                                    expansionTileIndex2 = index;
                                                  });
                                                  if (consonants.length - 2 <=
                                                      index) {
                                                    log("function calleddddd");
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      _scrollToItem(index);
                                                    });
                                                  }
                                                },
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      colorList[index],
                                                  child: Image.asset(
                                                    AllAssets.quickLinkPL,
                                                    scale: kIsWeb
                                                        ? 3
                                                        : displayWidth(
                                                                context) /
                                                            101.5,
                                                  ),
                                                ),
                                                title: Text(
                                                  "${consonants[index].category!.replaceFirst('Consonants Sounds: ', '')}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: kText.scale(14),
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                iconColor: Colors.white,
                                                collapsedIconColor:
                                                    Color(0xFF64748B),
                                                children: [
                                                  ListView.separated(
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            Divider(
                                                      indent: 10,
                                                      endIndent: 10,
                                                      color: Color(0xFF617397),
                                                    ),
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: consonants[index]
                                                        .subcategories!
                                                        .length,
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder:
                                                        (context, subIndex) {
                                                      return ListTile(
                                                        title: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          onTap: (() async {
                                                            /*if (consonants[index].subcategories![subIndex].link != null) {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => InAppWebViewPage(
                                                                              url: consonants[index]
                                                                                  .subcategories![subIndex]
                                                                                  .link!,
                                                                            )));
                                                              }*/
                                                            print(
                                                                "subcateogries text :${importantSounds2[index].subcategories![subIndex].soundsPractice!.first.text}");
                                                            List<SoundPracticeModel>?
                                                                soundsPractice =
                                                                importantSounds2[
                                                                        index]
                                                                    .subcategories![
                                                                        subIndex]
                                                                    .soundsPractice;

                                                            List<Word>
                                                                soundPractice =
                                                                soundsPractice?.map(
                                                                        (sound) {
                                                                      print(
                                                                          "sps is is : ${sound.file}");
                                                                      print(
                                                                          "sps is is : ${sound.pronun}");
                                                                      print(
                                                                          "sps is is : ${sound.syllabels}");
                                                                      print(
                                                                          "sps is is : ${sound.text}");
                                                                      return Word(
                                                                        file: sound
                                                                            .file,
                                                                        pronun:
                                                                            sound.pronun,
                                                                        syllables:
                                                                            sound.syllabels, // Make sure to use the correct spelling
                                                                        text: sound
                                                                            .text,
                                                                      );
                                                                    }).toList() ??
                                                                    [];
                                                            List<Word> words = await soundsWordsdb
                                                                .getWordsForSounds(
                                                                    consonants[
                                                                            index]
                                                                        .subcategories![
                                                                            subIndex]
                                                                        .name!,
                                                                    soundPractice);
                                                            print(
                                                                "sound practice : $soundPractice");
                                                            print(
                                                                "sound practice length: ${soundPractice.length}");
                                                            sessionName = consonants[
                                                                    index]
                                                                .subcategories![
                                                                    subIndex]
                                                                .name!;
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfluentSubScreen(
                                                                  ulr: consonants[
                                                                          index]
                                                                      .subcategories![
                                                                          subIndex]
                                                                      .ulr!,
                                                                  title: consonants[
                                                                          index]
                                                                      .subcategories![
                                                                          subIndex]
                                                                      .name!,
                                                                  load: consonants[
                                                                          index]
                                                                      .subcategories![
                                                                          subIndex]
                                                                      .name!,
                                                                  links: importantSounds2[
                                                                          index]
                                                                      .subcategories![
                                                                          subIndex]
                                                                      .links!,
                                                                  soundPractice:
                                                                      soundPractice,
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                          child: Text(
                                                            consonants[index]
                                                                .subcategories![
                                                                    subIndex]
                                                                .name!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Keys
                                                                  .lucidaFontFamily,
                                                              fontSize: kText
                                                                  .scale(14),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ),
      ),
    );
  }
}
