import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../constants/all_assets.dart';
import '../../models/ProcessLearningLink.dart';
import '../webview/video_player_screen.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class ProcessCatScreen extends StatefulWidget {
  ProcessCatScreen({Key? key, required this.linkCats, required this.title})
      : super(key: key);
  final List<ProcessLearningLink> linkCats;
  final String title;

  @override
  _ProcessCatScreenState createState() {
    return _ProcessCatScreenState();
  }
}

class _ProcessCatScreenState extends State<ProcessCatScreen> {
  String? _selectedWordOnClick;
  late AutoScrollController controller;
  List<String> processLearningLinks = [];

  bool _isLoading = false;

  @override
  void initState() {
    // isPlaying = List.generate(widget.linkCats.length, (index) => false);
    subCategoryTitile = widget.title;
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerMainCategory();
      },
      child: Scaffold(
        body: BackgroundWidget(
          appBar: CommonAppBar(
            title: widget.title,
            // height: displayHeight(context) / 12.6875,
          ),
          body: widget.linkCats.length == 0 && !_isLoading
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
                                  ? getFullWidgetHeight(height: 10)
                                  : getWidgetHeight(height: 10),
                              bottom: isSplitScreen
                                  ? getFullWidgetHeight(height: 10)
                                  : getWidgetHeight(height: 10)),
                          shrinkWrap: true,
                          controller: controller,
                          itemCount: widget.linkCats.length,
                          // scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            isPlaying = List.generate(
                                widget.linkCats.length, (index) => false.obs);
                            print(widget.linkCats[index].toMap());
                            return AutoScrollTag(
                              key: ValueKey(widget.linkCats[index].name),
                              controller: controller,
                              index: index,
                              child: Container(
                                decoration: BoxDecoration(
                                  // color: Colors.yellow,
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
                                    sessionName = widget.linkCats[index].name ??
                                        "not getting";
                                    log("printing the session ${sessionName}");
                                    if (val) {
                                      _selectedWordOnClick =
                                          widget.linkCats[index].name;
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
                                  initiallyExpanded:
                                      _selectedWordOnClick != null &&
                                          _selectedWordOnClick ==
                                              widget.linkCats[index].name,
                                  isWord: false,
                                  isRefresh: (val) {
                                    // if (val) _getWords(isRefresh: true);
                                  },
                                  wordId: 1,
                                  isFav: 0,
                                  title: widget.linkCats[index].name ?? "",
                                  url: "_words[index].file",
                                  onTapForThreePlayerStop: () {},
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      color: Color(0xff293750),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  if (widget.linkCats[index]
                                                              .video !=
                                                          null &&
                                                      widget.linkCats[index]
                                                          .video!.isNotEmpty) {
                                                    activityName = "Video";
                                                    sessionName = widget
                                                        .linkCats[index].name!;
                                                    startTimerMainCategory(
                                                        "name");
                                                    print(
                                                        'videoLinkkkkcheckkk:${widget.linkCats[index].video}');
                                                    String? links = widget
                                                        .linkCats[index].video;
                                                    processLearningLinks
                                                        .add(links!);
                                                    FirebaseFirestore
                                                        firestore =
                                                        FirebaseFirestore
                                                            .instance;
                                                    String userId =
                                                        await SharedPref
                                                            .getSavedString(
                                                                'userId');
                                                    DocumentReference
                                                        softSkills = firestore
                                                            .collection(
                                                                'processLearningReports')
                                                            .doc(userId);

                                                    await softSkills.update({
                                                      'isLink': FieldValue
                                                          .arrayUnion([
                                                        widget.linkCats[index]
                                                            .video
                                                      ]),
                                                    }).then((_) {
                                                      print(
                                                          'Link added to Firestore: ${widget.linkCats[index].video}');
                                                    }).catchError((e) {
                                                      print(
                                                          'Error updating Firestore: $e');
                                                    });
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                VideoPlayerScreen(
                                                                    url: widget
                                                                        .linkCats[
                                                                            index]
                                                                        .video!)));
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.play_circle_outline,
                                                  color: widget.linkCats[index]
                                                                  .video !=
                                                              null &&
                                                          widget.linkCats[index]
                                                              .video!.isNotEmpty
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  size: 30,
                                                ),
                                              ),
                                              SPW(15),
                                              InkWell(
                                                  onTap: () async {
                                                    if (widget.linkCats[index]
                                                                .simulation !=
                                                            null &&
                                                        widget
                                                            .linkCats[index]
                                                            .simulation!
                                                            .isNotEmpty) {
                                                      activityName =
                                                          "E-Learning";
                                                      sessionName = widget
                                                          .linkCats[index]
                                                          .name!;
                                                      String? links2 = widget
                                                          .linkCats[index]
                                                          .simulation;
                                                      processLearningLinks
                                                          .add(links2!);
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      String userId =
                                                          await SharedPref
                                                              .getSavedString(
                                                                  'userId');
                                                      DocumentReference
                                                          softSkills = firestore
                                                              .collection(
                                                                  'processLearningReports')
                                                              .doc(userId);

                                                      await softSkills.update({
                                                        'isLink': FieldValue
                                                            .arrayUnion([
                                                          widget.linkCats[index]
                                                              .simulation
                                                        ]),
                                                      }).then((_) {
                                                        print(
                                                            'Link added to Firestore: ${widget.linkCats[index].simulation}');
                                                      }).catchError((e) {
                                                        print(
                                                            'Error updating Firestore: $e');
                                                      });
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await prefs.setStringList(
                                                          'InAppWebViewPage', [
                                                        widget.linkCats[index]
                                                            .simulation!
                                                      ]);
                                                      await prefs.setString(
                                                          'lastAccess',
                                                          'InAppWebViewPage');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  InAppWebViewPage(
                                                                    url: widget
                                                                        .linkCats[
                                                                            index]
                                                                        .simulation!,
                                                                  )));
                                                    } else if (widget
                                                                .linkCats[index]
                                                                .eLearning !=
                                                            null &&
                                                        widget
                                                            .linkCats[index]
                                                            .eLearning!
                                                            .isNotEmpty) {
                                                      activityName =
                                                          "E-Learning";
                                                      sessionName = widget
                                                          .linkCats[index]
                                                          .name!;
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await prefs.setStringList(
                                                          'InAppWebViewPage', [
                                                        widget.linkCats[index]
                                                            .eLearning!
                                                      ]);
                                                      await prefs.setString(
                                                          'lastAccess',
                                                          'InAppWebViewPage');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  InAppWebViewPage(
                                                                    url: widget
                                                                        .linkCats[
                                                                            index]
                                                                        .eLearning!,
                                                                  )));
                                                    }
                                                  },
                                                  child: Image.asset(
                                                    AllAssets.interaction,
                                                    /*widget.linkCats[index].eLearning != null
                                                      ? AllAssets.interaction
                                                      : AllAssets.interb,*/
                                                    color: ((widget
                                                                        .linkCats[
                                                                            index]
                                                                        .eLearning !=
                                                                    null &&
                                                                widget
                                                                    .linkCats[
                                                                        index]
                                                                    .eLearning!
                                                                    .isNotEmpty) ||
                                                            (widget
                                                                        .linkCats[
                                                                            index]
                                                                        .eLearning ==
                                                                    null &&
                                                                widget
                                                                        .linkCats[
                                                                            index]
                                                                        .simulation !=
                                                                    null &&
                                                                widget
                                                                    .linkCats[
                                                                        index]
                                                                    .simulation!
                                                                    .isNotEmpty))
                                                        ? Colors.white
                                                        : Colors.grey,
                                                    width: 25,
                                                    height: 25,
                                                  )),
                                              SPW(15),
                                              InkWell(
                                                  onTap: () async {
                                                    if (widget.linkCats[index]
                                                                .faq !=
                                                            null &&
                                                        widget.linkCats[index]
                                                            .faq!.isNotEmpty) {
                                                      activityName = "FAQ";
                                                      sessionName = widget
                                                          .linkCats[index]
                                                          .name!;
                                                      print(
                                                          "LinkCheckkk:${widget.linkCats[index].faq}");
                                                      String? links3 = widget
                                                          .linkCats[index].faq;
                                                      processLearningLinks
                                                          .add(links3!);
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      String userId =
                                                          await SharedPref
                                                              .getSavedString(
                                                                  'userId');
                                                      DocumentReference
                                                          softSkills = firestore
                                                              .collection(
                                                                  'processLearningReports')
                                                              .doc(userId);

                                                      await softSkills.update({
                                                        'isLink': FieldValue
                                                            .arrayUnion([
                                                          widget.linkCats[index]
                                                              .faq
                                                        ]),
                                                      }).then((_) {
                                                        print(
                                                            'Link added to Firestore: ${widget.linkCats[index].faq}');
                                                      }).catchError((e) {
                                                        print(
                                                            'Error updating Firestore: $e');
                                                      });
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      await prefs.setStringList(
                                                          'InAppWebViewPage', [
                                                        widget.linkCats[index]
                                                            .faq!
                                                      ]);
                                                      await prefs.setString(
                                                          'lastAccess',
                                                          'InAppWebViewPage');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  InAppWebViewPage(
                                                                    url: widget
                                                                        .linkCats[
                                                                            index]
                                                                        .faq!,
                                                                  )));
                                                    }
                                                  },
                                                  child: Image.asset(
                                                    AllAssets.faq,
                                                    color: widget
                                                                    .linkCats[
                                                                        index]
                                                                    .faq !=
                                                                null &&
                                                            widget
                                                                .linkCats[index]
                                                                .faq!
                                                                .isNotEmpty
                                                        ? Colors.white
                                                        : Colors.grey,
                                                    width: 25,
                                                    height: 25,
                                                  )),
                                              SPW(15),
                                              InkWell(
                                                onTap: () async {
                                                  if (widget.linkCats[index]
                                                              .knowledge !=
                                                          null &&
                                                      widget
                                                          .linkCats[index]
                                                          .knowledge!
                                                          .isNotEmpty) {
                                                    activityName =
                                                        "Knowledge heck";
                                                    sessionName = widget
                                                        .linkCats[index].name!;
                                                    String? links4 = widget
                                                        .linkCats[index]
                                                        .knowledge;
                                                    processLearningLinks
                                                        .add(links4!);
                                                    FirebaseFirestore
                                                        firestore =
                                                        FirebaseFirestore
                                                            .instance;
                                                    String userId =
                                                        await SharedPref
                                                            .getSavedString(
                                                                'userId');
                                                    DocumentReference
                                                        softSkills = firestore
                                                            .collection(
                                                                'processLearningReports')
                                                            .doc(userId);

                                                    await softSkills.update({
                                                      'isLink': FieldValue
                                                          .arrayUnion([
                                                        widget.linkCats[index]
                                                            .knowledge
                                                      ]),
                                                    }).then((_) {
                                                      print(
                                                          'Link added to Firestore: ${widget.linkCats[index].knowledge}');
                                                    }).catchError((e) {
                                                      print(
                                                          'Error updating Firestore: $e');
                                                    });
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await prefs.setStringList(
                                                        'InAppWebViewPage', [
                                                      widget
                                                          .linkCats[index].faq!
                                                    ]);
                                                    await prefs.setString(
                                                        'lastAccess',
                                                        'InAppWebViewPage');
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                InAppWebViewPage(
                                                                  url: widget
                                                                      .linkCats[
                                                                          index]
                                                                      .knowledge!,
                                                                )));
                                                  }
                                                },
                                                child: Image.asset(
                                                  AllAssets.approval,
                                                  width: 25,
                                                  height: 25,
                                                  color: widget.linkCats[index]
                                                                  .knowledge !=
                                                              null &&
                                                          widget
                                                              .linkCats[index]
                                                              .knowledge!
                                                              .isNotEmpty
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SPH(10),
                                  ],
                                ),
                              ),
                            );

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
                    Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 55)
                          : getWidgetHeight(height: 55),
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
        ),
      ),
    );
  }
}
