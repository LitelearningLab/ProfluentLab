import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/bottom_navigation_bar_common.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/screens/reports/prolab_date_reports.dart';
import 'package:litelearninglab/screens/reports/speech_lab_date_reports.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';

class PronunciationReport extends StatefulWidget {
  PronunciationReport({Key? key}) : super(key: key);

  @override
  _PronunciationReportState createState() {
    return _PronunciationReportState();
  }
}

class _PronunciationReportState extends State<PronunciationReport> {
  FirebaseHelper db = new FirebaseHelper();
  bool _isLoading = false;
  Map<String, ProReport> _reports = {};

  @override
  void initState() {
    super.initState();
    _getReports();
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

  Future<void> _getReports() async {
    setState(() {
      _isLoading = true;
    });
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    var reports1 = await db.getProLabReports(userDatas.appUser!.id!);
    print('id is is :${userDatas.appUser!.id!}');
    print("reports1: ${reports1}");

    for (int i = 0; i < reports1.length; i++) {
      print("reports  aaaaaa1 worddddddd: ${reports1[i].word}");
      print("reports  aaaaaa1: ${reports1[i].timeCal}");
    }
    reports1.sort((a, b) => b.timeCal!.compareTo(a.timeCal as num));
    for (int i = 0; i < reports1.length; i++) {
      print("reports  aaaaaa1 worddddddd new : ${reports1[i].word}");
      print("reports  aaaaaa1 new: ${reports1[i].timeCal}");
    }
    print("_reports.length");
    print(reports1.length);
    var reports = reports1.where((element) =>
        /* element.correct != null &&*/ element.pracatt != null && element.pracatt != 0 /*&& element.correct != 0*/);
    for (ProLab pl in reports) {
      if (_reports[pl.word] == null) {
        _reports[pl.word!] = ProReport();
        _reports[pl.word]?.words = [];
      }
      _reports[pl.word]?.words?.add(pl);
      _reports[pl.word]?.correct = (_reports[pl.word]?.correct ?? 0) + (pl.correct ?? 0);
      _reports[pl.word]?.pracatt = (_reports[pl.word]?.pracatt ?? 0) + (pl.pracatt ?? 0);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: 'Pronunciation Lab report',
      ),
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
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                  color: context.read<AuthState>().currentIndex == 1
                                      ? Color(0xFFAAAAAA)
                                      : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(1);
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                  color: context.read<AuthState>().currentIndex == 2
                                      ? Color(0xFFAAAAAA)
                                      : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(2);
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                  color: context.read<AuthState>().currentIndex == 3
                                      ? Color(0xFFAAAAAA)
                                      : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(3);
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                              }),
                          IconButton(
                              icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                  color: context.read<AuthState>().currentIndex == 4
                                      ? Color(0xFFAAAAAA)
                                      : Color.fromARGB(132, 170, 170, 170)),
                              onPressed: () {
                                context.read<AuthState>().changeIndex(4);
                                Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                              }),
                        ],
                      ),
                    )
                  ],
                )
              : _reports.isEmpty && !_isLoading
                  ? Container(
                      width: displayWidth(context),
                      height: displayHeight(context),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: getWidgetWidth(width: 10),
                            right: getWidgetWidth(width: 10),
                            top: isSplitScreen ? getFullWidgetHeight(height: 5) : getWidgetHeight(height: 5),
                          ),
                          child: headings(context),
                        ),
                        Expanded(
                          child: ListView.builder(
                              padding: EdgeInsets.only(
                                  top: isSplitScreen ? getFullWidgetHeight(height: 8) : getWidgetHeight(height: 8),
                                  bottom:
                                      isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                              shrinkWrap: true,
                              itemCount: _reports.length,
                              itemBuilder: (context, index) {
                                print("index");
                                // print(_reports[index].toMap());
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    print("WrongWords:${_reports[_reports.keys.toList()[index]]?.pracatt.toString()}");
                                    print(
                                        "correctWords:${_reports[_reports.keys.toList()[index]]?.correct.toString()}");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProLabDateReports(
                                                  words: _reports[_reports.keys.toList()[index]]!.words!,
                                                )));
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            isSplitScreen ? getFullWidgetHeight(height: 8) : getWidgetHeight(height: 8),
                                        horizontal: getWidgetWidth(width: 10)),
                                    child: Container(
                                        height: isSplitScreen
                                            ? getFullWidgetHeight(height: 50)
                                            : getWidgetHeight(height: 50),
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
                                                _reports.keys.toList()[index],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: globalFontSize(kText.scale(16), context),
                                                ),
                                              ),
                                              SizedBox(
                                                width: displayWidth(context) / 3.3,
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
                                                          /*  _reports[_reports.keys.toList()[index]]?.pracatt.toString() ??
                                                              "0",*/
                                                          ((_reports[_reports.keys.toList()[index]]?.pracatt ?? 0) -
                                                                  (_reports[_reports.keys.toList()[index]]?.correct ??
                                                                      0))
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: globalFontSize(kText.scale(20), context),
                                                          ),
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
                                                          _reports[_reports.keys.toList()[index]]?.correct.toString() ??
                                                              "0",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: globalFontSize(kText.scale(20), context),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
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
                                    color: context.read<AuthState>().currentIndex == 0
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170),
                                  ),
                                  onPressed: () {
                                    context.read<AuthState>().changeIndex(0);
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                                  }),
                              IconButton(
                                  icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                      color: context.read<AuthState>().currentIndex == 1
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                                  onPressed: () {
                                    context.read<AuthState>().changeIndex(1);
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                                  }),
                              IconButton(
                                  icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                      color: context.read<AuthState>().currentIndex == 2
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                                  onPressed: () {
                                    context.read<AuthState>().changeIndex(2);
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                                  }),
                              IconButton(
                                  icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                      color: context.read<AuthState>().currentIndex == 3
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                                  onPressed: () {
                                    context.read<AuthState>().changeIndex(3);
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                                  }),
                              IconButton(
                                  icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                      color: context.read<AuthState>().currentIndex == 4
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170)),
                                  onPressed: () {
                                    context.read<AuthState>().changeIndex(4);
                                    Navigator.pushReplacement(
                                        context, MaterialPageRoute(builder: (context) => BottomNavigation()));
                                  }),
                            ],
                          ),
                        )
                      ],
                    ),
    );
  }
}

Padding headings(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: getWidgetWidth(width: 10),
      vertical: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "WORDS",
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
  );
}

class GradientDividerPronoun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidgetWidth(width: 0.2), // Full width of the parent container
      height: isSplitScreen ? getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36), // Height of the divider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // Color(0xFF676767),
            // Color(0xFF676767),
            Color(0xFF676767),
            // Color(0xFF676767),
            Color(0xFFFFFFFF),
            // Color(0xFFFFFFFF),
            // Color(0xFF676767),
            Color(0xFF676767),
            // Color(0xFF676767),
            // Color(0xFF676767),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class ProReport {
  int? correct = 0;
  List<ProLab>? words = [];
  int? pracatt = 0;

  ProReport({this.correct, this.words, this.pracatt});
}
