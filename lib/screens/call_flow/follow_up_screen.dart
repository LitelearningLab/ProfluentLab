import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/Sentence.dart';
import 'package:litelearninglab/screens/call_flow/download_helper.dart';
import 'package:litelearninglab/screens/dialogs/sentence_result_dialog.dart';
import 'package:litelearninglab/screens/dialogs/speech_analytics_dialog.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';
import '../../main.dart';
import '../../utils/audio_player_manager.dart';
import '../../utils/shared_pref.dart';

enum PlayingRouteState { speakers, earpiece }

// bool isConnected = true;
// bool isAllDownloaded = false;
// bool isDownloading = false;
// List<Sentence> followUps = [];
// bool isDownloadError = false;

class FollowUpScreen extends StatefulWidget {
  FollowUpScreen(
      {Key? key,
      required this.title,
      required this.load,
      required this.user,
      required this.main})
      : super(key: key);
  final AuthState user;
  final String title;
  final String main;
  final String load;

  @override
  followUpscreenState createState() {
    return followUpscreenState();
  }
}

class followUpscreenState extends State<FollowUpScreen> {
  FirebaseHelperRTD db = new FirebaseHelperRTD();
  // List<Sentence> followUps = [];

  StreamSubscription? _playerStateSubscription;

  bool _isLoading = false;
  // bool isAllDownloaded = false;
  // bool isDownloading = false;
  final _audioPlayerManager = AudioPlayerManager();
  bool _isPlaying = false;
  int _currentPlayingIndex = -1;
  bool _isAudioLoading = false;
  bool _isAudioPlayed = true;
  // bool isDownloadError = false;
  List<String> fileUrl = [];
  // bool isConnected = true;
  StreamSubscription? networkSubscription;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    sessionName2 = widget.title;
    startTimerMainCategory("name");
    if (loadsFrom.contains(widget.load)) {
      checkingLoad();
    }

    _playerStateSubscription =
        _audioPlayerManager.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });

    _getFollowUps();

    initConnectivity();

    networkSubscription =
        Connectivity().onConnectivityChanged.listen((connectionResult) {
      print('^^^^^^^^^^^^^^CHECKING CONNECTION');
      checkConnection(connectionResult);
    });
  }

  void checkingLoad() {
    setState(() {
      isDownloading = true;
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void dispose() {
    // _audioPlayerManager.dispose();

    _playerStateSubscription?.cancel();

    networkSubscription!.cancel();
    super.dispose();
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
        "practicetype": "Call Flow Practise Report",
        "action": action
      });

      print("response start practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  final Connectivity connectivity = Connectivity();

  Future<void> initConnectivity() async {
    print('^^^^^^^^^^^ INIT CONNECTIVITY ^^^^^^^^^^^^^');
    final downloadController = Provider.of<AuthState>(context, listen: false);
    List<ConnectivityResult> result;
    try {
      result = await connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        downloadController.setIsConnected(isConnected: false);
        // setState(() {
        //   isConnected = false;
        //   // isConnected = false;
        // });
      } else {
        downloadController.setIsConnected(isConnected: true);
        // setState(() {
        //   isConnected = true;
        //   // isConnected = true;
        // });
      }
    } catch (e) {
      print('Connection Init Error : $e');
    }
  }

  Future<void> checkConnection(
      List<ConnectivityResult> connectivityResult) async {
    connectivityResult = await Connectivity().checkConnectivity();
    final downloadController = Provider.of<AuthState>(context, listen: false);

    if (connectivityResult.contains(ConnectivityResult.none)) {
      downloadController.setIsConnected(isConnected: false);
      // setState(() {
      //   isConnected = false;
      //   // isConnected = false;
      // });
    } else {
      downloadController.setIsConnected(isConnected: true);
      // setState(() {
      //   isConnected = true;
      //   // isConnected = true;
      // });
    }
    // print('<<<<<<<< Is Connected : $isConnected >>>>>>>>>>>>');
  }

  Future<void> _play(String url, String sentence, int index, context,
      {String? localPath}) async {
    final audioController = Provider.of<AuthState>(context, listen: false);
    print(
        '///////////////////////// ENTERED TO PLAY /////////////////////////');
    try {
      String? eLocalPath;
      setState(() {
        _isAudioLoading = true;
        _currentPlayingIndex = index;
        _isAudioPlayed = true;
      });
      print(
          "local path>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print("Local Path  : : : ${localPath.toString()}");
      await _audioPlayerManager.stop();
      await _audioPlayerManager.play(
        url,
        localPath: localPath,
        context: context,
        decodedPath: (val) {
          eLocalPath = val;
        },
      );
      print(
          "playing>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

      setState(() {
        _isAudioLoading = false;
        _isAudioPlayed = audioController.isAudioDone!;
      });

      FirebaseHelper db = new FirebaseHelper();
      AuthState userDatas = Provider.of<AuthState>(context, listen: false);
      db.saveCallFlowReport(
        isPractice: false,
        company: userDatas.appUser!.company ?? "",
        name: userDatas.appUser!.UserMname,
        userID: userDatas.appUser!.id!,
        sentence: sentence,
        team: userDatas.appUser?.team,
        userprofile: userDatas.appUser?.profile,
        city: userDatas.appUser?.city,
        date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      );

      if (eLocalPath != null && eLocalPath!.isNotEmpty) {
        try {
          await File(eLocalPath!).delete();
        } catch (e) {}
      }
    } catch (e) {
      print(
          '///////////////////////// PLAYING FAILED $e /////////////////////////');
    }
  }

  void _getFollowUps() async {
    final downloadController = Provider.of<AuthState>(context, listen: false);

    setState(() {
      _isLoading = true;
    });
    downloadController.followUps =
        // followUps =
        await db.getFollowUps("Call Flow Practice", widget.main, widget.load);

    // followUps = await db.getFollowUps("main", widget.main, widget.load);
    downloadController.followUps.forEach((element) {
      // followUps.forEach((element) {
      // print(element.toJson());
    });

    print("Main : : : ${widget.main}");
    print("Load : : : ${widget.load}");

    // for (Sentence sent in followUps) {
    for (Sentence sent in downloadController.followUps) {
      print(
          "<><><>><><><><><><<>><><><><><>< Local PAth : : : ${sent.localPath}");
      if (sent.localPath == null ||
          sent.localPath == 'g!ZS84%8t=QFR' ||
          sent.localPath == 'ERROR') {
        // isAllDownloaded = false;
        // isAllDownloaded = false;
        downloadController.setIsAllDownloaded(isallDownloaded: false);
      } else {
        downloadController.setIsAllDownloaded(isallDownloaded: true);
        // isAllDownloaded = true;
        // isAllDownloaded = true;
      }
    }

    _isLoading = false;
    setState(() {});
  }

  String convertNumbersToText(String inputString) {
    final numberPattern = RegExp(r'\d+'); // Matches one or more digits

    final StringBuffer outputBuffer = StringBuffer();
    int startIndex = 0;

    for (final match in numberPattern.allMatches(inputString)) {
      final int number =
          int.parse(match.group(0)!); // Extract and parse the number
      final String numberText = convertToWordsWithAnd(
          number); // Use the modified method to convert number to words with "and"

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
      // '\'': ' apostrophe ',
      '<': ' less than ',
      '>': ' greater than ',
      // ',': ' comma ',
      // '.': ' dot ',
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

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    print("showdialogue succesfully>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    Get.dialog(Container(
      // color: Color(0xCC000000),
      child: Dialog(
        // backgroundColor: AppColors.black,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        //this right here
        child: SpeechAnalyticsDialog(
          false,
          isShowDidNotCatch: notCatch,
          word: word,
          title: widget.title,
          isCallflow: true,
          load: widget.load,
          main: widget.main,
        ),
      ),
    )).then((value) {
      print("listening succesfully>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(value.toString());
      if (value != null) {
        if (value.isCorrect == "true" || value.isCorrect == "false") {
          print("getting value succesfully>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          showDialog(
            context: context,
            builder: (BuildContext buildContext) {
              return Dialog(
                // backgroundColor: AppColors.c262626,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                //this right here
                child: SentenceResultDialog(
                  correctedWidget: value.formatedWords,
                  score: value.wordPer,
                  word: word,
                  isCorrect: value.isCorrect == "true" ? true : false,
                  practiceType: 'Call Flow Practise Report',
                ),
              );
            },
          );
        } else if (value.isCorrect == "notCatch") {
          _showDialog(word, true, context);
        } else if (value.isCorrect == "openDialog") {
          _showDialog(word, false, context);
        }
      }
    });
  }

// Future<void> downloadAll(

// ) async {
//   print('############### ISCONNECTED : $isConnected : : : isAllDownloaded : $isAllDownloaded');

//   if (isConnected && !isAllDownloaded) {
//     print('<><><>  Download : : : IF CASE');
//     final downloadController = Provider.of<AuthState>(context, listen: false);
//     setState(() {
//       isDownloading = true;
//     });

//     for (Sentence sentence in followUps) {
//       SentDatabaseProvider dbb = SentDatabaseProvider.get;
//       SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);

//       Directory appDocDir = await getApplicationDocumentsDirectory();
//       String appDocPath = appDocDir.path;

//       // Define the task
//       final task = DownloadTask(
//         url: sentence.file!,
//         filename: '${sentence.id}.mp3',
//         directory: widget.load,
//         baseDirectory: BaseDirectory.applicationDocuments
//       );

//       // Perform the background download
//       final result = await FileDownloader().download(task,
//           onProgress: (progress) => print('Progress: ${progress * 100}%'),
//           onStatus: (status) => print('Status: $status'));

//       switch (result.status) {
//         case TaskStatus.complete:
//           print('Download Complete!');

//           // Move the file to shared storage (e.g., Downloads folder)
//           final newFilePath = await FileDownloader().moveToSharedStorage(task, SharedStorage.downloads);

//           if (newFilePath == null) {
//             print('Failed to move file to shared storage');
//           } else {
//             print('File moved to: $newFilePath');

//             // Encrypt and store the new file path in the database
//             String eLocalPath = EncryptData.encryptFile(newFilePath, context);

//             try {
//               await File(newFilePath).delete(); // Optionally delete the unencrypted file
//             } catch (e) {
//               print("Error deleting file: $e");
//             }

//             await dbRef.setDownloadPath(sentence.id!, eLocalPath);
//           }

//           break;

//         case TaskStatus.canceled:
//           print('Download was canceled');
//           break;

//         case TaskStatus.paused:
//           print('Download was paused');
//           break;

//         default:
//           print('Download not successful');
//           break;
//       }
//     }

//     setState(() {
//       isDownloading = false;
//       isAllDownloaded =true ;
//       // isAllDownloaded = downloadController.isDownloaded!;
//     });
//   } else {
//     print('<><><>  Download : : : ELSE CASE');
//     Toast.show("No network connection",
//         duration: Toast.lengthShort,
//         gravity: Toast.bottom,
//         backgroundColor: AppColors.white,
//         textStyle: TextStyle(color: AppColors.black),
//         backgroundRadius: 10);
//   }
// }

  @override
  Widget build(BuildContext context) {
    log("${widget.main}");
    final downloadController = Provider.of<AuthState>(context, listen: false);

    print('IS ALL DOWNLOADED : ${downloadController.isAllDownloaded}');
    return Consumer<AuthState>(builder: (context, AuthStateProvider, child) {
      return PopScope(
        onPopInvoked: ((didPop) {
          stopTimerMainCategory();
        }),
        child: BackgroundWidget(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              widget.main,
              style: TextStyle(
                  fontFamily: Keys.fontFamily,
                  fontSize: kText.scale(17),
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            backgroundColor: Color(0xFF324265),
            leading: IconButton(
              onPressed: () {
                stopTimerMainCategory();
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
            actions: [
              (isDownloading && !downloadController.isAllDownloaded)
                  ? SizedBox(
                      width: getWidgetWidth(width: 20),
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 20)
                          : getWidgetHeight(height: 20),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                  : downloadController.isAllDownloaded &&
                          !downloadController.isDownloadError
                      ? InkWell(
                          onTap: () {},
                          child: Icon(
                            Icons.file_download_done,
                            color: AppColors.white,
                          ),
                        )
                      : InkWell(
                          // onTap: downloadAll,
                          onTap: () async {
                            isDownloading = true;
                            setState(() {});
                            downloadAll(downloadController, widget.load);
                          },
                          child: Container(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 18.6)
                                  : getWidgetHeight(height: 18.6),
                              width: getWidgetWidth(width: 19.8),
                              child: Image.asset(AllAssets.downloading)),
                          /* child: Icon(
                      Icons.file_download,
                      color: AppColors.white,
                    ),*/
                        ),
              SizedBox(width: getWidgetWidth(width: 20))
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: isSplitScreen
                        ? getFullWidgetHeight(height: 18)
                        : getWidgetHeight(height: 18)),
                child: ListView(
                  children: [
                    // SPH(10),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: getWidgetWidth(width: 10)),
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidgetWidth(width: 20),
                          vertical: isSplitScreen
                              ? getFullWidgetHeight(height: 7)
                              : getWidgetHeight(height: 7)),
                      // decoration: new BoxDecoration(
                      //   borderRadius: new BorderRadius.circular(10.0),
                      //   color: AppColors.chatBack,
                      // ),
                      child: Text(
                        widget.load,
                        style: TextStyle(
                            color: AppColors.white,
                            fontFamily: Keys.fontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: kText.scale(19)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(
                          horizontal: getWidgetWidth(width: 5)),
                      padding: EdgeInsets.symmetric(
                          horizontal: getWidgetWidth(width: 10),
                          vertical: isSplitScreen
                              ? getFullWidgetHeight(height: 3)
                              : getWidgetHeight(height: 3)),
                      child: Text(
                        widget.load,
                        style: TextStyle(
                            color: AppColors.white,
                            fontFamily: Keys.fontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: kText.scale(10)),
                      ),
                    ),
                    // SPH(10),
                    Container(
                      margin: EdgeInsets.only(
                          left: getWidgetWidth(width: 25),
                          right: getWidgetWidth(width: 25),
                          bottom: isSplitScreen
                              ? getFullWidgetHeight(height: 60)
                              : getWidgetHeight(height: 60),
                          top: isSplitScreen
                              ? getFullWidgetHeight(height: 26)
                              : getWidgetHeight(height: 26)),
                      child: ListView.builder(
                          itemCount: downloadController.followUps.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index % 2 == 0) {
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  getWidgetWidth(width: 10),
                                              vertical: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 10)
                                                  : getWidgetHeight(
                                                      height: 10)),
                                          decoration: new BoxDecoration(
                                            borderRadius: new BorderRadius.only(
                                              topLeft: Radius.circular(24.5),
                                              bottomLeft: Radius.circular(24.5),
                                              bottomRight:
                                                  Radius.circular(24.5),
                                            ),
                                            // color: AppColors.chatRight,
                                            color: Color(0xff34425D),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: getWidgetWidth(
                                                        width: 8),
                                                    vertical: isSplitScreen
                                                        ? getFullWidgetHeight(
                                                            height: 8)
                                                        : getWidgetHeight(
                                                            height: 8)),
                                                child: Text(
                                                  downloadController
                                                          .followUps[index]
                                                          .text ??
                                                      "",
                                                  style: TextStyle(
                                                      color: Color(0XFFFFFFFF),
                                                      fontFamily:
                                                          Keys.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          kText.scale(14)),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: isSplitScreen
                                                      ? getFullWidgetHeight(
                                                          height: 5)
                                                      : getWidgetHeight(
                                                          height: 5)),
                                              Row(
                                                children: [
                                                  // if (!_isPlaying)
                                                  InkWell(
                                                    onTap: () async {
                                                      print(
                                                          "playyyyyyyyyyyyyyyyyyyyyyyyy");
                                                      startPractice(
                                                          actionType:
                                                              'listening');
                                                      if (_isPlaying &&
                                                          _currentPlayingIndex ==
                                                              index) {
                                                        _audioPlayerManager
                                                            .stop();
                                                      } else {
                                                        _play(
                                                          downloadController
                                                              .followUps[index]
                                                              .file!,
                                                          // convertNumbersToText(convertSpecialChars(
                                                          downloadController
                                                                  .followUps[
                                                                      index]
                                                                  .text ??
                                                              ""
                                                          // ))
                                                          ,
                                                          index,
                                                          context,
                                                          localPath:
                                                              downloadController
                                                                  .followUps[
                                                                      index]
                                                                  .localPath,
                                                        );
                                                        String?
                                                            sentenceFileUrl =
                                                            downloadController
                                                                .followUps[
                                                                    index]
                                                                .file;
                                                        print(
                                                            "sentenceScenerioFileUrl:${downloadController.followUps[index].file}");
                                                        fileUrl?.add(
                                                            sentenceFileUrl!);

                                                        /* FirebaseFirestore firestore = FirebaseFirestore.instance;
                                                        String userId = await SharedPref.getSavedString('userId');
                                                        DocumentReference wordFileUrlDocument =
                                                            firestore.collection('proFluentEnglishReport').doc(userId);
        
                                                        await wordFileUrlDocument.update({
                                                          'SentencesTapped': FieldValue.arrayUnion(
                                                              [downloadController.followUps[index].file]),
                                                        }).then((_) {
                                                          print(
                                                              'Link added to Firestore: ${downloadController.followUps[index].file}');
                                                        }).catchError((e) {
                                                          print('Error updating Firestore: $e');
                                                        });*/
                                                        print(
                                                            "fileUrl:${downloadController.followUps[index].file}");
                                                        print(
                                                            "sdhhvgfrhngkihri");
                                                        log(downloadController
                                                                .followUps[
                                                                    index]
                                                                .localPath ??
                                                            "no local path exist");
                                                        log("${downloadController.followUps[index].file.toString()}");
                                                        log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                                                        log("${downloadController.followUps[index].text.toString()}");
                                                        downloadController
                                                            .followUps
                                                            .forEach((element) {
                                                          log("${element.text}");
                                                        });
                                                      }

                                                      // _play(followUps[index].file!, convertNumbersToText(convertSpecialChars(followUps[index].text ?? "")), index,
                                                      //     localPath: followUps[index].localPath);
                                                      // log("${followUps[index].file.toString()}");
                                                      // log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                                                      // log("${followUps[index].text.toString()}");
                                                      // followUps.forEach((element) {
                                                      //   log("${element.text}");
                                                      // });
                                                    },
                                                    child: _isAudioPlayed ==
                                                                false &&
                                                            _currentPlayingIndex ==
                                                                index
                                                        ? Icon(
                                                            Icons.info_outlined,
                                                            color: Colors.red,
                                                            size: isSplitScreen
                                                                ? getFullWidgetHeight(
                                                                    height: 30)
                                                                : getWidgetHeight(
                                                                    height: 30),
                                                          )
                                                        : _isAudioLoading &&
                                                                _currentPlayingIndex ==
                                                                    index
                                                            ? SizedBox(
                                                                height: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            30)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            30),
                                                                width:
                                                                    getWidgetWidth(
                                                                        width:
                                                                            30),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Color(
                                                                        0xff6C63FE),
                                                                    strokeWidth:
                                                                        2.5,
                                                                  ),
                                                                ))
                                                            : Icon(
                                                                _isPlaying &&
                                                                        _currentPlayingIndex ==
                                                                            index
                                                                    ? Icons
                                                                        .pause_circle_outline
                                                                    : Icons
                                                                        .play_circle_outline,
                                                                color: Color(
                                                                    0xff6C63FE),
                                                                size: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            30)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            30),
                                                              ),
                                                    // child: Icon(
                                                    //   Icons.play_circle_outline,
                                                    //   color: Color(0xff71b800),
                                                    //   size: 30,
                                                    // ),
                                                  ),
                                                  // if (_isPlaying)
                                                  //   InkWell(
                                                  //       onTap: () {
                                                  //         _audioPlayerManager.stop();
                                                  //       },
                                                  //       child: Icon(
                                                  //         Icons.pause_circle_outline,
                                                  //         color: Color(0xff71b800),
                                                  //         size: 30,
                                                  //       )),
                                                  SizedBox(
                                                      width: getWidgetWidth(
                                                          width: 17)),
                                                  InkWell(
                                                    onTap: () async {
                                                      print(
                                                          "miccccccccccccccccccccccccccccccc");
                                                      startPractice(
                                                          actionType:
                                                              'practice');
                                                      _audioPlayerManager
                                                          .stop();
                                                      _isAudioLoading = false;
                                                      _showDialog(
                                                          // convertNumbersToText(convertSpecialChars(
                                                          downloadController
                                                                  .followUps[
                                                                      index]
                                                                  .text ??
                                                              ""
                                                          // ))
                                                          ,
                                                          false,
                                                          context);
                                                      String? sentenceFileUrl =
                                                          downloadController
                                                              .followUps[index]
                                                              .file;
                                                      print(
                                                          "sentenceScenerioFileUrl:${downloadController.followUps[index].file}");
                                                      fileUrl?.add(
                                                          sentenceFileUrl!);

                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      String userId =
                                                          await SharedPref
                                                              .getSavedString(
                                                                  'userId');
                                                      DocumentReference
                                                          wordFileUrlDocument =
                                                          firestore
                                                              .collection(
                                                                  'proFluentEnglishReport')
                                                              .doc(userId);

                                                      await wordFileUrlDocument
                                                          .update({
                                                        'SentencesTapped':
                                                            FieldValue
                                                                .arrayUnion([
                                                          downloadController
                                                              .followUps[index]
                                                              .file
                                                        ]),
                                                      }).then((_) {
                                                        print(
                                                            'Link added to Firestore: ${downloadController.followUps[index].file}');
                                                      }).catchError((e) {
                                                        print(
                                                            'Error updating Firestore: $e');
                                                      });
                                                      print(
                                                          "fileUrl:${downloadController.followUps[index].file}");
                                                      print("sdhhvgfrhngkihri");
                                                    },
                                                    child: Icon(
                                                      Icons.mic,
                                                      size: isSplitScreen
                                                          ? getFullWidgetHeight(
                                                              height: 30)
                                                          : getWidgetHeight(
                                                              height: 30),
                                                      color: Color(0xffFFFFFF),
                                                    ),
                                                  ),
                                                  // SPW(15),
                                                  // Image.asset(
                                                  //   AllAssets.dfb,
                                                  //   width: 30,
                                                  //   color: Colors.white,
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: getWidgetWidth(width: 11)),
                                      Image.asset(
                                        AllAssets.sender,
                                        width: getWidgetWidth(width: 40),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 26)
                                          : getWidgetHeight(height: 26))
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        AllAssets.receiver,
                                        width: getWidgetWidth(width: 40),
                                      ),
                                      SizedBox(width: 11),
                                      Flexible(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  getWidgetWidth(width: 15),
                                              vertical: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 10)
                                                  : getWidgetHeight(
                                                      height: 10)),
                                          decoration: new BoxDecoration(
                                            borderRadius: new BorderRadius.only(
                                              topRight: Radius.circular(24.5),
                                              bottomLeft: Radius.circular(24.5),
                                              bottomRight:
                                                  Radius.circular(24.5),
                                            ),
                                            color: Color(0XFF37496C),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                downloadController
                                                        .followUps[index]
                                                        .text ??
                                                    "",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontFamily: Keys.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: kText.scale(14)),
                                              ),
                                              SizedBox(
                                                  height: isSplitScreen
                                                      ? getFullWidgetHeight(
                                                          height: 5)
                                                      : getWidgetHeight(
                                                          height: 5)),
                                              Row(
                                                children: [
                                                  // if (!_isPlaying)
                                                  InkWell(
                                                    onTap: () async {
                                                      if (_isPlaying &&
                                                          _currentPlayingIndex ==
                                                              index) {
                                                        _audioPlayerManager
                                                            .stop();
                                                      } else {
                                                        print(
                                                            "listening tapped");
                                                        startPractice(
                                                            actionType:
                                                                'listening');
                                                        _play(
                                                            downloadController
                                                                .followUps[
                                                                    index]
                                                                .file!,
                                                            // convertNumbersToText(convertSpecialChars(
                                                            downloadController
                                                                    .followUps[
                                                                        index]
                                                                    .text ??
                                                                ""
                                                            // ))
                                                            ,
                                                            index,
                                                            context,
                                                            localPath:
                                                                downloadController
                                                                    .followUps[
                                                                        index]
                                                                    .localPath);

                                                        String?
                                                            sentenceFileUrl =
                                                            downloadController
                                                                .followUps[
                                                                    index]
                                                                .file;
                                                        print(
                                                            "sentenceScenerioFileUrl:${downloadController.followUps[index].file}");
                                                        fileUrl?.add(
                                                            sentenceFileUrl!);

                                                        FirebaseFirestore
                                                            firestore =
                                                            FirebaseFirestore
                                                                .instance;
                                                        String userId =
                                                            await SharedPref
                                                                .getSavedString(
                                                                    'userId');
                                                        DocumentReference
                                                            wordFileUrlDocument =
                                                            firestore
                                                                .collection(
                                                                    'proFluentEnglishReport')
                                                                .doc(userId);

                                                        await wordFileUrlDocument
                                                            .update({
                                                          'SentencesTapped':
                                                              FieldValue
                                                                  .arrayUnion([
                                                            downloadController
                                                                .followUps[
                                                                    index]
                                                                .file
                                                          ]),
                                                        }).then((_) {
                                                          print(
                                                              'Link added to Firestore: ${downloadController.followUps[index].file}');
                                                        }).catchError((e) {
                                                          print(
                                                              'Error updating Firestore: $e');
                                                        });
                                                        print(
                                                            "fileUrl:${downloadController.followUps[index].file}");
                                                        print(
                                                            "sdhhvgfrhngkihri");
                                                      }

                                                      // _play(followUps[index].file!, convertNumbersToText(convertSpecialChars(followUps[index].text ?? "")), index,
                                                      //     localPath: followUps[index].localPath);
                                                    },
                                                    child: _isAudioPlayed ==
                                                                false &&
                                                            _currentPlayingIndex ==
                                                                index
                                                        ? Icon(
                                                            Icons.info_outlined,
                                                            color: Colors.red,
                                                            size: isSplitScreen
                                                                ? getFullWidgetHeight(
                                                                    height: 30)
                                                                : getWidgetHeight(
                                                                    height: 30),
                                                          )
                                                        : _isAudioLoading &&
                                                                _currentPlayingIndex ==
                                                                    index
                                                            ? SizedBox(
                                                                height: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            30)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            30),
                                                                width:
                                                                    getWidgetWidth(
                                                                        width:
                                                                            30),
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal: getWidgetWidth(
                                                                          width:
                                                                              5),
                                                                      vertical: isSplitScreen
                                                                          ? getFullWidgetHeight(
                                                                              height:
                                                                                  5)
                                                                          : getWidgetHeight(
                                                                              height: 5)),
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: Color(
                                                                        0xff6C63FE),
                                                                    strokeWidth:
                                                                        2.5,
                                                                  ),
                                                                ))
                                                            : Icon(
                                                                _isPlaying &&
                                                                        _currentPlayingIndex ==
                                                                            index
                                                                    ? Icons
                                                                        .pause_circle_outline
                                                                    : Icons
                                                                        .play_circle_outline,
                                                                color: Color(
                                                                    0xff6C63FE),
                                                                size: isSplitScreen
                                                                    ? getFullWidgetHeight(
                                                                        height:
                                                                            30)
                                                                    : getWidgetHeight(
                                                                        height:
                                                                            30),
                                                              ),
                                                    // child: Icon(
                                                    //   Icons.play_circle_outline,
                                                    //   color: Color(0xff0588e2),
                                                    //   size: 30,
                                                    // ),
                                                  ),
                                                  // if (_isPlaying)
                                                  //   InkWell(
                                                  //       onTap: () {
                                                  //         _audioPlayerManager.stop();
                                                  //       },
                                                  //       child: Icon(
                                                  //         Icons.pause_circle_outline,
                                                  //         color: Color(0xff0588e2),
                                                  //         size: 30,
                                                  //       )),
                                                  SizedBox(
                                                      width: getWidgetWidth(
                                                          width: 17)),
                                                  InkWell(
                                                    child: Icon(
                                                      Icons.mic,
                                                      size: isSplitScreen
                                                          ? getFullWidgetHeight(
                                                              height: 30)
                                                          : getWidgetHeight(
                                                              height: 30),
                                                      color: Color(0xffFFFFFF),
                                                    ),
                                                    onTap: () async {
                                                      print(
                                                          "mic button tappedd");
                                                      startPractice(
                                                          actionType:
                                                              'practice');
                                                      _audioPlayerManager
                                                          .stop();
                                                      _isAudioLoading = false;
                                                      _showDialog(
                                                          // convertNumbersToText(convertSpecialChars(
                                                          downloadController
                                                                  .followUps[
                                                                      index]
                                                                  .text ??
                                                              "",
                                                          // )),
                                                          false,
                                                          context);
                                                      String? sentenceFileUrl =
                                                          downloadController
                                                              .followUps[index]
                                                              .file;
                                                      print(
                                                          "sentenceScenerioFileUrl:${downloadController.followUps[index].file}");
                                                      fileUrl?.add(
                                                          sentenceFileUrl!);

                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      String userId =
                                                          await SharedPref
                                                              .getSavedString(
                                                                  'userId');
                                                      DocumentReference
                                                          wordFileUrlDocument =
                                                          firestore
                                                              .collection(
                                                                  'proFluentEnglishReport')
                                                              .doc(userId);

                                                      await wordFileUrlDocument
                                                          .update({
                                                        'SentencesTapped':
                                                            FieldValue
                                                                .arrayUnion([
                                                          downloadController
                                                              .followUps[index]
                                                              .file
                                                        ]),
                                                      }).then((_) {
                                                        print(
                                                            'Link added to Firestore: ${downloadController.followUps[index].file}');
                                                      }).catchError((e) {
                                                        print(
                                                            'Error updating Firestore: $e');
                                                      });
                                                      print(
                                                          "fileUrl:${downloadController.followUps[index].file}");
                                                      print("sdhhvgfrhngkihri");
                                                    },
                                                  ),
                                                  // SPW(15),
                                                  // Image.asset(
                                                  //   AllAssets.dfb,
                                                  //   color: Color(0xff0b298f),
                                                  //   width: 30,
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 26)
                                          : getWidgetHeight(height: 26))
                                ],
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: Colors.white))
            ],
          ),
        ),
      );
    });
  }
}
