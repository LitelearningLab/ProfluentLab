import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/screens/call_flow/call_flow_cat_screen.dart';
import 'package:litelearninglab/screens/dashboard/widgets/drop_down_menu.dart';
import 'package:litelearninglab/screens/dashboard/widgets/second_row_menu.dart';
import 'package:litelearninglab/screens/dashboard/widgets/sub_menu_item.dart';
import 'package:litelearninglab/screens/grammer_check/grammer_check_screen.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
import 'package:litelearninglab/screens/reports/speech_report.dart';
import 'package:litelearninglab/screens/sentences/sentences_screen.dart';
import 'package:litelearninglab/screens/webview/video_player_screen.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../models/ProfluentEnglish.dart';
import '../../models/ProfluentLink.dart';
import '../../utils/firebase_helper.dart';
import '../reports/call_flow_report.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class ProfluentEnglishScreen extends StatefulWidget {
  ProfluentEnglishScreen({Key? key}) : super(key: key);

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

String repeatLoad = "";

class _ProcessLearningScreenState extends State<ProfluentEnglishScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<ProfluentEnglish> _categories = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  String? _selectedWordOnClick;
  bool _isProMenuOpen = false;
  bool _isSentMenuOpen = false;
  bool _isCallMenuOpen = false;
  bool _isPerMenuOpen = false;
  late AuthState user;

  @override
  void initState() {
    super.initState();
    user = Provider.of<AuthState>(context, listen: false);
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    _getWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getProfluentEnglish();
    _categories = _categories.reversed.toList();
    // isPlaying = List.generate(_categories.length, (index) => false);
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        appbarIcon: AllAssets.quickLinkPL,
        title: "Profluent English",
        // height: displayHeight(context) / 12.6875,
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      DropDownMenu(
                        onExpansionChanged: (val) {
                          _isProMenuOpen = val;
                          _isCallMenuOpen = false;
                          _isPerMenuOpen = false;
                          _isSentMenuOpen = false;
                          setState(() {});
                        },
                        isExpand: _isProMenuOpen && !_isCallMenuOpen && !_isPerMenuOpen && !_isSentMenuOpen,
                        icon: AllAssets.cvv1,
                        title: "PRONUNCIATION LAB",
                        children: [
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'daysdates';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Days, Dates, Months & Numbers",
                                            load: "daysdates",
                                          )));
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "Days, Dates, Months & Numbers",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'Latters and NATO';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Letters & NATP Phonetic Codes",
                                            load: "Latters and NATO",
                                          )));
                            },
                            backgroundImage: AllAssets.back2,
                            menuText: "Letters & NATP Phonetic Codes",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'States and Cities';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "US States & Cities",
                                            load: "States and Cities",
                                          )));
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "US States & Cities",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'CommonWords';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Most Commonly Used Words",
                                            load: "CommonWords",
                                          )));
                            },
                            backgroundImage: AllAssets.back2,
                            menuText: "Most Commonly Used Words",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'ProcessWords';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Common American Names",
                                            load: "ProcessWords",
                                          )));
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "Common American Names",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'US Healthcare';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "US Healthcare - Revenue Cycle Management",
                                            load: "US Healthcare",
                                          )));
                            },
                            backgroundImage: AllAssets.back2,
                            menuText: "US Healthcare - Revenue Cycle Management",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'Restaurant Hotel Travel';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Restaurant, Hotel & Travel",
                                            load: "Restaurant Hotel Travel",
                                          )));
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "Restaurant, Hotel & Travel",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'Business Words';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Business Words",
                                            load: "Business Words",
                                          )));
                            },
                            backgroundImage: AllAssets.back2,
                            menuText: "Business Words",
                            image: AllAssets.cvv1,
                          ),
                          SubMenuItem(
                            onTap: () {
                              repeatLoad = 'Information Technology';
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WordScreen(
                                            title: "Information Technology",
                                            load: "Information Technology",
                                          )));
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "Information Technology",
                            image: AllAssets.cvv1,
                          ),
                        ],
                      ),
                      Divider(
                        color: AppColors.black,
                        height: 0,
                        thickness: 1.5,
                      ),
                      DropDownMenu(
                          onExpansionChanged: (val) {
                            _isSentMenuOpen = val;
                            _isCallMenuOpen = false;
                            _isPerMenuOpen = false;
                            _isProMenuOpen = false;
                            setState(() {});
                          },
                          isExpand: _isSentMenuOpen && !_isCallMenuOpen && !_isPerMenuOpen && !_isProMenuOpen,
                          icon: AllAssets.cvv2,
                          title: "SENTENCE CONSTRUCTION LAB",
                          children: [
                            SubMenuItem(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SentencesScreen(
                                              user: user,
                                              title: "Professional Call Procedures",
                                              load: "Professional Call Procedures",
                                            )));
                              },
                              backgroundImage: AllAssets.back1,
                              menuText: "Professional Call Procedures",
                              image: AllAssets.cvv2,
                            ),
                            SubMenuItem(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SentencesScreen(
                                              user: user,
                                              title: "Questions Lab",
                                              load: "Questions Lab",
                                            )));
                              },
                              backgroundImage: AllAssets.back2,
                              menuText: "Questions Lab",
                              image: AllAssets.cvv2,
                            ),
                            SubMenuItem(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SentencesScreen(
                                              user: user,
                                              title: "Samples for frequent scenarios",
                                              load: "Samples for frequent scenarios",
                                            )));
                              },
                              backgroundImage: AllAssets.back1,
                              menuText: "Samples for frequent scenarios",
                              image: AllAssets.cvv2,
                            ),
                          ]),
                      Divider(
                        color: AppColors.black,
                        height: 0,
                        thickness: 1.5,
                      ),
                      DropDownMenu(
                        onExpansionChanged: (val) {
                          _isCallMenuOpen = val;
                          _isSentMenuOpen = false;
                          _isPerMenuOpen = false;
                          _isProMenuOpen = false;
                          setState(() {});
                        },
                        isExpand: _isCallMenuOpen && !_isProMenuOpen && !_isPerMenuOpen && !_isSentMenuOpen,
                        icon: AllAssets.cvv3,
                        title: "CALL FLOW PRACTICE LAB",
                        children: [
                          SubMenuItem(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CallFlowCatScreen(
                                    user: user,
                                    title: "Denial Management",
                                    load: "Denial Management",
                                  ),
                                ),
                              );
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: "Denial Management",
                            image: AllAssets.cvv3,
                          ),
                          SubMenuItem(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CallFlowCatScreen(
                                            user: user,
                                            title: "Non-Denials Follow-up",
                                            load: "Non Denials Follow up",
                                          )));
                            },
                            backgroundImage: AllAssets.back2,
                            menuText: "Non-Denials Follow-up",
                            image: AllAssets.cvv3,
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.red,
                        height: 0,
                        thickness: 1.5,
                      ),
                      Container(
                        // margin: EdgeInsets.only(left: 20),
                        // height: 400,
                        child: ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            itemCount: _categories.length,
                            // scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              // print(_processLeaning[index].toMap());
                              isPlaying = List.generate(_categories.length, (index) => false.obs);
                              return AutoScrollTag(
                                key: ValueKey(_categories[index].category),
                                controller: controller,
                                index: index,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(AllAssets.wordback),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: DropDownWordItem(
                                    index: index,
                                    load: "widget.load",
                                    // isPlaying: false,
                                    isButtonsVisible: false,
                                    isDownloaded: false,
                                    maintitle: "widget.title",
                                    // expKey: expansionTile,
                                    onExpansionChanged: (val) {
                                      if (val) {
                                        _selectedWordOnClick = _categories[index].category;
                                        setState(() {});
                                      }
                                    },
                                    // onClick: (val) {
                                    //   _selectedWordOnClick = val;
                                    //   setState(() {});
                                    //   // print(val);
                                    //   // expansionTile.currentState.setExpanded(
                                    //   //     _selectedWordOnClick != null &&
                                    //   //         _selectedWordOnClick == _words[index].text);
                                    // },
                                    initiallyExpanded: _selectedWordOnClick != null &&
                                        _selectedWordOnClick == _categories[index].category,
                                    isWord: false,
                                    isRefresh: (val) {
                                      // if (val) _getWords(isRefresh: true);
                                    },
                                    wordId: 1,
                                    isFav: 0,
                                    title: _categories[index].category ?? "",
                                    url: "_words[index].file",
                                    onTapForThreePlayerStop: () {},
                                    children: [
                                      for (ProfluentLink subCat in (_categories[index].subcategories ?? []))
                                        InkWell(
                                          onTap: () {
                                            if (subCat.links != null) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => ProfluentSubScreen(
                                                            title: _categories[index].category!,
                                                            load: subCat.name!,
                                                            links: subCat.links!,
                                                          )));
                                            } else if (subCat.link != null) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => InAppWebViewPage(
                                                            url: subCat.link!,
                                                          )));
                                            } else if (subCat.videoLink != null && subCat.videoLink!.isNotEmpty) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => VideoPlayerScreen(
                                                            url: subCat.videoLink!,
                                                          )));
                                            }
                                          },
                                          child: Container(
                                            color: Color(0xff202328),
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "-----${subCat.name}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontFamily: Keys.lucidaFontFamily),
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SecondRowMenu(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => GrammerCheckScreen()));
                          },
                          menuImage: AllAssets.kngl,
                          menu: "GRAMMAR\nCHECK",
                        ),
                      ),
                      Divider(
                        color: AppColors.black,
                        height: 0,
                        thickness: 1.5,
                      ),
                    ],
                  ),
                ),
    );
  }
}
