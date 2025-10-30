import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/models/SoftSkills.dart';
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
import '../webview/webview_screen.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class NewSoftSkillsScreen extends StatefulWidget {
  NewSoftSkillsScreen({Key? key}) : super(key: key);

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

class _ProcessLearningScreenState extends State<NewSoftSkillsScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<SoftSkills> _categories = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  List<String> softSkillLinks = [];
  int activeLinkCount = 0;
  String? _selectedWordOnClick;
  @override
  void initState() {
    super.initState();
    // startTimerMainCategory("Soft Skills");
    mianCategoryTitile = "Soft Skills";
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

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _categories = [];
    _categories = await db.getSoftSkills();
    _categories = _categories.reversed.toList();
    _isLoading = false;
    createDocumentWithSpecificId();
    setState(() {});
  }

  Future<void> createDocumentWithSpecificId() async {
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");

    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].link!.isNotEmpty) {
        print("sjfdif");
        activeLinkCount += 1;
        print("activeLinkCount: ${activeLinkCount}");
        //String? links = _categories[i].link;
        //  softSkillLinks.add(links!);
        // print("categoriesLink: ${_categories[i].link}");
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference softSkills =
        firestore.collection('softSkillReports').doc(userId);

    DocumentSnapshot snapshot = await softSkills.get();

    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExists");
      setState(() {
        softSkillLinks = List<String>.from(snapshot['isLink']);
      });
    }
    await softSkills.set({
      'activeLink': activeLinkCount,
      'isLink': softSkillLinks,
      'userId': userId,
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillController = Provider.of<AuthState>(context, listen: false);
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: "Soft Skills",
        // height: displayHeight(context) / 12.6875,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _categories.length == 0 && !_isLoading
              ? Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          "List is empty",
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: isSplitScreen
                            ? getFullWidgetHeight(height: 60)
                            : getWidgetHeight(height: 60),
                        width: kWidth,
                        decoration: BoxDecoration(
                          color: Color(0xFF34445F),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: ImageIcon(
                                  AssetImage(AllAssets.bottomHome),
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              0
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170),
                                ),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(0);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            1
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(1);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            2
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(2);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            3
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(3);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            4
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(4);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          padding: EdgeInsets.only(
                              top: isSplitScreen
                                  ? getFullWidgetHeight(height: 13)
                                  : getWidgetHeight(height: 13)),
                          shrinkWrap: true,
                          controller: controller,
                          itemCount: _categories.length,
                          // scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            // print(_categories[index].toMap());
                            isPlaying = List.generate(
                                _categories.length, (index) => false.obs);
                            return Column(
                              children: [
                                AutoScrollTag(
                                  key: ValueKey(_categories[index].name),
                                  controller: controller,
                                  index: index,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      sessionName = _categories[index].name!;
                                      if (_categories[index].link != null) {
                                        if (_categories[index].link!.isEmpty ||
                                            _categories[index].link == null) {
                                          print(
                                              '-----------------Invalid Link----------------');

                                          Toast.show("Work in progress",
                                              duration: Toast.lengthShort,
                                              gravity: Toast.bottom,
                                              backgroundColor: AppColors.white,
                                              textStyle: TextStyle(
                                                  color: AppColors.black),
                                              backgroundRadius: 10);
                                        } else {
                                          print(
                                              '-------------------- ${_categories[index].link!}');
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          // await prefs.setString('lastAccess',
                                          //     'NewSoftSkillsScreen');
                                          await prefs.setStringList(
                                              'InAppWebViewPage', [
                                            _categories[index].link!,
                                            _categories[index].name ==
                                                    'Meeting Etiquette'
                                                ? "false"
                                                : "true",
                                            "true"
                                          ]);
                                          await prefs.setString(
                                              'lastAccess', 'InAppWebViewPage');
                                          if (_categories[index]
                                              .link!
                                              .isNotEmpty) {
                                            print("sjfdif");
                                            String? links =
                                                _categories[index].link;
                                            softSkillLinks.add(links!);
                                            print(
                                                "categoriesLink: ${_categories[index].link}");

                                            FirebaseFirestore firestore =
                                                FirebaseFirestore.instance;
                                            String userId =
                                                await SharedPref.getSavedString(
                                                    'userId');
                                            DocumentReference softSkills =
                                                firestore
                                                    .collection(
                                                        'softSkillReports')
                                                    .doc(userId);

                                            await softSkills.update({
                                              'isLink': FieldValue.arrayUnion(
                                                  [_categories[index].link!]),
                                            }).then((_) {
                                              print(
                                                  'Link added to Firestore: ${_categories[index].link!}');
                                            }).catchError((e) {
                                              print(
                                                  'Error updating Firestore: $e');
                                            });
                                          }
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      InAppWebViewPage(
                                                        isLandscape: _categories[
                                                                        index]
                                                                    .name ==
                                                                'Meeting Etiquette'
                                                            ? false
                                                            : true,
                                                        isMeetingEtiquite: true,
                                                        url: _categories[index]
                                                            .link!,
                                                      )));
                                        }
                                      } else
                                        () {
                                          _selectedWordOnClick =
                                              _categories[index].name;
                                          setState(() {});
                                        };
                                    },
                                    child: Container(
                                      width: displayWidth(context),
                                      padding: EdgeInsets.only(
                                          left: getWidgetWidth(width: 20),
                                          right: getWidgetWidth(width: 20),
                                          top: isSplitScreen
                                              ? getFullWidgetHeight(height: 5)
                                              : getWidgetHeight(height: 5),
                                          bottom: isSplitScreen
                                              ? getFullWidgetHeight(height: 5)
                                              : getWidgetHeight(height: 5)),
                                      // onTap: onTap,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      skillController
                                                              .softSkillData[
                                                          index]['color'],
                                                  // colorList[index],
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            getWidgetWidth(
                                                                width: 8),
                                                        vertical: isSplitScreen
                                                            ? getFullWidgetHeight(
                                                                height: 8)
                                                            : getWidgetHeight(
                                                                height: 8)),
                                                    child: ImageIcon(
                                                      AssetImage(
                                                        skillController
                                                                .softSkillData[
                                                            index]['icon'],
                                                      ),
                                                    ),
                                                    // Image.asset(
                                                    //   image,
                                                    //   // scale: displayWidth(context)/101.5,
                                                    // ),
                                                  ),
                                                  radius: 18,
                                                ),
                                                SizedBox(
                                                  width:
                                                      getWidgetWidth(width: 10),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _categories[index].name!,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            kText.scale(15),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            // height: 30,
                                            // width: 30,
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              color: Color(0xFF34445F),
                                              size: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: Color(0xFF34445F),
                                ),
                              ],
                            );
                            //------------------------------------------------------------------------------
                            // AutoScrollTag(
                            //   key: ValueKey(_categories[index].name),
                            //   controller: controller,
                            //   index: index,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       image: DecorationImage(
                            //         image: AssetImage(AllAssets.wordback),
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //     child: DropDownWordItem(
                            //       load: "widget.load",
                            //       underContruction: _categories[index].link == null || _categories[index].link!.isEmpty,
                            //       // isPlaying: false,
                            //       isButtonsVisible: false,
                            //       index: index,
                            //       isDownloaded: false,
                            //       maintitle: "widget.title",
                            //       // expKey: expansionTile,
                            //       onExpansionChanged: (val) {
                            //         if (_categories[index].link != null) {
                            //           print('-------------------- ${_categories[index].link!}');
                            //           Navigator.push(
                            //               context,
                            //               MaterialPageRoute(
                            //                   builder: (context) => InAppWebViewPage(
                            //                         isLandscape: true,
                            //                         url: _categories[index].link!,
                            //                       )));
                            //         }
                            //         // } else if (val) {
                            //         _selectedWordOnClick = _categories[index].name;
                            //         setState(() {});
                            //         // }
                            //       },
                            //       // onClick: (val) {
                            //       //   _selectedWordOnClick = val;
                            //       //   setState(() {});
                            //       //   // print(val);
                            //       //   // expansionTile.currentState.setExpanded(
                            //       //   //     _selectedWordOnClick != null &&
                            //       //   //         _selectedWordOnClick == _words[index].text);
                            //       // },
                            //       initiallyExpanded: _selectedWordOnClick != null && _selectedWordOnClick == _categories[index].name,
                            //       isWord: false,
                            //       isRefresh: (val) {
                            //         // if (val) _getWords(isRefresh: true);
                            //       },
                            //       wordId: 1,
                            //       isFav: 0,
                            //       title: _categories[index].name ?? "",
                            //       url: "_words[index].file",
                            //       onTapForThreePlayerStop: () {},
                            //       children: [],
                            //     ),
                            //   ),
                            // );
                            //---------------------------------------------------------------------

                            //   InkWell(
                            //   onTap: () {
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => ProcessCatScreen(
                            //                   processLeaning:
                            //                       _processLeaning[index],
                            //                 )));
                            //   },
                            //   child: Container(
                            //       height: 400,
                            //       padding: EdgeInsets.all(20),
                            //       margin: EdgeInsets.only(right: 15),
                            //       width: displayWidth(context) * 0.8,
                            //       decoration: BoxDecoration(
                            //           color:
                            //               index % 2 == 0 ? Colors.blue : Colors.red,
                            //           borderRadius: BorderRadius.all(
                            //             Radius.circular(10.0),
                            //           )),
                            //       child: Column(
                            //         children: [
                            //           Image.asset(
                            //             AllAssets.linda,
                            //             width: displayWidth(context) * 0.5,
                            //           ),
                            //           Spacer(),
                            //           Text(
                            //             _processLeaning[index]
                            //                     .catname
                            //                     ?.toUpperCase() ??
                            //                 "",
                            //             style: TextStyle(
                            //                 fontFamily: Keys.fontFamily,
                            //                 fontSize: 18,
                            //                 color: Colors.white,
                            //                 fontWeight: FontWeight.w500),
                            //           ),
                            //           SPH(20)
                            //         ],
                            //       )),
                            // );
                          }),
                    ),
                    SizedBox(
                        height: isSplitScreen
                            ? getFullWidgetHeight(height: 10)
                            : getWidgetHeight(height: 10)),
                    Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 60)
                          : getWidgetHeight(height: 60),
                      width: kWidth,
                      decoration: BoxDecoration(
                        color: Color(0xFF34445F),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: ImageIcon(
                                AssetImage(AllAssets.bottomHome),
                                color:
                                    context.read<AuthState>().currentIndex == 0
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170),
                              ),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(0);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              1
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(1);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              2
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(2);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              3
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(3);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              4
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(4);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BottomNavigation()));
                              }),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
