import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/main.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../constants/all_assets.dart';
import '../../models/InteractiveLink.dart';
import '../../utils/shared_pref.dart';
import '../word_screen/widgets/drop_down_word_item.dart';

class InteracticeCatScreen extends StatefulWidget {
  InteracticeCatScreen({Key? key, required this.linkCats, required this.title}) : super(key: key);
  final List<InteractiveLink> linkCats;
  final String title;

  @override
  _ProcessCatScreenState createState() {
    return _ProcessCatScreenState();
  }
}

class _ProcessCatScreenState extends State<InteracticeCatScreen> {
  String? _selectedWordOnClick;
  late AutoScrollController controller;
  List<String> arCallSimulationsLinks = [];
  bool _isLoading = false;

  @override
  void initState() {
    startTimerSubCategory(arCallSimulation, widget.title);
    // isPlaying = List.generate(widget.linkCats.length, (index) => false);
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerSubCategory();
      },
      child: BackgroundWidget(
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
                  Container(
                    height: isSplitScreen ? getFullWidgetHeight(height: 60) : getWidgetHeight(height: 60),
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
                              color: context.read<AuthState>().currentIndex == 0 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170),
                            ),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(0);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                color: context.read<AuthState>().currentIndex == 1 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(1);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                color: context.read<AuthState>().currentIndex == 2 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(2);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                color: context.read<AuthState>().currentIndex == 3 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(3);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                color: context.read<AuthState>().currentIndex == 4 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(4);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                      ],
                    ),
                  )
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.only(
                            top: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),
                            bottom: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                        shrinkWrap: true,
                        controller: controller,
                        itemCount: widget.linkCats.length,
                        // scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          isPlaying = List.generate(widget.linkCats.length, (index) => false.obs);
                          print(widget.linkCats[index].toMap());
                          return AutoScrollTag(
                            key: ValueKey(widget.linkCats[index].name),
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
                                    _selectedWordOnClick = widget.linkCats[index].name;
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
                                initiallyExpanded: _selectedWordOnClick != null && _selectedWordOnClick == widget.linkCats[index].name,
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
                                    color: Color(0xff293750),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SPW(10),
                                        InkWell(
                                          onTap: () async {
                                            if (widget.linkCats[index].link1 != null && widget.linkCats[index].link1!.isNotEmpty) {
                                              print("LinkCheck:${widget.linkCats[index].link1}");
                                              String? links = widget.linkCats[index].link1;
                                              arCallSimulationsLinks.add(links!);
                                              FirebaseFirestore firestore = FirebaseFirestore.instance;
                                              String userId = await SharedPref.getSavedString('userId');
                                              DocumentReference arCallDocument = firestore.collection('arCallSimulationsReport').doc(userId);

                                              await arCallDocument.update({
                                                'isLink': FieldValue.arrayUnion([widget.linkCats[index].link1]),
                                              }).then((_) {
                                                print('Link added to Firestore: ${widget.linkCats[index].link1}');
                                              }).catchError((e) {
                                                print('Error updating Firestore: $e');
                                              });
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              await prefs.setStringList('InAppWebViewPage', [widget.linkCats[index].link1!]);
                                              await prefs.setString('lastAccess', 'InAppWebViewPage');
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => InAppWebViewPage(
                                                            url: widget.linkCats[index].link1!,
                                                          )));
                                            }
                                          },
                                          child: Wrap(
                                            children: [
                                              Text(
                                                "#1",
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              SPW(5),
                                              Image.asset(
                                                AllAssets.interb,
                                                color: (widget.linkCats[index].link1 != null && widget.linkCats[index].link1!.isNotEmpty)
                                                    ? Colors.white
                                                    : Colors.grey,
                                                width: 25,
                                                height: 25,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SPW(15),
                                        InkWell(
                                            onTap: () async {
                                              if (widget.linkCats[index].link2 != null && widget.linkCats[index].link2!.isNotEmpty) {
                                                print("LinkCheckkk:${widget.linkCats[index].link2}");
                                                String? links2 = widget.linkCats[index].link2;
                                                arCallSimulationsLinks.add(links2!);
                                                FirebaseFirestore firestore = FirebaseFirestore.instance;
                                                String userId = await SharedPref.getSavedString('userId');
                                                DocumentReference softSkills = firestore.collection('arCallSimulationsReport').doc(userId);

                                                await softSkills.update({
                                                  'isLink': FieldValue.arrayUnion([widget.linkCats[index].link2]),
                                                }).then((_) {
                                                  print('Link added to Firestore: ${widget.linkCats[index].link2}');
                                                }).catchError((e) {
                                                  print('Error updating Firestore: $e');
                                                });
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                await prefs.setStringList('InAppWebViewPage', [widget.linkCats[index].link2!]);
                                                await prefs.setString('lastAccess', 'InAppWebViewPage');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => InAppWebViewPage(
                                                              url: widget.linkCats[index].link2!,
                                                            )));
                                              }
                                            },
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  "#2",
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                                SPW(5),
                                                Image.asset(
                                                  AllAssets.interb,
                                                  color: (widget.linkCats[index].link2 != null && widget.linkCats[index].link2!.isNotEmpty)
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ],
                                            )),
                                        SPW(15),
                                        InkWell(
                                            onTap: () async {
                                              if (widget.linkCats[index].link3 != null && widget.linkCats[index].link3!.isNotEmpty) {
                                                print("LinkCheckkk:${widget.linkCats[index].link3}");
                                                String? links3 = widget.linkCats[index].link3;
                                                arCallSimulationsLinks.add(links3!);
                                                FirebaseFirestore firestore = FirebaseFirestore.instance;
                                                String userId = await SharedPref.getSavedString('userId');
                                                DocumentReference softSkills = firestore.collection('arCallSimulationsReport').doc(userId);
                                                await softSkills.update({
                                                  'isLink': FieldValue.arrayUnion([widget.linkCats[index].link3]),
                                                }).then((_) {
                                                  print('Link added to Firestore: ${widget.linkCats[index].link3}');
                                                }).catchError((e) {
                                                  print('Error updating Firestore: $e');
                                                });
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                await prefs.setStringList('InAppWebViewPage', [widget.linkCats[index].link3!]);
                                                await prefs.setString('lastAccess', 'InAppWebViewPage');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => InAppWebViewPage(
                                                              url: widget.linkCats[index].link3!,
                                                            )));
                                              }
                                            },
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  "#3",
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                                SPW(5),
                                                Image.asset(
                                                  AllAssets.interb,
                                                  color: (widget.linkCats[index].link3 != null && widget.linkCats[index].link3!.isNotEmpty)
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  width: 25,
                                                  height: 25,
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    height: isSplitScreen ? getFullWidgetHeight(height: 60) : getWidgetHeight(height: 60),
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
                              color: context.read<AuthState>().currentIndex == 0 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170),
                            ),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(0);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                color: context.read<AuthState>().currentIndex == 1 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(1);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                color: context.read<AuthState>().currentIndex == 2 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(2);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                color: context.read<AuthState>().currentIndex == 3 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(3);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                            }),
                        IconButton(
                            icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                color: context.read<AuthState>().currentIndex == 4 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)),
                            onPressed: () {
                              context.read<AuthState>().changeIndex(4);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
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
