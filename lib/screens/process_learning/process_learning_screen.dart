import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/screens/process_learning/process_cat_screen.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../models/ProcessLearningMain.dart';
import '../../models/ProcessLearningSub.dart';
import '../../utils/firebase_helper.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class ProcessLearningScreen extends StatefulWidget {
  ProcessLearningScreen({Key? key}) : super(key: key);

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

class _ProcessLearningScreenState extends State<ProcessLearningScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<ProcessLearningMain> _processLeaning = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  String? _selectedWordOnClick;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical);

    _getWords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getWords() async {
    _isLoading = true;
    setState(() {});
    _processLeaning = [];
    _processLeaning = await db.getProcessLearning();
    _processLeaning = _processLeaning.reversed.toList();
    // isPlaying = List.generate(_processLeaning.length, (index) => false);
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        appbarIcon: AllAssets.quickLinkDM,
        title: "Process Learning",
        // height: displayHeight(context) / 12.6875,
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
              : Container(
                  // margin: EdgeInsets.only(left: 20),
                  // height: 400,
                  child: ListView.builder(
                      // shrinkWrap: true,
                      controller: controller,
                      itemCount: _processLeaning.length,
                      // scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        isPlaying = List.generate(_processLeaning.length, (index) => false.obs);
                        print(_processLeaning[index].toMap());
                        return AutoScrollTag(
                          key: ValueKey(_processLeaning[index].category),
                          controller: controller,
                          index: index,
                          child: DropDownWordItem(
                            index: index,
                            underContruction: _processLeaning[index].underconstruction != null && _processLeaning[index].underconstruction!,
                            load: "widget.load",
                            // isPlaying: false,
                            isButtonsVisible: false,
                            isDownloaded: false,
                            maintitle: "widget.title",
                            // expKey: expansionTile,
                            onExpansionChanged: (val) async {
                              log("tap index>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${index}");
                              if (_processLeaning[index].subcategories != null &&
                                  _processLeaning[index].subcategories!.length == 1 &&
                                  _processLeaning[index].category == _processLeaning[index].subcategories!.first.name) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('lastAccess', 'ProcessCatScreen');
                                await prefs.setStringList('ProcessCatScreen',
                                    [_processLeaning[index].subcategories!.first.name ?? "", jsonEncode(_processLeaning[index].subcategories!.first.linkCats)]);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProcessCatScreen(
                                              linkCats: _processLeaning[index].subcategories!.first.linkCats ?? [],
                                              title: _processLeaning[index].subcategories!.first.name ?? "",
                                            )));
                              }
                              // } else if (val) {
                              _selectedWordOnClick = _processLeaning[index].category;
                              setState(() {});
                              // }
                            },
                            // onClick: (val) {
                            //   _selectedWordOnClick = val;
                            //   setState(() {});
                            //   // print(val);
                            //   // expansionTile.currentState.setExpanded(
                            //   //     _selectedWordOnClick != null &&
                            //   //         _selectedWordOnClick == _words[index].text);
                            // },
                            initiallyExpanded: _selectedWordOnClick != null && _selectedWordOnClick == _processLeaning[index].category,
                            isWord: false,
                            isRefresh: (val) {
                              // if (val) _getWords(isRefresh: true);
                            },
                            wordId: 1,
                            isFav: 0,
                            onClick: _processLeaning[index].subcategories != null && _processLeaning[index].subcategories!.length == 1
                                ? (val) async {
                                    _selectedWordOnClick = _processLeaning[index].category;
                                    setState(() {});
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('lastAccess', 'ProcessCatScreen');
                                    await prefs.setStringList('ProcessCatScreen', [
                                      _processLeaning[index].subcategories!.first.name ?? "",
                                      jsonEncode(_processLeaning[index].subcategories!.first.linkCats ?? [])
                                    ]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProcessCatScreen(
                                                  linkCats: _processLeaning[index].subcategories!.first.linkCats ?? [],
                                                  title: _processLeaning[index].subcategories!.first.name ?? "",
                                                )));
                                  }
                                : null,
                            title: _processLeaning[index].category ?? "",
                            url: "_words[index].file",
                            onTapForThreePlayerStop: () {},
                            children: [
                              if (!(_processLeaning[index].subcategories != null &&
                                  _processLeaning[index].subcategories!.length == 1 &&
                                  _processLeaning[index].category == _processLeaning[index].subcategories!.first.name))
                                for (ProcessLearningSub subCat in (_processLeaning[index].subcategories ?? []))
                                  InkWell(
                                    onTap: () async {
                                      if (subCat.link != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => InAppWebViewPage(
                                                      url: subCat.link!,
                                                      // title: subCat.name ?? "",
                                                    )));
                                      } else if (subCat.linkCats != null && subCat.linkCats!.isNotEmpty) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        await prefs.setString('lastAccess', 'ProcessCatScreen');
                                        await prefs.setStringList('ProcessCatScreen', [subCat.name ?? "", jsonEncode(subCat.linkCats)]);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ProcessCatScreen(
                                                      linkCats: subCat.linkCats ?? [],
                                                      title: subCat.name ?? "",
                                                    )));
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      color: Color(0xff202328),
                                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${subCat.name}",
                                            style: TextStyle(color: Colors.white, fontSize: 17),
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
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
    );
  }
}
