import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/SpeechLab.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:litelearninglab/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../call_flow/follow_up_screen.dart';
import '../sentences/sentence_screen.dart';

class SpeechLabDateReports extends StatefulWidget {
  SpeechLabDateReports({Key? key, required this.sentences, this.isSpeech = true}) : super(key: key);
  final List<SpeechLab> sentences;
  final bool isSpeech;


  @override
  _SpeechLabDateReportsState createState() {
    return _SpeechLabDateReportsState();
  }
}

class _SpeechLabDateReportsState extends State<SpeechLabDateReports> {
  List<SpeechLab> _reports = [];
  FirebaseHelper db = new FirebaseHelper();
  late AuthState user;

  @override
  void initState() {
    super.initState();
    print("ojdidf  ihuhdfud  hhhfihfo");
    _reports = widget.sentences;
    // _getReports();
  }

  refreshFunc(){
    context.read<AuthState>().changeIndex(4);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState((){});
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<void> _getReports() async {
  //   AuthState userDatas = Provider.of<AuthState>(context, listen: false);
  //   _reports =
  //       await db.getSpeechLabDateReports(userDatas.appUser.id, widget.word.id);
  //   setState(() {});
  //   print(_reports.length);
  // }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
        appBar: CommonAppBar(
          title: widget.isSpeech ? "Sentence Construction Lab Report" : "Call Flow Practice Report",
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 20), vertical: isSplitScreen? getFullWidgetHeight(height: 19) : getWidgetHeight(height: 19)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    calenderWidget(context),
                    SizedBox(height: isSplitScreen?  getFullWidgetHeight(height: 24) : getWidgetHeight(height: 24),),
                    Text(
                      "Detailed Report",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: kText.scale(17),
                        color: Colors.white,
                      ),
                    ),
                  SizedBox(height: isSplitScreen?  getFullWidgetHeight(height: 16) : getWidgetHeight(height: 16),),
                    // headings(context),
                    ListView.builder(
                      shrinkWrap: true,
                     physics: NeverScrollableScrollPhysics(),
                      itemCount: _reports.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (_reports[index].focusWord != null && _reports[index].focusWord!.length > 0)
                          return  ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemCount: _reports[index].focusWord!.length,
                              itemBuilder: (BuildContext context,int index1){
                              print("djoududh : ${_reports[index].focusWord!}");
                            return Container(
                              margin: EdgeInsets.only(bottom: isSplitScreen?  getFullWidgetHeight(height: 16) : getWidgetHeight(height: 16),),
                              width: kWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                               borderRadius: BorderRadius.circular(7),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                //  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: getWidgetWidth(width: 68),
                                      decoration: BoxDecoration(
                                       // color: Color(0xFFF6C63FE),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(7),bottomLeft: Radius.circular(7)),
                                        color: Color(0xFFF6C63FE),
                                        border: Border.all(color: Color(0xFFF6C63FE))
                                      ),
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${_reports[index].focusWord!.values.toList()[index1].last}%",
                                            style: TextStyle(
                                              fontSize: globalFontSize(kText.scale(13), context),
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: isSplitScreen?  getFullWidgetHeight(height: 4) : getWidgetHeight(height: 4)),
                                          Text(
                                            "score",
                                            style: TextStyle(
                                              fontSize: globalFontSize(kText.scale(10), context),
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: isSplitScreen?  getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                                        width: displayWidth(context) / 1.5,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: getWidgetWidth(width: 8)),
                                            SizedBox(
                                              width: getWidgetWidth(width: 166),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Focus words",
                                                    style: TextStyle(
                                                      color: Color(0xFFFFF4B32),
                                                      fontSize: globalFontSize(kText.scale(12), context),
                                                    ),
                                                  ),
                                                  Text(_reports[index].focusWord!.values.toList()[index1].last == "100.00" ? 'NA' : _reports[index].focusWord!.values.toList()[index1].join(', ').substring(0,_reports[index].focusWord!.values.toList()[index1].join(', ').lastIndexOf(', ')).replaceAll('NA,',"").trim(),
                                                    // maxLines: 3,
                                                    style: TextStyle(
                                                      color: Color(0xFFF222222),
                                                      fontSize: kText.scale(12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: getWidgetWidth(width: 8)),
                                       //   Container(child: Image.asset("assets/images/vertical_line.png")),
                                            Flexible(
                                              child: VerticalDivider(
                                                color: Color(0XFF111111).withOpacity(0.5),
                                                thickness: 0.8,
                                                width: 0,
                                              ),
                                            ),
                                            SizedBox(
                                              width: getWidgetWidth(width: 85),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _reports[index].dateTime!,
                                                    style: TextStyle(
                                                      color: Color(0xFFF222222),
                                                      fontSize: globalFontSize(kText.scale(12), context),
                                                    ),
                                                  ),
                                                  Text(
                                                    Utils.convertTime(_reports[index].focusWord!.keys.toList()[index1],
                                                        isTimeOnly: true),
                                                    style: TextStyle(
                                                      color: Color(0xFF676767),
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: globalFontSize(kText.scale(10), context),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                      },
                    ),
                    /* Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        height: displayHeight(context) / 9.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Row(
                              children: [
                                Container(
                                  width: displayWidth(context) / 5.5,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF6C63FE),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "99.65%",
                                        style: TextStyle(
                                          fontSize: globalFontSize(13, context),
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "score",
                                        style: TextStyle(
                                          fontSize: globalFontSize(10, context),
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: SizedBox(
                                    width: displayWidth(context) / 1.5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: displayWidth(context) / 2.3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Focus words",
                                                style: TextStyle(
                                                  color: Color(0xFFFFF4B32),
                                                  fontSize: globalFontSize(12, context),
                                                ),
                                              ),
                                              SPH(2),
                                              Text(
                                                "Was, Claim Denied Linda, Can You Check Why This Claim Has Exceeded",
                                                maxLines: 3,
                                                style: TextStyle(
                                                  color: Color(0xFFF222222),
                                                  fontSize: globalFontSize(12, context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GradientDividerVertical(),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "01 may 2024",
                                              style: TextStyle(
                                                color: Color(0xFFF222222),
                                                fontSize: globalFontSize(12, context),
                                              ),
                                            ),
                                            Text(
                                              "01 : 26 PM",
                                              style: TextStyle(
                                                color: Color(0xFF676767),
                                                fontWeight: FontWeight.w700,
                                                fontSize: globalFontSize(10, context),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),*/
                    // pronounLab(context)
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Container pronounLab(BuildContext context) {
    return Container(
       // height: displayHeight(context) / 14.24,
        decoration: BoxDecoration(
          color: Color(0xFFF34425D),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal:getWidgetWidth(width: 10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
               "27 may 2024",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: globalFontSize(kText.scale(16), context),
                ),
              ),
              SizedBox(
               // width: displayWidth(context) / 3.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: getWidgetWidth(width: 34),
                      height: isSplitScreen?  getFullWidgetHeight(height: 34) : getWidgetHeight(height: 34),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF293750),
                      ),
                      child: Center(
                        child: Text(
                          "0",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: globalFontSize(kText.scale(20), context),
                          ),
                        ),
                      ),
                    ),
                    GradientDividerVertical(),
                    Container(
                      width: getWidgetWidth(width: 34),
                      height: isSplitScreen?  getFullWidgetHeight(height: 34) : getWidgetHeight(height: 34),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF293750),
                      ),
                      child: Center(
                        child: Text(
                          "1",
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
        ));
  }

  Padding headings(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 10), vertical: isSplitScreen?  getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10),),
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
            //width: displayWidth(context) / 3.3,
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
                    fontSize: globalFontSize(10, context),
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

  Container calenderWidget(BuildContext context) {
    return Container(
     // height: displayHeight(context) / 6.88,
      decoration: BoxDecoration(
        color: Color(0xFFF34425D),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  // width: 36,
                  height:  isSplitScreen?  getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36),
                  child: Row(
                    children: [
                      Container(
                        width: getWidgetWidth(width: 36),
                        height:  isSplitScreen?  getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDC6379),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/calender.png',
                          height:  isSplitScreen?  getFullWidgetHeight(height: 19.71) : getWidgetHeight(height: 19.71),
                          width: getWidgetWidth(width: 17.86)
                        ),
                      ),
                      SizedBox(width: getWidgetWidth(width: 10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd-MMM-yyyy').format(DateTime.parse(_reports.first.lastAttempt!)),
                            style: TextStyle(
                              fontSize: globalFontSize(14, context),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Last attempt",
                            style: TextStyle(
                              fontSize: globalFontSize(10, context),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              InkWell(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  if(widget.isSpeech){
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setStringList('SentenceScreen', [_reports[0].title! ?? "",_reports[0].load ?? "",_reports[0].main ?? ""]);
                    await prefs.setString('lastAccess', 'SentenceScreen');
                  }else{
                    await prefs.setStringList('FollowUpScreen', [_reports[0].title!,_reports[0].load! ?? "",_reports[0].main!]);
                    await prefs.setString('lastAccess', 'FollowUpScreen');
                  }
                  widget.isSpeech
                      ? Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SentenceScreen(
                            user: Provider.of<AuthState>(context, listen: false),
                            title: _reports[0].title!,
                            load: _reports[0].load!,
                            main: _reports[0].main!,
                          ))).then((_) {
                    // you have come back to your Settings screen
                    refreshFunc();
                  })
                      : Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FollowUpScreen(
                            user: Provider.of<AuthState>(context, listen: false),
                            title: _reports[0].title!,
                            load: _reports[0].load!,
                            main: _reports[0].main!,
                          )));
                },
                child: Container(
                  height: isSplitScreen?  getFullWidgetHeight(height: 36) : getWidgetHeight(height: 36),
                  width: getWidgetWidth(width: 151),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text("click here to practice",style: TextStyle(
                      color: Colors.white,
                      fontSize: globalFontSize(12, context),
                      fontWeight: FontWeight.w500,
                    ),),
                  ),
                ),
              )
              /*  SizedBox(
                  height: 36,
                  width: 151,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "click here to practice",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: globalFontSize(12, context),
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
                )*/
              ],
            ),
            SPH(10),
            GradientDivider(),
            SPH(10),
            Text(
              _reports[0].sentence ?? "",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: globalFontSize(15, context),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width of the parent container
      height: 0.5, // Height of the divider
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF676767),
            Color(0xFF676767),
            Color(0xFFFFFFFF),
            Color(0xFF676767),
            Color(0xFF676767),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class GradientDividerVertical extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5, // Full width of the parent container
      height: displayHeight(context) / 12, // Height of the divider
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
