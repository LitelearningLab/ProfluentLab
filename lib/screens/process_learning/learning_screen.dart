import 'package:cloud_firestore/cloud_firestore.dart';
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

class LearningScreen extends StatefulWidget {
  LearningScreen({Key? key, required this.title, required this.linkCats})
      : super(key: key);
  final String title;
  final List<ProcessLearningLink> linkCats;

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
        appBar: CommonAppBar(
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
                                child: InkWell(
                                  splashColor: const Color.fromRGBO(0, 0, 0, 0),
                                  onTap: () async {
                                    sessionName = widget.linkCats[index].name!;
                                    if (widget.linkCats[index].eLearning !=
                                        null) {
                                      if (widget.linkCats[index].eLearning!
                                              .isEmpty ||
                                          widget.linkCats[index].eLearning ==
                                              null) {
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
                                            '-------------------- ${widget.linkCats[index].eLearning!}');
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs
                                            .setStringList('InAppWebViewPage', [
                                          widget.linkCats[index].eLearning!,
                                          widget.linkCats[index].name ==
                                                  'Meeting Etiquette'
                                              ? "false"
                                              : "true",
                                          "true"
                                        ]);
                                        await prefs.setString(
                                            'lastAccess', 'InAppWebViewPage');
                                        if (widget.linkCats[index].eLearning!
                                            .isNotEmpty) {
                                          print("sjfdif");
                                          String? links =
                                              widget.linkCats[index].eLearning;
                                          processLearningLinks.add(links!);
                                          print(
                                              "categoriesLink: ${widget.linkCats[index].eLearning}");

                                          FirebaseFirestore firestore =
                                              FirebaseFirestore.instance;
                                          String userId =
                                              await SharedPref.getSavedString(
                                                  'userId');
                                          DocumentReference processLearning =
                                              firestore
                                                  .collection(
                                                      'processLearningReports')
                                                  .doc(userId);

                                          await processLearning.update({
                                            'isLink': FieldValue.arrayUnion([
                                              widget.linkCats[index].eLearning!
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
                                                      isMeetingEtiquite: true,
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
                                                backgroundColor: skillController
                                                        .softSkillData[index]
                                                    ['color'],
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
                                                  widget.linkCats[index].name!,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: kText.scale(15),
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
                              color: context.read<AuthState>().currentIndex == 0
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
                                    context.read<AuthState>().currentIndex == 1
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
                                    context.read<AuthState>().currentIndex == 2
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
                                    context.read<AuthState>().currentIndex == 3
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
                                    context.read<AuthState>().currentIndex == 4
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
