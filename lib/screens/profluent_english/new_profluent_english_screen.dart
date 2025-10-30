// import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/screens/fast_track_pronunciation/fast_track_pronunciation_screen.dart';
import 'package:litelearninglab/screens/grammer_check/grammer_check_screen.dart';
import 'package:litelearninglab/screens/profluent_english/lab_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/top_catetgories_card.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../models/ProfluentEnglish.dart';
import '../../utils/firebase_helper.dart';

class NewProfluentEnglishScreen extends StatefulWidget {
  NewProfluentEnglishScreen({Key? key}) : super(key: key);

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

String repeatLoads = "";

class _ProcessLearningScreenState extends State<NewProfluentEnglishScreen> {
  int _selectedTabIndex = 0;
  FirebaseHelper db = new FirebaseHelper();
  List<ProfluentEnglish> _categories = [];
  List<ProfluentEnglish> vowels = [];
  List<ProfluentEnglish> consonants = [];
  ProfluentEnglish arFAs = ProfluentEnglish();
  late ProfluentEnglish importantSounds;
  bool _isLoading = false;
  late AutoScrollController controller;
  // String? _selectedWordOnClick;
  // bool _isProMenuOpen = false;
  // bool _isSentMenuOpen = false;
  // bool _isCallMenuOpen = false;
  // bool _isPerMenuOpen = false;
  late AuthState user;

  List<Color> colorList = [
    Color(0xFF5AB963),
    Color(0xFFDDD639),
    Color(0xFF9C2780),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
  ];

  @override
  void initState() {
    super.initState();
    user = Provider.of<AuthState>(context, listen: false);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _getWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getProfluentEnglish();
    _categories = _categories.reversed.toList();
    getImportantSoundsAndVowels();
    _isLoading = false;
    setState(() {});
  }

  void getImportantSoundsAndVowels() {
    int count = 0;
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].category == 'Important Sounds') {
        importantSounds = _categories[i];
      } else if (_categories[i].category == 'Long Vowels' ||
          _categories[i].category == 'Short Vowel' ||
          _categories[i].category == 'Diphthong') {
        vowels.add(_categories[i]);
        count++;
        log('${count}');
      } else if (_categories[i].category!.startsWith('Consonants')) {
        consonants.add(_categories[i]);
      } else if (_categories[i].category == 'Fast Track Pronunciation For AR') {
        arFAs = _categories[i];
        print("count>>>>>>>>>>>>>>>>>>");
        print(arFAs.category);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Provider.of<AuthState>(context, listen: false);
    controller.tabarIndex = 0;
    log("categoriessssssssssssssssssssssssssssss>>>>>>>>>>>>>>>>");

    return BackgroundWidget(
      appBar: CommonAppBar(
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
              : Column(
                  children: [
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Container(
                      // color: Colors.amber,
                      height: getWidgetHeight(height: 147),
                      width: size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            PETopCategoriesCard(
                              height: getWidgetHeight(height: 88.28),
                              width: getWidgetWidth(width: 96.11),
                              title: 'Pronunciation Lab',
                              imageUrl: AllAssets.pePl,
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'lastAccess', 'LabScreen');
                                await prefs.setStringList('LabScreen', [
                                  'Pronunciation Lab' ?? "",
                                  controller.pronunciationLabList.join(',,') ??
                                      "",
                                  'true'
                                ]);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LabScreen(
                                      pLIconKey: true,
                                      user: user,
                                      title: 'Pronunciation Lab',
                                      itemList: controller.pronunciationLabList,
                                    ),
                                  ),
                                );
                              },
                              cardColor: Color(0xFF398480),
                            ),
                            // SPW(10),
                            SizedBox(
                              width: 14,
                            ),
                            PETopCategoriesCard(
                              height: getWidgetHeight(height: 88.47),
                              width: getWidgetWidth(width: 103.76),
                              title: 'Sentence Lab',
                              imageUrl: AllAssets.peScl,
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'lastAccess', 'LabScreen');
                                await prefs.setStringList('LabScreen', [
                                  'Sentence Lab' ?? "",
                                  controller.sentenceConstructionLabList
                                          .join(',,') ??
                                      "",
                                  'true'
                                ]);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LabScreen(
                                      pLIconKey: true,
                                      user: user,
                                      title: 'Sentence Lab',
                                      itemList: controller
                                          .sentenceConstructionLabList,
                                    ),
                                  ),
                                );
                              },
                              cardColor: Color(0xFF445EA9),
                            ),
                            // SPW(10),
                            SizedBox(
                              width: 14,
                            ),
                            PETopCategoriesCard(
                              height: getWidgetHeight(height: 88.65),
                              width: getWidgetWidth(width: 106.03),
                              title: 'Call Flow Lab',
                              imageUrl: AllAssets.peCfpl,
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'lastAccess', 'LabScreen');
                                await prefs.setStringList('LabScreen', [
                                  'Call Flow Lab' ?? "",
                                  controller.callFlowPracticeLabList
                                          .join(',,') ??
                                      "",
                                  'true'
                                ]);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LabScreen(
                                      pLIconKey: true,
                                      user: user,
                                      title: 'Call Flow Lab',
                                      itemList:
                                          controller.callFlowPracticeLabList,
                                    ),
                                  ),
                                );
                              },
                              cardColor: Color(0xFF636CFF),
                            ),
                            // SPW(10),
                            SizedBox(
                              width: 14,
                            ),
                            PETopCategoriesCard(
                              height: getWidgetHeight(height: 88),
                              width: getWidgetWidth(width: 130.04),
                              title: 'Grammer Lab',
                              imageUrl: AllAssets.peGl,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GrammerCheckScreen()));
                              },
                              cardColor: Color(0xFFDC6379),
                            ),
                            // SPW(10),
                            SizedBox(
                              width: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: getWidgetHeight(height: 96),
                      width: getWidgetWidth(width: 335),
                      decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: InkWell(
                                onTap: () {
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
                                  // height: size.height * 0.054,
                                  width: size.width * 0.5,
                                  child: Text(
                                    'Fast Track\nPronunciation For AR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                      fontFamily: "Roboto",
                                      letterSpacing: 0,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                height: getWidgetHeight(height: 86),
                                width: getWidgetWidth(width: 131.19),
                                child: Image.asset(AllAssets.peFtpfar),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height -
                          kBottomNavigationBarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
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
                                  width: 7,
                                ),
                                SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: ImageIcon(
                                    AssetImage(AllAssets.infoIcon),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Consumer<AuthState>(
                              builder: (context, tabarController, _) {
                                return DefaultTabController(
                                  length: 3,
                                  child: Column(
                                    children: [
                                      TabBar(
                                        padding: EdgeInsets.zero,
                                        splashFactory: InkSplash.splashFactory,
                                        splashBorderRadius:
                                            BorderRadius.circular(30),
                                        enableFeedback: false,
                                        indicatorPadding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        onTap: (int) async {
                                          print('/////////// $int');
                                          _onTabChanged(int);
                                          // tabarController.changeTabarIndex(int);
                                        },
                                        labelPadding:
                                            EdgeInsets.only(right: 10),
                                        dividerColor: Colors.transparent,
                                        tabAlignment: TabAlignment.start,
                                        labelColor: Colors.white,
                                        isScrollable: true,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        unselectedLabelColor: Color(0xFF99A0AE),
                                        indicatorColor: Color(0xFF6C63FE),
                                        indicatorSize:
                                            TabBarIndicatorSize.label,
                                        indicator: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xFF6C63FE)),
                                        tabs: [
                                          Tab(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: _selectedTabIndex == 0
                                                    ? Colors.transparent
                                                    : Color(0xFF34425D),
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Important Sounds',
                                                  style: TextStyle(
                                                      color:
                                                          _selectedTabIndex == 0
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF99A0AE),
                                                      fontSize: 12,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: _selectedTabIndex == 1
                                                    ? Colors.transparent
                                                    : Color(0xFF34425D),
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Vowels',
                                                  style: TextStyle(
                                                      color:
                                                          _selectedTabIndex == 1
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF99A0AE),
                                                      fontSize: 12,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Tab(
                                            child: Container(
                                              height: 40,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: _selectedTabIndex == 2
                                                    ? Colors.transparent
                                                    : Color(0xFF34425D),
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Consonants',
                                                  style: TextStyle(
                                                      color:
                                                          _selectedTabIndex == 2
                                                              ? Colors.white
                                                              : Color(
                                                                  0xFF99A0AE),
                                                      fontSize: 12,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 15),
                                        child: Container(
                                          // color: Colors.yellow,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.53,
                                          /*  height: size.height / 2,*/
                                          width: size.width,
                                          child: TabBarView(
                                            // physics: NeverScrollableScrollPhysics(),
                                            children: [
                                              Scrollbar(
                                                thickness: 2,
                                                thumbVisibility: true,
                                                radius: Radius.circular(10),
                                                child: ListView.builder(
                                                  // physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  // separatorBuilder:
                                                  //     (context, index) => Divider(
                                                  //   color: Color(0xFF34425D),
                                                  // ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 3),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ProfluentSubScreen(
                                                                    title: _categories[
                                                                            index]
                                                                        .category!,
                                                                    load: importantSounds
                                                                        .subcategories![
                                                                            index]
                                                                        .name!,
                                                                    links: importantSounds
                                                                        .subcategories![
                                                                            index]
                                                                        .links!,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    '${importantSounds.subcategories![index].name}',
                                                                    style:
                                                                        TextStyle(
                                                                      letterSpacing:
                                                                          0,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                  ),
                                                                  Spacer(),
                                                                  Icon(
                                                                    Icons
                                                                        .chevron_right_rounded,
                                                                    size: 30,
                                                                    color:
                                                                        Color(
                                                                      0xFF34445F,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color:
                                                              Color(0xFF34425D),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  itemCount: importantSounds
                                                      .subcategories!.length,
                                                ),
                                              ),
                                              Scrollbar(
                                                thickness: 2,
                                                thumbVisibility: true,
                                                radius: Radius.circular(10),
                                                child: ListView.builder(
                                                  // physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: vowels.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    controller.expandedIndex =
                                                        -1;
                                                    return Card(
                                                      elevation: 0,
                                                      color: Color(0xFF34425D),
                                                      child: Theme(
                                                        data: ThemeData(
                                                          dividerColor: Colors
                                                              .transparent,
                                                        ),
                                                        child: Consumer<
                                                                AuthState>(
                                                            builder: (context,
                                                                expansionController,
                                                                _) {
                                                          return ExpansionTile(
                                                            key: Key(index
                                                                .toString()),
                                                            initiallyExpanded:
                                                                expansionController
                                                                    .isExpanded(
                                                                        index),
                                                            onExpansionChanged:
                                                                (expanded) {
                                                              setState(() {
                                                                expansionController
                                                                    .changeExpansion(
                                                                        expanded,
                                                                        index);
                                                              });
                                                              //  expansionController. expandedIndex = expanded == true ? index : -1;
                                                            },
                                                            leading:
                                                                CircleAvatar(
                                                              backgroundColor:
                                                                  colorList[
                                                                      index],
                                                              child:
                                                                  Image.asset(
                                                                AllAssets
                                                                    .quickLinkPL,
                                                                scale: displayWidth(
                                                                        context) /
                                                                    101.5,
                                                              ),
                                                            ),
                                                            title: Text(
                                                              "${vowels[index].category}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  letterSpacing:
                                                                      0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            iconColor:
                                                                Colors.white,
                                                            collapsedIconColor:
                                                                Color(
                                                                    0xFF64748B),
                                                            children: [
                                                              ListView
                                                                  .separated(
                                                                separatorBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        Divider(
                                                                  indent: 10,
                                                                  endIndent: 10,
                                                                  color: Color(
                                                                      0xFF617397),
                                                                ),
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemCount: vowels[
                                                                        index]
                                                                    .subcategories!
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        subIndex) {
                                                                  return Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                3),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              (() {
                                                                            if (vowels[index].subcategories![subIndex].link !=
                                                                                null) {
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => InAppWebViewPage(
                                                                                            url: vowels[index].subcategories![subIndex].link!,
                                                                                          )));
                                                                            }
                                                                          }),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                                                              child: Row(
                                                                                children: [
                                                                                  Text(
                                                                                    vowels[index].subcategories![subIndex].name!,
                                                                                    style: TextStyle(
                                                                                      letterSpacing: 0,
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontFamily: 'Roboto',
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (vowels[index].subcategories!.length -
                                                                              1 ==
                                                                          subIndex)
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(
                                                                            bottom:
                                                                                20,
                                                                          ),
                                                                          child:
                                                                              Divider(
                                                                            color:
                                                                                Color(0xFF617397),
                                                                            endIndent:
                                                                                20,
                                                                            indent:
                                                                                20,
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
                                                thickness: 2,
                                                thumbVisibility: true,
                                                radius: Radius.circular(10),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  // physics: NeverScrollableScrollPhysics(),
                                                  itemCount: consonants.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Card(
                                                      elevation: 0,
                                                      color: Color(0xFF34425D),
                                                      child: Theme(
                                                        data: ThemeData(
                                                          dividerColor: Colors
                                                              .transparent,
                                                        ),
                                                        child: Consumer<
                                                                AuthState>(
                                                            builder: (context,
                                                                expansionController,
                                                                _) {
                                                          return ExpansionTile(
                                                            initiallyExpanded:
                                                                expansionController
                                                                        .expandedIndex ==
                                                                    index,
                                                            onExpansionChanged:
                                                                (expanded) {
                                                              setState(() {
                                                                expansionController
                                                                        .expandedIndex =
                                                                    expanded
                                                                        ? index
                                                                        : -1;
                                                              });
                                                            },
                                                            leading:
                                                                CircleAvatar(
                                                              backgroundColor:
                                                                  colorList[
                                                                      index],
                                                              child:
                                                                  Image.asset(
                                                                AllAssets
                                                                    .quickLinkPL,
                                                                scale: displayWidth(
                                                                        context) /
                                                                    101.5,
                                                              ),
                                                            ),
                                                            title: Text(
                                                              "${consonants[index].category}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            iconColor:
                                                                Colors.white,
                                                            collapsedIconColor:
                                                                Color(
                                                                    0xFF64748B),
                                                            children: [
                                                              ListView
                                                                  .separated(
                                                                separatorBuilder:
                                                                    (context,
                                                                            index) =>
                                                                        Divider(
                                                                  indent: 10,
                                                                  endIndent: 10,
                                                                  color: Color(
                                                                      0xFF617397),
                                                                ),
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                itemCount: consonants[
                                                                        index]
                                                                    .subcategories!
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        subIndex) {
                                                                  return ListTile(
                                                                    title:
                                                                        InkWell(
                                                                      onTap:
                                                                          (() {
                                                                        if (consonants[index].subcategories![subIndex].link !=
                                                                            null) {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => InAppWebViewPage(
                                                                                        url: consonants[index].subcategories![subIndex].link!,
                                                                                      )));
                                                                        }
                                                                      }),
                                                                      child:
                                                                          Text(
                                                                        consonants[index]
                                                                            .subcategories![subIndex]
                                                                            .name!,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              13,
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
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
