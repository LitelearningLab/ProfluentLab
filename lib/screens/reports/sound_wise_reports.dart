import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProfluentEnglish.dart';
import 'package:litelearninglab/screens/fast_track_pronunciation/fast_track_pronunciation_screen.dart';
import 'package:litelearninglab/screens/grammer_check/grammer_check_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/top_catetgories_card.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profluent_english/lab_screen.dart';

class SoundWiseReportScreen extends StatefulWidget {
  @override
  State<SoundWiseReportScreen> createState() => _SoundWiseReportScreenState();
}

class _SoundWiseReportScreenState extends State<SoundWiseReportScreen> {
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
    setState(() {});
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
    final size = MediaQuery.of(context).size;
    final controller = Provider.of<AuthState>(context, listen: false);
    controller.tabarIndex = 0;
    return BackgroundWidget(
      appBar: AppBar(
        title: Text("Sound Wise Report",
            style: TextStyle(
                // fontFamily: fontFamily ?? Keys.fontFamily,
                fontFamily: 'Roboto',
                fontSize: 17.5,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                overflow: TextOverflow.ellipsis)),
        backgroundColor: Color(0xFF293750),
        leading: IconButton(
          onPressed: () {
            print('Back Button tappedddd');
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
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
                                width: getWidgetWidth(width: 7),
                              ),
                              SizedBox(
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 15)
                                    : getWidgetHeight(height: 15),
                                width: getWidgetWidth(width: 15),
                                child: ImageIcon(
                                  AssetImage(AllAssets.infoIcon),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 14)
                                  : getWidgetHeight(height: 14)),
                          // ColorfulTabBar(
                          //   verticalTabPadding: 5,
                          //   alignment: TabAxisAlignment.end,
                          //   labelColor: Colors.white,
                          //   unselectedLabelColor: Color(0XFF99A0AE),
                          //   selectedHeight: 32,
                          //   unselectedHeight: 32,
                          //   tabShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
                          //   indicatorHeight: 0,
                          //   tabs: [
                          //     TabItem(
                          //         title: Text(
                          //           "10 Important Sounds",
                          //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          //         ),
                          //         color: Color(0XFF6C63FE),
                          //         unselectedColor: Color(0XFF34425D)),
                          //     TabItem(
                          //         title: Text(
                          //           "Vowels",
                          //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          //         ),
                          //         color: Color(0XFF6C63FE),
                          //         unselectedColor: Color(0XFF34425D)),
                          //     TabItem(
                          //         title: Text(
                          //           "Consonants",
                          //           style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              200),
                                                      color: Color(0XFF34425D)),
                                                  child: Text("Words practiced",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0XFF99A0AE)))),
                                              SizedBox(
                                                  width:
                                                      getWidgetWidth(width: 5)),
                                              Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              200),
                                                      color: Color(0XFF34425D)),
                                                  child: Text("Accuracy",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0XFF99A0AE)))),
                                            ],
                                          ),
                                          ListView.builder(
                                            // physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: importantSounds
                                                .subcategories!.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: isSplitScreen
                                                            ? getFullWidgetHeight(
                                                                height: 6)
                                                            : getWidgetHeight(
                                                                height: 6),
                                                        bottom: isSplitScreen
                                                            ? getFullWidgetHeight(
                                                                height: 6)
                                                            : getWidgetHeight(
                                                                height: 6),
                                                        right: getWidgetWidth(
                                                            width: 5)),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        print(
                                                            "title check1:${importantSounds.subcategories![index].name}");
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
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
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                left:
                                                                    getWidgetWidth(
                                                                        width:
                                                                            10)),
                                                            child: Text(
                                                              //"checking",
                                                              importantSounds
                                                                  .subcategories![
                                                                      index]
                                                                  .name!
                                                                  .replaceFirst(
                                                                      RegExp(
                                                                          r'[\(\[\:].*'),
                                                                      ''),
                                                              style: TextStyle(
                                                                letterSpacing:
                                                                    0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily: Keys
                                                                    .lucidaFontFamily,
                                                                fontSize: kText
                                                                    .scale(15),
                                                              ),
                                                            ),
                                                          ),
                                                          /* Spacer(),
                                                          Icon(
                                                            Icons.chevron_right_rounded,
                                                            size: 30,
                                                            color: Color(
                                                              0xFF34445F,
                                                            ),
                                                          ),*/
                                                        ],
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
                                          ),
                                        ],
                                      ),
                                    ],
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
                                            dividerColor: Colors.transparent,
                                          ),
                                          child: Consumer<AuthState>(builder:
                                              (context, expansionController,
                                                  _) {
                                            return ExpansionTile(
                                              // key: Key(index.toString()),
                                              //maintainState: expanded[index],
                                              initiallyExpanded:
                                                  expansionTileIndex1 == index,
                                              onExpansionChanged: (expand) {
                                                // expanded.clear();
                                                //   expanded = List.generate(3, (index) => false);
                                                //  expanded[index] = true;
                                                setState(() {
                                                  expansionTileIndex1 = index;
                                                });
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
                                                print("expanded:${expanded}");
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
                                                  scale: displayWidth(context) /
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
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200),
                                                              color: Color(
                                                                  0XFF293750)),
                                                          child: Text(
                                                              "Words practice",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white))),
                                                      SizedBox(
                                                          width: getWidgetWidth(
                                                              width: 5)),
                                                      Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200),
                                                              color: Color(
                                                                  0XFF293750)),
                                                          child: Text(
                                                              "Accuracy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white))),
                                                    ],
                                                  ),
                                                ),
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
                                                                      height: 3)
                                                                  : getWidgetHeight(
                                                                      height:
                                                                          3)),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            onTap: (() {
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
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ProfluentSubScreen(
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
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      getWidgetWidth(
                                                                          width:
                                                                              20),
                                                                  vertical: isSplitScreen
                                                                      ? getFullWidgetHeight(
                                                                          height:
                                                                              5)
                                                                      : getWidgetHeight(
                                                                          height:
                                                                              5)),
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        getWidgetWidth(
                                                                            width:
                                                                                12)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      vowels[index]
                                                                          .subcategories![
                                                                              subIndex]
                                                                          .name!,
                                                                      style:
                                                                          TextStyle(
                                                                        letterSpacing:
                                                                            0,
                                                                        color: Colors
                                                                            .white,
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
                                                                EdgeInsets.only(
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
                                            dividerColor: Colors.transparent,
                                          ),
                                          child: Consumer<AuthState>(builder:
                                              (context, expansionController,
                                                  _) {
                                            return ExpansionTile(
                                              initiallyExpanded:
                                                  expansionTileIndex2 == index,
                                              onExpansionChanged: (expanded) {
                                                setState(() {
                                                  expansionTileIndex2 = index;
                                                });
                                              },
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    colorList[index],
                                                child: Image.asset(
                                                  AllAssets.quickLinkPL,
                                                  scale: displayWidth(context) /
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
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200),
                                                              color: Color(
                                                                  0XFF293750)),
                                                          child: Text(
                                                              "Words practice",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white))),
                                                      SizedBox(
                                                          width: getWidgetWidth(
                                                              width: 5)),
                                                      Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200),
                                                              color: Color(
                                                                  0XFF293750)),
                                                          child: Text(
                                                              "Accuracy",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white))),
                                                    ],
                                                  ),
                                                ),
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
                                                        splashColor:
                                                            Colors.transparent,
                                                        onTap: (() {
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
                                                              "title check:${consonants[index].subcategories![subIndex].name!}");
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfluentSubScreen(
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
                                                            color: Colors.white,
                                                            fontFamily: Keys
                                                                .lucidaFontFamily,
                                                            fontSize:
                                                                kText.scale(14),
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
    );
  }
}

List<TextSpan> _buildTextSpans(String text) {
  List<TextSpan> spans = [];
  bool isWithinParentheses = false;
  StringBuffer buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    if (text[i] == '(') {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(
          text: buffer.toString(),
          style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: Keys.lucidaFontFamily),
        ));
        buffer.clear();
      }
      isWithinParentheses = true;
    } else if (text[i] == ')') {
      spans.add(TextSpan(
        text: ' ${buffer.toString()} ',
        style: TextStyle(
            color: Colors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: Keys.lucidaFontFamily),
      ));
      buffer.clear();
      isWithinParentheses = false;
    } else {
      buffer.write(text[i]);
    }
  }
  if (buffer.isNotEmpty) {
    spans.add(TextSpan(
      text: buffer.toString(),
      style: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: Keys.lucidaFontFamily),
    ));
  }

  return spans;
}
