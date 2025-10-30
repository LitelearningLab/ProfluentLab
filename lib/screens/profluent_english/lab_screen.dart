import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/all_assets.dart';
// import 'package:litelearninglab/screens/call_flow/call_flow_cat_screen.dart';
import 'package:litelearninglab/screens/dashboard/widgets/new_submenu_items.dart';
import 'package:litelearninglab/screens/grammar_check/grammar_check_screen.dart';
import 'package:litelearninglab/screens/sentences/sentences_screen.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/bottom_navigation.dart';
import 'new_profluent_english_screen.dart';

class LabScreen extends StatefulWidget {
  final String title;
  final AuthState user;
  final List<Map<String, dynamic>> itemList;
  const LabScreen({
    required this.title,
    required this.itemList,
    required this.user,
    required this.pLIconKey,
    Key? key,
  }) : super(key: key);
  final bool pLIconKey;

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  @override
  void initState() {
    super.initState();
    subCategoryTitile = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthState>(context, listen: false);
    return PopScope(
      onPopInvoked: (didPop) {},
      child: BackgroundWidget(
        // bottomNav: BottomNavigationBarCommon(),
        appBar: widget.pLIconKey
            ? CommonAppBar(
                title: widget.title,
                isSearch: true,
                labType: widget.title,
                // height: displayHeight(context) / 12.6875,
              )
            : CommonAppBar(
                title: widget.title,
                appbarIcon: AllAssets.quickLinkPL,
                isSearch: true,
                // height: displayHeight(context) / 12.6875,
              ),
        body: Padding(
          padding: EdgeInsets.only(
              top: isSplitScreen
                  ? getFullWidgetHeight(height: 13)
                  : getWidgetHeight(height: 13)),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    //padding: EdgeInsets.only(bottom: isSplitScreen?  getFullWidgetHeight(height: 60) : getWidgetHeight(height: 60)),
                    itemCount: widget.itemList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          NewSubMenuItem(
                            onTap: () async {
                              // if (widget.title == "Grammer Lab") {
                              //   startTimerMainCategory("name");
                              // }
                              log("${widget.title}"); // startTimerMainCategory("name");
                              sessionName = widget.itemList[index]['title'];
                              print("indexcheckk:${index}");
                              repeatLoads = widget.itemList[index]['load'];
                              print(
                                  "title : ${widget.itemList[index]['title']}");
                              print("user : ${widget.user}");
                              print("load : ${widget.itemList[index]['load']}");
                              print("itemList:${widget.itemList}");
                              print(
                                  "checkkk:${widget.itemList[index]['load']}");
                              if (widget.itemList ==
                                  controller.callFlowPracticeLabList) {
                                print("dkpdidid u u d hdh");
                                print(widget.itemList[index]['title']);
                                print(widget.itemList[index]['load']);
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setStringList('CallFlowCatScreen', [
                                  widget.itemList[index]['title'] ?? "",
                                  widget.itemList[index]['load']
                                ]);
                                await prefs.setString(
                                    'lastAccess', 'CallFlowCatScreen');
                              } else if (widget.itemList ==
                                  controller.sentenceConstructionLabList) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setStringList('SentencesScreen', [
                                  widget.itemList[index]['title'] ?? "",
                                  widget.itemList[index]['load'] ?? ""
                                ]);
                                await prefs.setString(
                                    'lastAccess', 'SentencesScreen');
                              } else if (widget.itemList ==
                                  controller.pronunciationLabList) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setStringList('WordScreen', [
                                  widget.itemList[index]['title'],
                                  widget.itemList[index]['load']
                                ]);
                                await prefs.setString(
                                    'lastAccess', 'WordScreen');
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => widget.itemList ==
                                          controller.pronunciationLabList
                                      ? WordScreen(
                                          index: index,
                                          itemWordList: widget.itemList,
                                          controllerList:
                                              controller.pronunciationLabList,
                                          title: widget.itemList[index]
                                              ['title'],
                                          load: widget.itemList[index]['load'],
                                        )
                                      : widget.itemList ==
                                              controller
                                                  .sentenceConstructionLabList
                                          ? SentencesScreen(
                                              title: widget.itemList[index]
                                                  ['title'],
                                              user: widget.user,
                                              load: widget.itemList[index]
                                                  ['load'],
                                            )
                                          :
                                          // widget.itemList ==
                                          //         controller
                                          //             .callFlowPracticeLabList
                                          //     ? CallFlowCatScreen(
                                          //         title: widget.itemList[index]
                                          //             ['title'],
                                          //         user: widget.user,
                                          //         load: widget.itemList[index]
                                          //             ['load'],
                                          //       )
                                          //     :
                                          GrammarCheckScreen(
                                              title: widget.itemList[index]
                                                  ['title'],
                                              load: widget.itemList[index]
                                                  ['load'],
                                            ),
                                ),
                              );
                            },
                            backgroundImage: AllAssets.back1,
                            menuText: widget.itemList[index]['menuText'],
                            image: widget.itemList[index]['image'],
                            bgColor: widget.itemList[index]['bgColor'],
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
                                  builder: (context) => BottomNavigation()));
                        }),
                    IconButton(
                        icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                            color: context.read<AuthState>().currentIndex == 1
                                ? Color(0xFFAAAAAA)
                                : Color.fromARGB(132, 170, 170, 170)),
                        onPressed: () {
                          context.read<AuthState>().changeIndex(1);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavigation()));
                        }),
                    IconButton(
                        icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                            color: context.read<AuthState>().currentIndex == 2
                                ? Color(0xFFAAAAAA)
                                : Color.fromARGB(132, 170, 170, 170)),
                        onPressed: () {
                          context.read<AuthState>().changeIndex(2);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavigation()));
                        }),
                    IconButton(
                        icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                            color: context.read<AuthState>().currentIndex == 3
                                ? Color(0xFFAAAAAA)
                                : Color.fromARGB(132, 170, 170, 170)),
                        onPressed: () {
                          context.read<AuthState>().changeIndex(3);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavigation()));
                        }),
                    IconButton(
                        icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                            color: context.read<AuthState>().currentIndex == 4
                                ? Color(0xFFAAAAAA)
                                : Color.fromARGB(132, 170, 170, 170)),
                        onPressed: () {
                          context.read<AuthState>().changeIndex(4);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomNavigation()));
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
