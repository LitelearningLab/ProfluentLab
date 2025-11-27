import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:http/http.dart' as http;

class SentenceResultDialog extends StatefulWidget {
  SentenceResultDialog(
      {Key? key,
      required this.isCorrect,
      required this.word,
      required this.score,
      required this.correctedWidget,
      required this.practiceType})
      : super(key: key);
  final String word;
  final double score;
  final List<Widget> correctedWidget;
  final String practiceType;

  final bool isCorrect;

  @override
  _SentenceResultDialogState createState() {
    return _SentenceResultDialogState();
  }
}

class _SentenceResultDialogState extends State<SentenceResultDialog> {
  late String resultText;

  @override
  void initState() {
    super.initState();
    endPractice(practiceType: widget.practiceType);
    if (widget.score >= 90) {
      resultText = "WELL DONE!";
    } else {
      resultText = "Need More Practice!";
    }
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  endPractice({required practiceType}) async {
    print("practice Type: $practiceType");
    print("end practice Tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    String url = baseUrl + endPracticeApi;
    print("url : $url");
    print("scoreeeeetypeee:${widget.score.runtimeType}");
    print("scoreeee:${widget.score}");
    try {
      var response = await http.post(Uri.parse(url), body: {
        "userid": userId,
        "practicetype": practiceType,
        "score": widget.score.toString(),
        "action": "practice"
      });

      print("response end practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isSplitScreen
        ? Container(
            padding: EdgeInsets.only(bottom: getWidgetHeight(height: 15)),
            // height: 370,
            decoration: new BoxDecoration(
              color: Color(0xff202328),
              //color: Colors.pink,
              borderRadius: new BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10),
                      vertical: getWidgetHeight(height: 5)),
                  decoration: new BoxDecoration(
                    color: Color(0xff333a40),
                    // color: Color(0xff333a40),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0)),
                  ),
                  child: Align(
                    child: Text("Pronunciation Analysis Report",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: kText.scale(16),
                            fontFamily: Keys.fontFamily,
                            color: Colors.white)),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: getWidgetWidth(width: 15)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 15)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: getWidgetWidth(width: 85),
                            // width: displayWidth(context) * 0.28,
                            padding: EdgeInsets.symmetric(
                                horizontal: getWidgetWidth(width: 5),
                                vertical: getWidgetHeight(height: 4)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text(
                                "SCORE:" +
                                    widget.score.toStringAsFixed(0) +
                                    "%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(10),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.black)),
                          ),
                          Container(
                            width: getWidgetWidth(width: 130),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidgetWidth(width: 5),
                              vertical: getWidgetHeight(height: 4),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text(resultText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(10),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            getWidgetHeight(height: getWidgetWidth(width: 15)),
                      ),
                      Container(
                          height: 120,
                          //Scolor: Colors.yellow,
                          child: Wrap(children: widget.correctedWidget)),
                      SizedBox(height: getWidgetHeight(height: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: getWidgetHeight(height: 25),
                            width: getWidgetWidth(width: 110),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green[500]!,
                                ),
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text("CORRECT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(10),
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.green[500])),
                          ),
                          Container(
                            height: getWidgetHeight(height: 25),
                            width: getWidgetWidth(width: 115),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text("WRONG/MISSED",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(10),
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.red)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: getWidgetHeight(height: 15),
                      ),
                      Text(
                        "Note: This result only indicates intelligibility and does not confirm the accuracy of pronunciation.",
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: kText.scale(10),
                            fontFamily: Keys.fontFamily),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.only(bottom: getWidgetHeight(height: 15)),
            //height: 265,
            decoration: new BoxDecoration(
              color: Color(0xFF0293750),
              //color: Color(0xFF37496C),
              //color: Colors.yellow,
              // Color(0XFF34425D)
              borderRadius: new BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10),
                      vertical: getWidgetHeight(height: 5)),
                  decoration: new BoxDecoration(
                    color: Color(0xFF34425D),
                    // color: Color(0xff333a40),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0)),
                  ),
                  child: Align(
                    child: Text("Pronunciation Analysis Report",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: kText.scale(20),
                            fontFamily: Keys.fontFamily,
                            color: Colors.white)),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 15)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: getWidgetWidth(width: 85),
                            // width: displayWidth(context) * 0.28,
                            padding: EdgeInsets.symmetric(
                                horizontal: getWidgetWidth(width: 5),
                                vertical: getWidgetHeight(height: 7)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text(
                                "SCORE:" +
                                    widget.score.toStringAsFixed(0) +
                                    "%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(12),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.black)),
                          ),
                          Container(
                            width: getWidgetWidth(width: 130),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidgetWidth(width: 5),
                              vertical: getWidgetHeight(height: 7),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text(resultText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(12),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: getWidgetHeight(height: 20),
                      ),
                      Container(
                        //color: Colors.yellow,
                        child: Wrap(
                          children: widget.correctedWidget,
                        ),
                      ),
                      SizedBox(height: getWidgetHeight(height: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: getWidgetHeight(height: 30),
                            width: getWidgetWidth(width: 110),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green[500]!,
                                ),
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text("CORRECT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(12),
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.green[500])),
                          ),
                          Container(
                            height: getWidgetHeight(height: 30),
                            width: getWidgetWidth(width: 115),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text("WRONG/MISSED",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: kText.scale(12),
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.red)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: getWidgetHeight(height: 20),
                      ),
                      Text(
                        "Note: This result only indicates intelligibility and does not confirm the accuracy of pronunciation.",
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: kText.scale(10),
                            fontFamily: Keys.fontFamily),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
