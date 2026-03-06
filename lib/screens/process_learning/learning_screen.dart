import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/models/ProcessLearningLink.dart';
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
import 'widgets/web_hover_list_item.dart';
import 'widgets/web_hover_wrapper.dart';

class LearningScreen extends StatefulWidget {
  LearningScreen(
      {Key? key,
      required this.title,
      required this.linkCats,
      required this.icon})
      : super(key: key);
  final String title;
  final List<ProcessLearningLink> linkCats;
  final String icon;

  @override
  _LearningScreenState createState() {
    return _LearningScreenState();
  }
}

class _LearningScreenState extends State<LearningScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<SoftSkills> _categories = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  List<String> processLearningLinks = [];
  int activeLinkCount = 0;
  String? _selectedWordOnClick;
  @override
  void initState() {
    super.initState();
    startTimerSubCategory(processLearning, widget.title);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skillController = Provider.of<AuthState>(context, listen: false);
    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerSubCategory();
      },
      child: BackgroundWidget(
        appBar: kIsWeb
            ? null
            : CommonAppBar(
                title: widget.title,
              ),
        body: widget.linkCats.length == 0
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
                  if (!kIsWeb)
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
            : kIsWeb
                ? SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 40, left: 24, right: 24),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            Colors.grey.withValues(alpha: 0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_rounded,
                                        size: 20,
                                        color:
                                            Colors.black.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Back",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 50,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 25),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(32),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6C63FE)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ImageIcon(
                                            AssetImage(widget.icon),
                                            color: const Color(0xFF6C63FE),
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF1A1A1A),
                                                  letterSpacing: -0.8,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Detailed learning modules for specializations",
                                                style: TextStyle(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    child: Column(
                                      children: List.generate(
                                          widget.linkCats.length, (index) {
                                        return WebHoverListItem(
                                          title: widget.linkCats[index].name!,
                                          onTap: () async {
                                            sessionName =
                                                widget.linkCats[index].name!;
                                            if (widget.linkCats[index]
                                                    .eLearning !=
                                                null) {
                                              if (widget.linkCats[index]
                                                      .eLearning!.isEmpty ||
                                                  widget.linkCats[index]
                                                          .eLearning ==
                                                      null) {
                                                print(
                                                    '-----------------Invalid Link----------------');

                                                Toast.show("Work in progress",
                                                    duration: Toast.lengthShort,
                                                    gravity: Toast.bottom,
                                                    backgroundColor:
                                                        AppColors.white,
                                                    textStyle: const TextStyle(
                                                        color: AppColors.black),
                                                    backgroundRadius: 10);
                                              } else {
                                                print(
                                                    '-------------------- ${widget.linkCats[index].eLearning!}');
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setStringList(
                                                    'InAppWebViewPage', [
                                                  widget.linkCats[index]
                                                      .eLearning!,
                                                  widget.linkCats[index].name ==
                                                          'Meeting Etiquette'
                                                      ? "false"
                                                      : "true",
                                                  "true"
                                                ]);
                                                await prefs.setString(
                                                    'lastAccess',
                                                    'InAppWebViewPage');
                                                if (widget.linkCats[index]
                                                    .eLearning!.isNotEmpty) {
                                                  print("sjfdif");
                                                  String? links = widget
                                                      .linkCats[index]
                                                      .eLearning;
                                                  processLearningLinks
                                                      .add(links!);
                                                  print(
                                                      "categoriesLink: ${widget.linkCats[index].eLearning}");

                                                  FirebaseFirestore firestore =
                                                      FirebaseFirestore
                                                          .instance;
                                                  String userId =
                                                      await SharedPref
                                                          .getSavedString(
                                                              'userId');
                                                  DocumentReference
                                                      processLearning =
                                                      firestore
                                                          .collection(
                                                              'processLearningReports')
                                                          .doc(userId);

                                                  await processLearning.update({
                                                    'isLink':
                                                        FieldValue.arrayUnion([
                                                      widget.linkCats[index]
                                                          .eLearning!
                                                    ]),
                                                  }).then((_) {
                                                    print(
                                                        'Link added to Firestore: ${widget.linkCats[index].eLearning!}');
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
                                                              isLandscape: widget
                                                                          .linkCats[
                                                                              index]
                                                                          .eLearning ==
                                                                      'Meeting Etiquette'
                                                                  ? false
                                                                  : true,
                                                              isMeetingEtiquite:
                                                                  true,
                                                              url: widget
                                                                  .linkCats[
                                                                      index]
                                                                  .eLearning!,
                                                            )));
                                              }
                                            } else {
                                              _selectedWordOnClick =
                                                  widget.linkCats[index].name;
                                              setState(() {});
                                            }
                                          },
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            itemCount: widget.linkCats.length,
                            // scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              // print(_categories[index].toMap());
                              isPlaying = List.generate(
                                  widget.linkCats.length, (index) => false.obs);
                              return Column(
                                children: [
                                  AutoScrollTag(
                                    key: ValueKey(widget.linkCats[index].name),
                                    controller: controller,
                                    index: index,
                                    child: WebHoverWrapper(
                                      hoverDecoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: InkWell(
                                        splashColor:
                                            const Color.fromRGBO(0, 0, 0, 0),
                                        onTap: () async {
                                          sessionName =
                                              widget.linkCats[index].name!;
                                          if (widget
                                                  .linkCats[index].eLearning !=
                                              null) {
                                            if (widget.linkCats[index]
                                                    .eLearning!.isEmpty ||
                                                widget.linkCats[index]
                                                        .eLearning ==
                                                    null) {
                                              print(
                                                  '-----------------Invalid Link----------------');

                                              Toast.show("Work in progress",
                                                  duration: Toast.lengthShort,
                                                  gravity: Toast.bottom,
                                                  backgroundColor:
                                                      AppColors.white,
                                                  textStyle: TextStyle(
                                                      color: AppColors.black),
                                                  backgroundRadius: 10);
                                            } else {
                                              print(
                                                  '-------------------- ${widget.linkCats[index].eLearning!}');
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setStringList(
                                                  'InAppWebViewPage', [
                                                widget
                                                    .linkCats[index].eLearning!,
                                                widget.linkCats[index].name ==
                                                        'Meeting Etiquette'
                                                    ? "false"
                                                    : "true",
                                                "true"
                                              ]);
                                              await prefs.setString(
                                                  'lastAccess',
                                                  'InAppWebViewPage');
                                              if (widget.linkCats[index]
                                                  .eLearning!.isNotEmpty) {
                                                print("sjfdif");
                                                String? links = widget
                                                    .linkCats[index].eLearning;
                                                processLearningLinks
                                                    .add(links!);
                                                print(
                                                    "categoriesLink: ${widget.linkCats[index].eLearning}");

                                                FirebaseFirestore firestore =
                                                    FirebaseFirestore.instance;
                                                String userId = await SharedPref
                                                    .getSavedString('userId');
                                                DocumentReference
                                                    processLearning = firestore
                                                        .collection(
                                                            'processLearningReports')
                                                        .doc(userId);

                                                await processLearning.update({
                                                  'isLink':
                                                      FieldValue.arrayUnion([
                                                    widget.linkCats[index]
                                                        .eLearning!
                                                  ]),
                                                }).then((_) {
                                                  print(
                                                      'Link added to Firestore: ${widget.linkCats[index].eLearning!}');
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
                                                            isLandscape: widget
                                                                        .linkCats[
                                                                            index]
                                                                        .eLearning ==
                                                                    'Meeting Etiquette'
                                                                ? false
                                                                : true,
                                                            isMeetingEtiquite:
                                                                true,
                                                            url: widget
                                                                .linkCats[index]
                                                                .eLearning!,
                                                          )));
                                            }
                                          } else
                                            () {
                                              _selectedWordOnClick =
                                                  widget.linkCats[index].name;
                                              setState(() {});
                                            };
                                        },
                                        child: Container(
                                          width: displayWidth(context),
                                          padding: EdgeInsets.only(
                                              left: getWidgetWidth(width: 20),
                                              right: getWidgetWidth(width: 20),
                                              top: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 5)
                                                  : getWidgetHeight(height: 5),
                                              bottom: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 5)
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
                                                                    width: 1),
                                                            vertical: isSplitScreen
                                                                ? getFullWidgetHeight(
                                                                    height: 5)
                                                                : getWidgetHeight(
                                                                    height: 5)),
                                                        child: ImageIcon(
                                                          AssetImage(
                                                            widget.icon,
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
                                                      width: getWidgetWidth(
                                                          width: 10),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        widget.linkCats[index]
                                                            .name!,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                kText.scale(15),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: 0),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                  ),
                                  Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color(0xFF34445F),
                                  ),
                                ],
                              );
                            }),
                      ),
                      SizedBox(
                          height: isSplitScreen
                              ? getFullWidgetHeight(height: 10)
                              : getWidgetHeight(height: 10)),
                      if (!kIsWeb)
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
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPL),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomIS),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPE),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPT),
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
                        )
                    ],
                  ),
      ),
    );
  }
}
