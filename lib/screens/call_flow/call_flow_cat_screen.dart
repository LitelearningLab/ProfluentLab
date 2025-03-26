import 'dart:async';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/SentenceCat.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import 'follow_up_screen.dart';

class CallFlowCatScreen extends StatefulWidget {
  CallFlowCatScreen({Key? key, required this.title, required this.user, required this.load}) : super(key: key);
  final AuthState user;
  final String title;
  final String load;
  @override
  _CallFlowCatScreenState createState() {
    return _CallFlowCatScreenState();
  }
}

class _CallFlowCatScreenState extends State<CallFlowCatScreen> {
  FirebaseHelperRTD db = new FirebaseHelperRTD();
  List<SentenceCat> _sentCat = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _getSentCat();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  void _getSentCat() async {
    setState(() {
      _isLoading = true;
    });
    _sentCat = await db.getSentencesCat(widget.load, "Call Flow Practice");
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: widget.title,
        // height: displayHeight(context) / 12.6875,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(
                          top: isSplitScreen ? getFullWidgetHeight(height: 14) : getWidgetHeight(height: 14),
                          left: getWidgetWidth(width: 20),
                          right: getWidgetWidth(width: 20)),
                      itemCount: _sentCat.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setStringList('FollowUpScreen', [_sentCat[index].title ?? "", _sentCat[index].title ?? "", widget.load]);
                                await prefs.setString('lastAccess', 'FollowUpScreen');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FollowUpScreen(
                                              user: widget.user,
                                              title: _sentCat[index].title ?? "",
                                              load: _sentCat[index].title ?? "",
                                              main: widget.load,
                                              // main: 'Denied As Maximum Benefits Exhausted',
                                            )));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _sentCat[index].title ?? "",
                                      style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily, fontSize: kText.scale(17)),
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
                                  )
                                ],
                              ),
                              /* child: Card(
                                margin: EdgeInsets.symmetric(vertical: 1),
                                color: Color(0xff333a40),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  child: Row(
                                    children: [
                                      Container(height: 9, width: 16, child: Image.asset("assets/images/left_arrow.png")),
                                      SPW(10),
                                      Flexible(
                                        child: Text(
                                          _sentCat[index].title ?? "",
                                          style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily, fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
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
                SizedBox(
                  height: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),
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
    );
  }
}
