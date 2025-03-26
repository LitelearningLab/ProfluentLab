import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/screens/dialogs/own_word_dialog.dart';
import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
import 'package:litelearninglab/screens/reports/speech_lab_date_reports.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';

class ProLabDateReports extends StatefulWidget {
  ProLabDateReports({Key? key, required this.words}) : super(key: key);
  final List<ProLab> words;

  @override
  _ProLabDateReportsState createState() {
    return _ProLabDateReportsState();
  }
}

class _ProLabDateReportsState extends State<ProLabDateReports> {
  List<ProLab> _reports = [];
  FirebaseHelper db = new FirebaseHelper();

  @override
  void initState() {
    super.initState();
    _reports = widget.words;
    // _getReports();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    print("splitScreen:${isSplitScreen}");
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<void> _getReports() async {
  //   AuthState userDatas = Provider.of<AuthState>(context, listen: false);
  //   _reports =
  //       await db.getProLabDateReports(userDatas.appUser.id, widget.word.word);
  //   setState(() {});
  //   print(_reports.length);
  // }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: "Pronunciation Lab report",
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getWidgetWidth(width: 20),
                vertical: isSplitScreen ? getFullWidgetHeight(height: 24) : getWidgetHeight(height: 24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    calenderWidget(context),
                    SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 24) : getWidgetHeight(height: 24)),
                    Text(
                      "Detailed Report",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: kText.scale(17),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: isSplitScreen ? getFullWidgetHeight(height: 24) : getWidgetHeight(height: 24),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "DATE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: globalFontSize(kText.scale(10), context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: displayWidth(context) / 3.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "WRONG",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: globalFontSize(kText.scale(10), context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "CORRECT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: globalFontSize(kText.scale(10), context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _reports.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            margin: EdgeInsets.only(
                                bottom: isSplitScreen ? getFullWidgetHeight(height: 16) : getWidgetHeight(height: 16)),
                            height: isSplitScreen ? getFullWidgetHeight(height: 52) : getWidgetHeight(height: 52),
                            decoration: BoxDecoration(
                              color: Color(0xFFF34425D),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _reports[index].date ?? "",
                                    style: TextStyle(color: Colors.white, fontSize: kText.scale(16)),
                                  ),
                                  SizedBox(
                                    width: getWidgetWidth(width: 115),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: getWidgetWidth(width: 34),
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 34)
                                              : getWidgetHeight(height: 34),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF293750),
                                          ),
                                          child: Center(
                                            child: Text(
                                              ((_reports[index].pracatt ?? 0) - (_reports[index].correct ?? 0))
                                                  .toString(),
                                              style: TextStyle(color: Colors.white, fontSize: kText.scale(20)),
                                            ),
                                          ),
                                        ),
                                        GradientDividerPronoun(),
                                        Container(
                                          width: getWidgetWidth(width: 34),
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 34)
                                              : getWidgetHeight(height: 34),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF293750),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _reports[index].correct.toString(),
                                              style: TextStyle(color: Colors.white, fontSize: kText.scale(20)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ));
                      },
                    ),
                  ],
                ),
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
                      color: context.read<AuthState>().currentIndex == 0
                          ? Color(0xFFAAAAAA)
                          : Color.fromARGB(132, 170, 170, 170),
                    ),
                    onPressed: () {
                      context.read<AuthState>().changeIndex(0);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                    }),
                IconButton(
                    icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                        color: context.read<AuthState>().currentIndex == 1
                            ? Color(0xFFAAAAAA)
                            : Color.fromARGB(132, 170, 170, 170)),
                    onPressed: () {
                      context.read<AuthState>().changeIndex(1);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                    }),
                IconButton(
                    icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                        color: context.read<AuthState>().currentIndex == 2
                            ? Color(0xFFAAAAAA)
                            : Color.fromARGB(132, 170, 170, 170)),
                    onPressed: () {
                      context.read<AuthState>().changeIndex(2);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                    }),
                IconButton(
                    icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                        color: context.read<AuthState>().currentIndex == 3
                            ? Color(0xFFAAAAAA)
                            : Color.fromARGB(132, 170, 170, 170)),
                    onPressed: () {
                      context.read<AuthState>().changeIndex(3);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                    }),
                IconButton(
                    icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                        color: context.read<AuthState>().currentIndex == 4
                            ? Color(0xFFAAAAAA)
                            : Color.fromARGB(132, 170, 170, 170)),
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

  Container calenderWidget(BuildContext context) {
    return Container(
      //height: displayHeight(context) / 5.88,
      decoration: BoxDecoration(
        color: Color(0xFFF34425D),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12),
            horizontal: getWidgetWidth(width: 14)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  // width: 36,
                  height: isSplitScreen ? getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36),
                  child: Row(
                    children: [
                      Container(
                        width: getWidgetWidth(width: 36),
                        height: isSplitScreen ? getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDC6379),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/calender.png',
                          /*height: displayHeight(context) / 44.29,
                          width: displayWidth(context) / 20.9,*/
                        ),
                      ),
                      SizedBox(width: getWidgetWidth(width: 10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _reports[0].date ?? "",
                            style: TextStyle(
                              fontSize: kText.scale(14),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Last attempt",
                            style: TextStyle(
                              fontSize: kText.scale(10),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  // width: displayWidth(context) / 2.3,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_reports.first.title != null && _reports.first.title == "own") {
                        showDialog(
                          useRootNavigator: true,
                          context: context,
                          builder: (BuildContext context) {
                            return OwnWordDialog(
                              isFromWord: true,
                              word: _reports.first.word ?? "",
                            );
                            // return OwnWordResultDialog();
                          },
                        );
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WordScreen(
                                      title: _reports.first.title ?? "",
                                      load: _reports.first.load ?? "",
                                      word: _reports.first,
                                    )));
                      }
                    },
                    child: Text(
                      "click here to practice",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: kText.scale(11),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),
            ),
            GradientDivider(),
            SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
            Text(
              _reports[0].word ?? "",
              style: TextStyle(
                fontSize: kText.scale(17),
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
