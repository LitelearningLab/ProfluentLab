import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/models/SoftSkills.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../utils/firebase_helper.dart';
import '../webview/webview_screen.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class SoftSkillsScreen extends StatefulWidget {
  SoftSkillsScreen({Key? key}) : super(key: key);

  @override
  _ProcessLearningScreenState createState() {
    return _ProcessLearningScreenState();
  }
}

class _ProcessLearningScreenState extends State<SoftSkillsScreen> {
  FirebaseHelper db = new FirebaseHelper();
  List<SoftSkills> _categories = [];
  bool _isLoading = false;
  late AutoScrollController controller;
  String? _selectedWordOnClick;

  @override
  void initState() {
    super.initState();
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
    _categories = await db.getSoftSkills();
    _categories = _categories.reversed.toList();
    // isPlaying = List.generate(_categories.length, (index) => false);
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                      shrinkWrap: true,
                      controller: controller,
                      itemCount: _categories.length,
                      // scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        // print(_categories[index].toMap());
                        isPlaying = List.generate(_categories.length, (index) => false.obs);
                        return AutoScrollTag(
                          key: ValueKey(_categories[index].name),
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
                              load: "widget.load",
                              underContruction: _categories[index].link == null || _categories[index].link!.isEmpty,
                              // isPlaying: false,
                              isButtonsVisible: false,
                              index: index,
                              isDownloaded: false,
                              maintitle: "widget.title",
                              // expKey: expansionTile,
                              onExpansionChanged: (val) {
                                if (_categories[index].link != null) {
                                  print('-------------------- ${_categories[index].link!}');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => InAppWebViewPage(
                                                isLandscape: true,
                                                url: _categories[index].link!,
                                              )));
                                }
                                // } else if (val) {
                                _selectedWordOnClick = _categories[index].name;
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
                              initiallyExpanded:
                                  _selectedWordOnClick != null && _selectedWordOnClick == _categories[index].name,
                              isWord: false,
                              isRefresh: (val) {
                                // if (val) _getWords(isRefresh: true);
                              },
                              wordId: 1,
                              isFav: 0,
                              title: _categories[index].name ?? "",
                              url: "_words[index].file",
                              onTapForThreePlayerStop: () {},
                              children: [],
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
    );
  }
}
