import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/SpeechLab.dart';
import 'package:litelearninglab/screens/reports/speech_lab_date_reports.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';
import '../../constants/all_assets.dart';

class SpeechReport extends StatefulWidget {
  SpeechReport({Key? key}) : super(key: key);

  @override
  _SpeechReportState createState() {
    return _SpeechReportState();
  }
}

class _SpeechReportState extends State<SpeechReport> {
  // List<SpeechLab> _reports = [];
  FirebaseHelper db = new FirebaseHelper();
  Map<String, SpeechSum> _reports = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getReports();
  }
  
  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    print("splitScreen:${isSplitScreen}");
    setState((){});
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getReports() async {
    setState(() {
      _isLoading = true;
    });
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    var report = await db.getSpeechLabReports(userDatas.appUser!.id!);
    if (report.isNotEmpty)
      report.sort((a, b) => DateTime.parse(b.lastAttempt!).compareTo(DateTime.parse(a.lastAttempt!)));

    for (SpeechLab data in report) {
      if (_reports[data.sentence] == null) {
        _reports[data.sentence!] = SpeechSum();
        _reports[data.sentence]?.sentences = [];
      }
      _reports[data.sentence]?.sentences.add(data);

      _reports[data.sentence]?.attempts = (_reports[data.sentence]?.attempts ?? 0) + (data.pracatt ?? 0);
    }
    for (int i = 0; i < _reports.length; i++) {
      _reports[_reports.keys.toList()[i]]
          ?.sentences
          .sort((a, b) => DateTime.parse(b.lastAttempt!).compareTo(DateTime.parse(a.lastAttempt!)));
      _reports[_reports.keys.toList()[i]]?.lastScore = _reports[_reports.keys.toList()[i]]!.sentences.first.lastScore!;
    }
    setState(() {
      _isLoading = false;
    });
    print(_reports.length);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(title: "Sentence Construction Lab Report"),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _reports.length <= 0
              ? Column(
                children: [
                  Expanded(
                    child: Center(
                        child: Text(
                          'No Reports Found',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ),
                  Container(
                    height: isSplitScreen?  getFullWidgetHeight(height: 60) : getWidgetHeight(height: 60),
                    width: kWidth,
                    decoration: BoxDecoration(
                      color:  Color(0xFF34445F),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomHome),color: context.read<AuthState>().currentIndex == 0 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170),), onPressed: () {
                          context.read<AuthState>().changeIndex(0);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPL),color: context.read<AuthState>().currentIndex == 1 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(1);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomIS),color: context.read<AuthState>().currentIndex == 2 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(2);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPE),color: context.read<AuthState>().currentIndex == 3 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(3);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPT),color: context.read<AuthState>().currentIndex == 4 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
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
                        padding: EdgeInsets.only(top: isSplitScreen?  getFullWidgetHeight(height: 16) : getWidgetHeight(height: 16) ,bottom:  isSplitScreen?  getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),left:getWidgetWidth(width: 20),right: getWidgetWidth(width: 20)),
                        //physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          return 5 > 0
                              // _reports[_reports.keys.toList()[index]]!.attempts > 0
                              ? InkWell(
                            splashColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SpeechLabDateReports(
                                              
                                                  sentences: _reports[_reports.keys.toList()[index]]!.sentences,
                                                )));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: isSplitScreen?  getFullWidgetHeight(height: 8) : getWidgetHeight(height: 8)),
                                    child: Container(
                                      height: isSplitScreen?  getFullWidgetHeight(height: 114) : getWidgetHeight(height: 114),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: Color(0xFF34425D),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Container(
                                                    color: Color(0xFF34425D),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          _reports.keys.toList()[index] ?? "",
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: globalFontSize(kText.scale(12), context),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(bottom: isSplitScreen?  getFullWidgetHeight(height: 4) : getWidgetHeight(height: 4)),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Last attempt score",
                                                                    textAlign: TextAlign.start,
                                                                    style: TextStyle(
                                                                      color: const Color(0xFF41C94C),
                                                                      fontSize: globalFontSize(kText.scale(11), context),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _reports[_reports.keys.toList()[index]]!
                                                                            .lastScore
                                                                            .toStringAsFixed(0) +
                                                                        "%",
                                                                    style: TextStyle(
                                                                      fontSize: globalFontSize(kText.scale(11), context),
                                                                      color: Colors.white,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            LinearPercentIndicator(
                                                              padding: EdgeInsets.all(0),
                                                              barRadius: const Radius.circular(50),
                                                              // width: displayWidth(context) / 2.16,
                                                              lineHeight: displayHeight(context) / 162.4,
                                                              percent: _reports[_reports.keys.toList()[index]]!
                                                                  .lastScore/100,
                                                              backgroundColor: const Color(0xFFFFFFFF),
                                                              progressColor: const Color(0xFF41C94C),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            Container(
                                              width: getWidgetWidth(width: 93),//displayWidth(context) / 4,
                                              color: Color(0xFF6C63FE),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    (_reports[_reports.keys.toList()[index]]?.attempts).toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: globalFontSize(kText.scale(26), context),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Total\nAttempts",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: globalFontSize(kText.scale(12), context),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              //  Container(
                              //     color: Colors.yellow,
                              //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              //     child: Column(
                              //       children: [
                              //         InkWell(
                              //           onTap: () {
                              //             Navigator.push(
                              //                 context,
                              //                 MaterialPageRoute(
                              //                     builder: (context) => SpeechLabDateReports(
                              //                           sentences: _reports[_reports.keys.toList()[index]]!.sentences,
                              //                         )));
                              //           },
                              //           child: Container(
                              //             //width: 300,
                              //             height: 60,
                              //             decoration: new BoxDecoration(
                              //               borderRadius: new BorderRadius.only(topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0)),
                              //               color: AppColors.primary,
                              //             ),
                              //             child: Row(
                              //               children: [
                              //                 Padding(
                              //                   padding: const EdgeInsets.symmetric(horizontal: 10),
                              //                   child: Container(
                              //                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              //                     decoration: new BoxDecoration(
                              //                       borderRadius: new BorderRadius.all(Radius.circular(40.0)),
                              //                       color: AppColors.c40000000,
                              //                     ),
                              //                     child: Text(
                              //                       "5-ABC",
                              //                       // (_reports[_reports.keys.toList()[index]]?.attempts).toString(),
                              //                       style: TextStyle(fontFamily: Keys.fontFamily, fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 Text(
                              //                   "Total\nAttempts",
                              //                   style: TextStyle(fontFamily: Keys.fontFamily, fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w500),
                              //                 ),
                              //                 Spacer(),
                              //                 Text(
                              //                   "Last Attempts\nScore",
                              //                   textAlign: TextAlign.right,
                              //                   style: TextStyle(fontFamily: Keys.fontFamily, fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                              //                 ),
                              //                 Padding(
                              //                   padding: const EdgeInsets.symmetric(horizontal: 10),
                              //                   child: Container(
                              //                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              //                     decoration: new BoxDecoration(
                              //                       borderRadius: new BorderRadius.all(Radius.circular(40.0)),
                              //                       color: AppColors.c40000000,
                              //                     ),
                              //                     child: Text(
                              //                       '50%-ABC',
                              //                       // _reports[_reports.keys.toList()[index]]!.lastScore.toStringAsFixed(0) + "%",
                              //                       style: TextStyle(fontFamily: Keys.fontFamily, fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //         Container(
                              //           margin: EdgeInsets.symmetric(horizontal: 30),
                              //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              //           color: Colors.white,
                              //           child: Row(
                              //             children: [
                              //               Flexible(
                              //                 child: Text(
                              //                   "What is the claim denied?-ABC",
                              //                   // _reports.keys.toList()[index],
                              //                   style: TextStyle(fontFamily: Keys.fontFamily, fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         )
                              //       ],
                              //     ),
                              //   )
                              : Container(
                                  height: isSplitScreen?  getFullWidgetHeight(height: 200) : getWidgetHeight(height: 200),
                                  color: Colors.yellowAccent,
                                );
                        }),
                  ),
                  Container(
                    height: isSplitScreen?  getFullWidgetHeight(height: 60) : getWidgetHeight(height: 60),
                    width: kWidth,
                    decoration: BoxDecoration(
                      color:  Color(0xFF34445F),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomHome),color: context.read<AuthState>().currentIndex == 0 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170),), onPressed: () {
                          context.read<AuthState>().changeIndex(0);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPL),color: context.read<AuthState>().currentIndex == 1 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(1);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomIS),color: context.read<AuthState>().currentIndex == 2 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(2);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPE),color: context.read<AuthState>().currentIndex == 3 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
                          context.read<AuthState>().changeIndex(3);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                        }),
                        IconButton(icon: ImageIcon(AssetImage(AllAssets.bottomPT),color: context.read<AuthState>().currentIndex == 4 ? Color(0xFFAAAAAA) : Color.fromARGB(132, 170, 170, 170)), onPressed: () {
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

class SpeechSum {
  int attempts = 0;
  double lastScore = 0.0;
  String? sentence;
  List<SpeechLab> sentences = [];
}
