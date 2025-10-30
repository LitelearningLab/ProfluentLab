import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

import '../../../utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class WordMenu extends StatefulWidget {
  WordMenu(
      {Key? key,
      required this.onTapMic,
      required this.text,
      required this.syllables,
      this.isCorrect,
      required this.selectedWord,
      this.pronun,
      this.url,
      required this.onTapHeadphone})
      : super(key: key);
  final GestureTapCallback onTapMic;
  final GestureTapCallback onTapHeadphone;
  final String text;
  final String syllables;
  final String selectedWord;
  final String? pronun;
  final String? url;
  final bool? isCorrect;

  @override
  _WordMenuState createState() {
    return _WordMenuState();
  }
}

class _WordMenuState extends State<WordMenu> {
  List<String> wordsFileUrl = [];

  pronunciationLabReport({required actionType, required word}) async {
    print("pronunciation lab report tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    print("word:$word");
    String action = actionType;
    print("action:${action}");
    String url = baseUrl + pronunciationLabReportApi;
    print("url : $url");
    try {
      print("responseeeeeeee");
      var response = await http.post(Uri.parse(url),
          body: {"userid": userId, "type": action, "word": word});

      print(
          "response for pronunciation lab report for practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  startPractice({required actionType}) async {
    print("Start practice Tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    String action = actionType;
    print("action:${action}");
    String url = baseUrl + startPracticeApi;
    print("url : $url");
    try {
      print("responseeeeeeee");
      var response = await http.post(Uri.parse(url), body: {
        "userid": userId,
        "practicetype": "Pronunciation Sound Lab Report",
        "action": action
      });

      print(
          "response start practice for pronunciation lab reportttt : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(" Selected Word >>>>>>>>>>>>>>>>>> ${widget.selectedWord.isEmpty}");
    print(" Selected Text >>>>>>>>>>>>>>>>>> ${widget.text}");
    print(" Syllabus >>>>>>>>>>>>>>>>>> ${widget.syllables.isEmpty}");
    return Container(
      color: Color(0xFF293750),
      child: Column(
        children: [
          // SPH(5),

          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ListTile(
              // leading: SizedBox(
              //   width: 25,
              // ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IPA",
                    style: TextStyle(
                        color: Color(0xFF939393),
                        fontSize: 12,
                        fontFamily: Keys.fontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0),
                  ),
                  // SPH(5),
                  SizedBox(
                    height: 5,
                  ),
                  /* RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: widget.syllables.split("(")[0],
                        style: const TextStyle(color: Colors.green, fontSize: 35),
                      ),
                      TextSpan(
                        text: widget.syllables.split("(")[1].split(")")[0],
                        style: const TextStyle(color: Colors.red, fontSize: 35),
                      ),
                      TextSpan(
                        text: widget.syllables.split("(")[1].split(")")[1],
                        style: const TextStyle(color: Colors.green, fontSize: 35),
                      ),
                    ]),
                  ),*/
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: _buildTextSpans(widget.syllables),
                    ),
                  ),
                  /*    Text(
                    widget.syllables,
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: Keys.lucidaFontFamily),
                  )*/
                ],
              ),
            ),
          ),
          // SPH(10),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ListTile(
              trailing: Container(
                // height: displayHeight(context)/20.3,
                width: 120,
                child: widget.syllables.isEmpty
                    ? null
                    : ElevatedButton.icon(
                        onPressed: () async {
                          print("practice button tappedd");
                          pronunciationLabReport(
                              actionType: "practice", word: widget.text);
                          startPractice(actionType: 'practice');
                          widget.onTapMic();
                          String? fileUrl = widget.url;
                          print("checkkkk:${widget.text}");
                          print("urll checkkk:${fileUrl}");
                          wordsFileUrl.add(fileUrl!);
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;
                          String userId =
                              await SharedPref.getSavedString('userId');
                          DocumentReference wordFileUrlDocument = firestore
                              .collection('proFluentEnglishReport')
                              .doc(userId);

                          await wordFileUrlDocument.update({
                            'WordsTapped': FieldValue.arrayUnion([widget.url]),
                          }).then((_) {
                            print('Link added to Firestore: ${widget.url}');
                          }).catchError((e) {
                            print('Error updating Firestore: $e');
                          });
                          print("fileUrl:${widget.url}");
                          print("sdhhvgfrhngkihri");
                        }
                        //              speech.isListening
                        //                  ? null
                        //                  : startListening,
                        ,
                        icon: SizedBox(
                          // height: displayHeight(context)/45.11,
                          // width: displayWidth(context)/20.8,
                          height: 18,
                          width: 18,
                          child: ImageIcon(
                            AssetImage(AllAssets.micIcon),
                            color: Colors.white,
                          ),
                        ),
                        label: Text(
                          'Practice',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: Keys.fontFamily,
                              fontSize: 14,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Color(0xFF6C63FF)),
                            shape: MaterialStatePropertyAll(
                                ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)))),
                      ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "PRONUNCIATION",
                    style: TextStyle(
                        color: Color(0xFF939393),
                        fontSize: 12,
                        fontFamily: Keys.fontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0),
                  ),
                  SPH(5),
                  FittedBox(
                    child: Text(
                      widget.pronun ?? "",
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontFamily: Keys.fontFamily),
                    ),
                  )
                ],
              ),
            ),
          ),
          // SPH(10),
          if (widget.selectedWord.toLowerCase() == widget.text.toLowerCase())
            ListTile(
              title: Text(
                "Pronunciation Analysis Result",
                style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 13,
                    fontFamily: Keys.fontFamily),
              ),
              subtitle: Text(
                "Note: This result only indicates intelligibility and does not confirm the accuracy of pronunciation.",
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontFamily: Keys.fontFamily,
                    fontWeight: FontWeight.w500),
              ),
              /*  trailing: Icon(
                widget.isCorrect! ? Icons.check_circle : Icons.cancel_rounded,
                color: widget.isCorrect! ? Color(0xFF00BC45) : Colors.red,
                size: 45,
              ),*/
              trailing: Container(
                height: 40,
                width: 40,
                child: Image.asset(widget.isCorrect!
                    ? "assets/images/right.png"
                    : "assets/images/wrong.png"),
              ),
            ),
          SPH(10)
        ],
      ),
    );
  }
}

List<TextSpan> _buildTextSpans(String text) {
  List<TextSpan> spans = [];
  bool isWithinParentheses = false;
  StringBuffer buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    if (text[i] == '(') {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(
          text: buffer.toString(),
          style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: Keys.lucidaFontFamily),
        ));
        buffer.clear();
      }
      isWithinParentheses = true;
    } else if (text[i] == ')') {
      spans.add(TextSpan(
        text: ' ${buffer.toString()} ',
        style: TextStyle(
            color: Colors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: Keys.lucidaFontFamily),
      ));
      buffer.clear();
      isWithinParentheses = false;
    } else {
      buffer.write(text[i]);
    }
  }
  if (buffer.isNotEmpty) {
    spans.add(TextSpan(
      text: buffer.toString(),
      style: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: Keys.lucidaFontFamily),
    ));
  }

  return spans;
}
