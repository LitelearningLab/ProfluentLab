import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/enums.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:toast/toast.dart';

import 'own_word_result_dialog.dart';
import 'sentence_result_dialog.dart';
import 'speech_analytics_dialog.dart';

class OwnWordDialog extends StatefulWidget {
  OwnWordDialog({Key? key, required this.isFromWord, this.word}) : super(key: key);
  final bool isFromWord;
  final String? word;

  @override
  _OwnWordDialogState createState() {
    return _OwnWordDialogState();
  }
}

class _OwnWordDialogState extends State<OwnWordDialog> {
  late FlutterTts flutterTts;
  dynamic languages;
  String? language;
  String _lastWord = "";
  double volume = 0.5;
  double pitch = 1.0;

  double rate = 0.5;
  TextEditingController _text = TextEditingController();
  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  final SpeechToText speech = SpeechToText();
  bool? _isCorrect;
  String _title = "";

  @override
  void initState() {
    super.initState();
    if (widget.isFromWord)
      _title = "Try Unlisted Words";
    else
      _title = "Speech Lab";
    _text.text = widget.word ?? "";

    initTts();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void dispose() {
    _text.dispose();
    flutterTts.stop();
    super.dispose();
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    final number = num.tryParse(str);
    return number != null;
  }

  initTts() {
    flutterTts = FlutterTts();

    //_getLanguages();

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        _getEngines();
      }
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        ttsState = TtsState.playing;
        print("playing native>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        print(ttsState.toString());
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (kIsWeb || Platform.isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText!);
        if (result == 1) setState(() => ttsState = TtsState.playing);
        if (_newVoiceText != "Please write word") if (widget.isFromWord)
          SharedPref.saveString("lastTriedWord", _newVoiceText!);
        else
          SharedPref.saveString("lastTriedSentence", _newVoiceText!);

        FirebaseHelper db = new FirebaseHelper();
        AuthState userDatas = Provider.of<AuthState>(context, listen: false);
        db.saveWordListReport(
          isPractice: false,
          company: userDatas.appUser?.company ?? "",
          name: userDatas.appUser?.UserMname,
          userID: userDatas.appUser!.id!,
          word: _newVoiceText!,
          team: userDatas.appUser?.team,
          userprofile: userDatas.appUser?.profile,
          city: userDatas.appUser?.city,
          date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          load: "Own word",
          title: _title,
          time: 1,
        );
        _newVoiceText = "";
      }
    }
  }

  void _getLastTriedWord() async {
    if (widget.isFromWord)
      _lastWord = await SharedPref.getSavedString("lastTriedWord");
    else
      _lastWord = await SharedPref.getSavedString("lastTriedSentence");
    setState(() {});
  }

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    Get.dialog(
      Container(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: SpeechAnalyticsDialog(
            true,
            isShowDidNotCatch: notCatch,
            word: word,
            title: "own",
            load: "own",
          ),
        ),
      ),
    ).then((value) {
      if (value.isCorrect == "true" || value.isCorrect == "false") {
        if (widget.isFromWord) {
          _isCorrect = value.isCorrect == "true";
          // Get.dialog(
          //   Container(
          //     // color: Color(0xCC000000),
          //     child: Dialog(
          //       // backgroundColor: AppColors.black,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(25.0)),
          //       //this right here
          //       child: OwnWordResultDialog(
          //         heard: value.heard,
          //         word: word,
          //         isCorrect: value.isCorrect == "true" ? true : false,
          //       ),
          //     ),
          //   ),
          // );
        } else {
          Get.dialog(
            Container(
              // color: Color(0xCC000000),
              child: Dialog(
                // backgroundColor: AppColors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                //this right here
                child: SentenceResultDialog(
                  correctedWidget: value.formatedWords,
                  score: value.wordPer,
                  word: word,
                  isCorrect: value.isCorrect == "true" ? true : false,
                  practiceType: '',
                ),
              ),
            ),
          );
        }
        setState(() {});
      } else if (value.isCorrect == "notCatch") {
        _showDialog(word, true, context);
      } else if (value.isCorrect == "openDialog") {
        _showDialog(word, false, context);
      }
    });
  }

  String convertSpecialChars(String input) {
    final Map<String, String> specialCharMap = {
      '!': ' exclamation mark',
      '@': ' at ',
      '#': ' number',
      '%': ' percent ',
      '^': ' caret ',
      '&': ' ampersand ',
      '*': ' asterisk ',
      '(': ' open parenthesis ',
      ')': ' close parenthesis ',
      '_': ' underscore',
      '+': ' plus ',
      '=': ' equals ',
      '{': ' open brace ',
      '}': ' close brace ',
      '[': ' open bracket ',
      ']': ' close bracket ',
      '|': ' vertical bar ',
      '\\': ' backslash ',
      ':': ' colon ',
      ';': ' semicolon ',
      '"': ' quotation mark ',
      '\'': ' apostrophe ',
      '<': ' less than ',
      '>': ' greater than ',
      // ',': ' comma ',
      '.': ' dot ',
      '?': ' question mark ',
      '/': ' slash ',
      '`': ' backtick ',
      '~': ' tilde ',
      '§': ' section ',
      '°': ' degree ',
      // '€': ' euro ',
      // '£': ' pound sterling ',
      // '¥': ' yen ',
      '•': ' bullet ',
      '…': ' ellipsis ',
      '¡': ' inverted exclamation mark ',
      '¢': ' cent ',
      '∞': ' infinity ',
      '≠': ' not equal to ',
      '≤': ' less than or equal to ',
      '≥': ' greater than or equal to ',
      '÷': ' division ',
      '×': ' multiplication ',
      '±': ' plus-minus ',
      '™': ' trademark ',
      '®': ' registered trademark ',
      '©': ' copyright ',
      '¶': ' pilcrow ',
      '‰': ' per mille ',
      // '₹': ' rupee '
    };

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      if (char == '\$') {
        // Handle specific case for $ followed by text
        int start = i + 1;
        while (start < input.length && input[start] == ' ') {
          start++;
        }
        int end = start;
        while (end < input.length && input[end] != ' ') {
          end++;
        }
        if (start < input.length) {
          buffer.write(input.substring(start, end).trim());
          buffer.write(' dollars ');
          i = end - 1; // Move the index to the end of the processed part
        } else {
          buffer.write('dollars ');
        }
      } else if (char == '₹') {
        // Handle specific case for $ followed by text
        int start = i + 1;
        while (start < input.length && input[start] == ' ') {
          start++;
        }
        int end = start;
        while (end < input.length && input[end] != ' ') {
          end++;
        }
        if (start < input.length) {
          buffer.write(input.substring(start, end).trim());
          buffer.write(' rupee ');
          i = end - 1; // Move the index to the end of the processed part
        } else {
          buffer.write('rupee ');
        }
      } else if (char == '€') {
        // Handle specific case for $ followed by text
        int start = i + 1;
        while (start < input.length && input[start] == ' ') {
          start++;
        }
        int end = start;
        while (end < input.length && input[end] != ' ') {
          end++;
        }
        if (start < input.length) {
          buffer.write(input.substring(start, end).trim());
          buffer.write(' euro ');
          i = end - 1; // Move the index to the end of the processed part
        } else {
          buffer.write('euro ');
        }
      } else if (char == '£') {
        // Handle specific case for $ followed by text
        int start = i + 1;
        while (start < input.length && input[start] == ' ') {
          start++;
        }
        int end = start;
        while (end < input.length && input[end] != ' ') {
          end++;
        }
        if (start < input.length) {
          buffer.write(input.substring(start, end).trim());
          buffer.write(' pound sterling ');
          i = end - 1; // Move the index to the end of the processed part
        } else {
          buffer.write('pound sterling ');
        }
      } else if (char == '¥') {
        // Handle specific case for $ followed by text
        int start = i + 1;
        while (start < input.length && input[start] == ' ') {
          start++;
        }
        int end = start;
        while (end < input.length && input[end] != ' ') {
          end++;
        }
        if (start < input.length) {
          buffer.write(input.substring(start, end).trim());
          buffer.write(' yen ');
          i = end - 1; // Move the index to the end of the processed part
        } else {
          buffer.write('yen ');
        }
      } else if (specialCharMap.containsKey(char)) {
        buffer.write(specialCharMap[char]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString().trim();
  }

  String convertNumbersToText(String inputString) {
    final numberPattern = RegExp(r'\d+'); // Matches one or more digits

    final StringBuffer outputBuffer = StringBuffer();
    int startIndex = 0;

    for (final match in numberPattern.allMatches(inputString)) {
      final int number = int.parse(match.group(0)!); // Extract and parse the number
      final String numberText =
          convertToWordsWithAnd(number); // Use the modified method to convert number to words with "and"

      // Append the text before the number
      outputBuffer.write(inputString.substring(startIndex, match.start));
      // Append the converted text instead of the number
      outputBuffer.write(numberText + ' ');

      startIndex = match.end; // Update start index for remaining string
    }

    // Append the remaining string after the last number
    outputBuffer.write(inputString.substring(startIndex));

    return outputBuffer.toString();
  }

  String convertToWordsWithAnd(int number) {
    // Convert the number to words using a hypothetical NumberToWordsEnglish.convert method
    final String numberText = NumberToWordsEnglish.convert(number);

    // Add "and" appropriately for British English
    if (number >= 100) {
      final StringBuffer resultBuffer = StringBuffer();
      final parts = numberText.split(' ');

      for (int i = 0; i < parts.length; i++) {
        resultBuffer.write(parts[i]);
        if (i == 1 && number % 100 != 0) {
          resultBuffer.write(' and');
          print("and added>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          print(resultBuffer.toString());
        }
        if (i < parts.length - 1) {
          resultBuffer.write(' ');
        }
      }

      return resultBuffer.toString();
    } else {
      return numberText;
    }
  }

  @override
  Widget build(BuildContext context) {
    _getLastTriedWord();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Dialog(
          backgroundColor: AppColors.trans,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //this right here
          child: Container(
            // height: 275,
            // margin: EdgeInsets.only(bottom: 53),

            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(Radius.circular(10.0)),
              color: Color(0xFF293750),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: isSplitScreen ? getFullWidgetHeight(height: 70) : getWidgetHeight(height: 70),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    borderRadius:
                        new BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                    color: Color(0xff34425D),
                    // boxShadow: [new BoxShadow(color: Colors.grey, blurRadius: 3.0, offset: new Offset(1.0, 1.0))],
                  ),
                  child: Text(_title,
                      style: TextStyle(fontSize: kText.scale(20), fontFamily: Keys.fontFamily, color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 15),
                      vertical: isSplitScreen ? getFullWidgetHeight(height: 5) : getWidgetHeight(height: 5)),
                  child: TextFormField(
                    controller: _text,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white, fontSize: kText.scale(17)),
                    decoration: InputDecoration(
                      hintText: "Type the word...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: kText.scale(15)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff34425D)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff34425D)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                if (_lastWord.length > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: getWidgetWidth(width: 15)),
                    child: SizedBox(
                      //   height: isSplitScreen ?  getFullWidgetHeight(height: 12) : getWidgetHeight(height:80),
                      width: displayWidth(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: getWidgetWidth(width: 15)),
                          SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 5) : getWidgetHeight(height: 5)),
                          Text(widget.isFromWord ? "Last Searched Term: " : "Last sentence tried: ",
                              style: TextStyle(
                                fontSize: kText.scale(12),
                                fontWeight: FontWeight.bold,
                                fontFamily: Keys.fontFamily,
                                color: Color(0xFF6C63FE),
                              )),
                          InkWell(
                            onTap: () {
                              _text.text = _lastWord;
                              FocusManager.instance.primaryFocus?.unfocus();
                              print(" last word clickedd");
                            },
                            child: SizedBox(
                              height: isSplitScreen ? getFullWidgetHeight(height: 50) : getWidgetHeight(height: 50),
                              width: displayHeight(context),
                              // color: Colors.blue,
                              child: Text(
                                  convertNumbersToText(convertSpecialChars(_text.text)).isEmpty
                                      ? _lastWord.capitalizeFirst!
                                      : convertNumbersToText(
                                          convertSpecialChars(_text.text).capitalizeFirst!,
                                        ),
                                  // maxLines: 5,
                                  softWrap: true, // Allow wrapping to next line
                                  // overflow: TextOverflow.ellipsis, //
                                  style: TextStyle(
                                    fontSize: kText.scale(17),
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                //SizedBox(height: isSplitScreen ?  getFullWidgetHeight(height: 10) : getWidgetHeight(height:10)),
                Container(
                    height: isSplitScreen ? getFullWidgetHeight(height: 85) : getWidgetHeight(height: 85),
                    width: displayWidth(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: displayWidth(context) * 0.3,
                          height: isSplitScreen ? getFullWidgetHeight(height: 85) : getWidgetHeight(height: 85),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.play_circle_outline,
                                    size: isSplitScreen ? getFullWidgetHeight(height: 35) : getWidgetHeight(height: 35),
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _isCorrect = null;
                                    setState(() {});
                                    if (_text.text.isNotEmpty) {
                                      _newVoiceText = convertNumbersToText(convertSpecialChars(_text.text));
                                      _speak();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    } else {
                                      //  _newVoiceText = "Please write word";
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      Toast.show("Please type the word",
                                          duration: Toast.lengthShort,
                                          gravity: Toast.bottom,
                                          backgroundColor: AppColors.white,
                                          textStyle: TextStyle(color: AppColors.black),
                                          backgroundRadius: 10);
                                    }
                                  }),
                              Text("Native Speaker\n",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: kText.scale(10),
                                      fontFamily: Keys.fontFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Container(
                          width: displayWidth(context) * 0.3,
                          height: isSplitScreen ? getFullWidgetHeight(height: 85) : getWidgetHeight(height: 85),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.mic_none_rounded,
                                    size: isSplitScreen ? getFullWidgetHeight(height: 35) : getWidgetHeight(height: 35),
                                    color: /*_text.text.isEmpty ? Color.fromARGB(255, 95, 95, 95) : */ Colors.white,
                                  ),
                                  onPressed: _text.text.isEmpty
                                      ? () {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          Toast.show("Please type the word",
                                              duration: Toast.lengthShort,
                                              gravity: Toast.bottom,
                                              backgroundColor: AppColors.white,
                                              textStyle: TextStyle(color: AppColors.black),
                                              backgroundRadius: 10);
                                        }
                                      : () {
                                          _isCorrect = null;
                                          setState(() {});
                                          // _newVoiceText = convertNumbersToText(convertSpecialChars(_text.text));
                                          _showDialog(
                                              convertNumbersToText(convertSpecialChars(_text.text)), false, context);
                                          if (_newVoiceText != "Please write word") if (widget.isFromWord)
                                            SharedPref.saveString(
                                                "lastTriedWord", convertNumbersToText(convertSpecialChars(_text.text)));
                                          else
                                            SharedPref.saveString("lastTriedSentence",
                                                convertNumbersToText(convertSpecialChars(_text.text)));
                                          // SharedPref.saveString("lastTriedSentence", );
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }),
                              Text("Pratice",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: kText.scale(10),
                                      color: Colors.white,
                                      fontFamily: Keys.fontFamily,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )
                      ],
                    )),
                if (_isCorrect != null)
                  ListTile(
                    title: Text(
                      "Pronunciation Analysis Result",
                      style:
                          TextStyle(color: Color(0xFF6C63FF), fontSize: kText.scale(13), fontFamily: Keys.fontFamily),
                    ),
                    subtitle: Text(
                      "Note: This result only indicates intelligibility and does not confirm the accuracy of pronunciation.",
                      style: TextStyle(color: AppColors.white, fontSize: kText.scale(10), fontFamily: Keys.fontFamily),
                    ),
                    trailing: Icon(
                      _isCorrect! ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect! ? AppColors.green : Colors.red,
                      size: 45,
                    ),
                  ),
                if (_isCorrect != null)
                  SizedBox(height: isSplitScreen ? getFullWidgetHeight(height: 25) : getWidgetHeight(height: 25)),
                // SPH(20),
              ],
            ),
          )),
    );
  }
}
