import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/main.dart';
import 'package:litelearninglab/models/ProfluentEnglish.dart';
import 'package:litelearninglab/models/SentenceCat.dart';
import 'package:litelearninglab/screens/sentences/sentence_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../webview/video_player_screen.dart';

class fastTrackPronunciationScreen extends StatefulWidget {
  fastTrackPronunciationScreen({Key? key, required this.title}) : super(key: key);

  final ProfluentEnglish title;

  @override
  State<fastTrackPronunciationScreen> createState() => _fastTrackPronunciationScreenState();
}

late AuthState sentenceRepeatUser;
String sentenceRepeatLoad = "";

class _fastTrackPronunciationScreenState extends State<fastTrackPronunciationScreen> {
  FirebaseHelperRTD db = new FirebaseHelperRTD();

  bool _isLoading = false;

  @override
  void initState() {
    startTimerSubCategory(profluentEnglish, "Fast Track Pronunciation For AR");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didpop) {
        stopTimerSubCategory();
      },
      child: BackgroundWidget(
          appBar: CommonAppBar(
            title: widget.title.category!,
          ),
          body:
              // !_isLoading
              //     ?
              Column(
            children: [
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(
                        top: isSplitScreen ? getFullWidgetHeight(height: 14) : getWidgetHeight(height: 14),
                        bottom: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),
                        left: getWidgetWidth(width: 20),
                        right: getWidgetWidth(width: 20)),
                    itemCount: widget.title.subcategories!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                          InkWell(
                            onTap: () async {
                              print("video url:${widget.title.subcategories![index].videoLink!}");
                              // _isLoading = false;
                              // setState(() {});
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setStringList('InAppWebViewPage', [widget.title.subcategories![index].videoLink!]);
                              await prefs.setString('lastAccess', 'InAppWebViewPage');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                            url: widget.title.subcategories![index].videoLink!,
                                          )));
                              // Future.delayed(Duration(seconds: 20)).then((value) => _isLoading = true);
                              // setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //SPW(10),
                                Text(
                                  widget.title.subcategories![index].name ?? "",
                                  style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily, fontSize: kText.scale(17)),
                                ),
                                Container(
                                    height: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12),
                                    width: getWidgetWidth(width: 16),
                                    child: Image.asset("assets/images/left_arrow.png", color: Color(0xFF34445F))),
                              ],
                            ),
                          ),
                          SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                          Divider(
                            color: Color(0XFF34425D),
                            thickness: 1,
                          ),
                        ],
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
          )
          // : Center(
          //     child: CircularProgressIndicator(),)
          ),
    );
  }
}
