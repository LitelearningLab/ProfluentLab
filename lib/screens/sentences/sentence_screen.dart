import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/boom_menu_item.dart' as bm;
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/database/SentencesDatabaseRepository.dart';
import 'package:litelearninglab/models/Sentence.dart';
import 'package:litelearninglab/models/SentenceCat.dart';
import 'package:litelearninglab/screens/dialogs/sentence_result_dialog.dart';
import 'package:litelearninglab/screens/dialogs/speech_analytics_dialog.dart';
import 'package:litelearninglab/screens/sentences/sentences_screen.dart';
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:litelearninglab/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/boom_menu.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../utils/audio_player_manager.dart';

enum PlayingRouteState { speakers, earpiece }

class SentenceScreen extends StatefulWidget {
  SentenceScreen(
      {Key? key,
      required this.load,
      required this.main,
      required this.user,
      this.filterLoad,
      required this.title,
      this.index,
      this.check,
      this.itemWordList})
      : super(key: key);
  final AuthState user;
  final String title;
  final String main;
  final String load;
  final String? filterLoad;
  int? index;
  bool? check;
  List<SentenceCat>? itemWordList;

  @override
  _SentenceScreenState createState() {
    return _SentenceScreenState();
  }
}

class _SentenceScreenState extends State<SentenceScreen> with WidgetsBindingObserver {
  FirebaseHelperRTD db = new FirebaseHelperRTD();
  List<Sentence> _sentences = [];
  Sentence? _selectedSentence;
  List<String> fileUrl = [];
  final _audioPlayerManager = AudioPlayerManager();
  bool _isLoading = false;
  bool _isPlaying = false;
  int _currentPlayingIndex = -1;
  late StreamSubscription _playerStateSubscription;
  String title = "";
  String load = "";
  String main = "";
  List<bool> isDownloaded = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    title = widget.title;
    load = widget.load;
    main = widget.main;
    print("title2 : ${title}");
    print("load2 : ${load}");
    print("main3 : ${main}");
    _getSentences(isRefresh: false);
    _playerStateSubscription = _audioPlayerManager.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  void _getSentences({String? searchTerm, required bool isRefresh}) async {
    print("slkdhj i ii id od o d ou ou");
    print("search term : $searchTerm");
    setState(() {
      _isLoading = true;
    });
    if ((searchTerm == null || searchTerm.length == 0) && !isRefresh) setState(() {});
    _sentences = [];
    print("load : ${widget.load}");
    print("load length : ${widget.load.length}");
    if (widget.load.length > 0) {
      print("from firebase");
      _sentences = await db.getFollowUps("SentenceConstructionLab", widget.main, widget.load);
      for (int i = 0; i < _sentences.length; i++) {
        print("sentence doc text: ${_sentences[i].text}");
        print("sentence doc key: ${_sentences[i].key}");
        print("sentence doc id: ${_sentences[i].id}");
        print("sentence doc isFav: ${_sentences[i].isFav}");
        print("sentence doc cat: ${_sentences[i].cat}");
        print("sentence doc localPath: ${_sentences[i].localPath}");
        print("sentence doc file: ${_sentences[i].file}");
      }
      isPlaying = List.generate(_sentences.length, (index) => false.obs);
      isDownloaded = List.generate(_sentences.length, (index) => false);
      await _checkAndPerformInitialFav();
    } else {
      print("local db");
      SentDatabaseProvider dbb = SentDatabaseProvider.get;
      SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
      List<Sentence> sentences = await dbRef.getWords();

      for (Sentence wr in sentences) {
        print(wr.cat);
        if ((wr.isFav == 1 && widget.filterLoad == null) ||
            (wr.isFav == 1 && widget.filterLoad != null && widget.filterLoad == wr.cat)) {
          _sentences.add(wr);
        }
      }
    }
    print("local path isssssssssssssssssss ${_sentences[0].localPath}");
    _isLoading = false;
    setState(() {});
  }

  Future<bool> _isFirstTimeUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime_$userId') ?? true;
  }

  Future<void> _setFirstTimeFlag(String userId, bool isFirstTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime_$userId', isFirstTime);
  }

  Future<void> _checkAndPerformInitialFav() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("sjdjknfkekfknkigk");
    String userId = await SharedPref.getSavedString('userId');
    bool isFirstTime = await _isFirstTimeUser(userId);
    print("userId:$userId");
    print("titleTrim:${widget.load.removeAllWhitespace}");
    bool mainTitleSentenceFirstTime = prefs.getBool(widget.main.removeAllWhitespace) ?? false;
    bool sentenceFirstTime = prefs.getBool(widget.load.removeAllWhitespace) ?? false;
    print("checkload: ${widget.load.removeAllWhitespace}");
    if (sentenceFirstTime == false) {
      print("djfijdovigjrdfigjv");
      await addInitialFav();
      prefs.setBool(widget.load.removeAllWhitespace, true);
      //  prefs.setBool(widget.main.removeAllWhitespace, true);
      setState(() {});
    } else {
      print("ijvijdrfvigjdri");
    }

    /*if (isFirstTime) {
    print(":sojdoifjrg");
    await addInitialFav();
    setState(() {
      // isfirst = false;
    });
    await _setFirstTimeFlag(userId, false);
  }*/
  }

  Future<void> addInitialFav() async {
    print("save First Five items in the list");
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String? localPath1;
      String? eLocalPath1;
      for (var i = 0; i < _sentences.length; i++) {
        print("sjfjdijfiejifjeiji");
        print("wordspriority:${_sentences[i].isPriority}");
        print("wordstext: ${_sentences[i].text}");
        print("wordfile: ${_sentences[i].file}");
        if (_sentences[i].isPriority == "true") {
          print("dsjfirjfiejf");
          print("isPriorityStatus:${_sentences[i].isPriority}");
          final downloadController = Provider.of<AuthState>(context, listen: false);
          localPath1 = await Utils.downloadFile(
              userDatas, _sentences[i].file!, '${_sentences[i].text}.mp3', '$appDocPath/${widget.load}');
          eLocalPath1 = EncryptData.encryptFile(localPath1, userDatas);
          try {
            await File(localPath1).delete();
          } catch (e) {}
          await toggleWordFavorite(eLocalPath1, _sentences[i]);
        }
      }
    } catch (e) {}
  }

  Future toggleWordFavorite(String? eLocalPath1, Sentence word) async {
    SentDatabaseProvider dbb = SentDatabaseProvider.get;
    SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
    await dbRef.setFav(word.id!, 1, eLocalPath1!);
    setState(() {
      word.isFav = 1;
    });
  }

  @override
  void dispose() {
    print("dispose function calleddddd");
    _playerStateSubscription.cancel();
    _audioPlayerManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("skmjfkijegfkingki");
    print("stateddfid:$state");
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        _audioPlayerManager.stop();
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        _audioPlayerManager.stop();
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        _audioPlayerManager.stop();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Future<void> _play(
  //   String url, String sentence,{
  //     String? localPath
  //   }
  // )async{
  //   String? eLocalPath;

  //   await _audioPlayerManager.play(url, context: context,decodedPath: (val) {
  //     eLocalPath = val;
  //   },);

  //   FirebaseHelper db = new FirebaseHelper();
  //   AuthState userDatas = Provider.of<AuthState>(context,listen: false);
  //   db.saveSentenceListReport(
  //     isPractice: false,
  //     company: userDatas.appUser!.company!,
  //     name: userDatas.appUser!.UserMname,
  //    userID: userDatas.appUser!.id!,
  //    sentence: sentence,
  //    team: userDatas.appUser!.team,
  //    userprofile: userDatas.appUser!.profile,
  //    city: userDatas.appUser!.city,
  //    date: DateFormat("dd-MMM-yyyy").format(DateTime.now()));

  //    if (eLocalPath != null && eLocalPath!.isNotEmpty) {
  //      try {
  //        await File(eLocalPath!).delete();
  //      } catch (e) {

  //      }
  //    }
  // }

  Future<void> _play(String sentence, int index, {required String url, String? localPath}) async {
    FirebaseHelper db = new FirebaseHelper();
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    String? eLocalPath;
    _currentPlayingIndex = index;

    try {
      print("AUDIO PLAY STARTEDddddddddd");
      print("*********URL : : : $url");
      await _audioPlayerManager.stop();
      await _audioPlayerManager.play(url, localPath: localPath, context: context, decodedPath: (val) {
        eLocalPath = val;
      });
      print("Audio play Completeddddddd : $eLocalPath");
      print("djkhdi u udedd : $title");
      print("djkhdi u udedd : $main");
      print("djkhdi u udedd : $load");
      await db.saveSentenceListReport(
          isPractice: false,
          company: userDatas.appUser!.company!,
          name: userDatas.appUser!.UserMname,
          userID: userDatas.appUser!.id!,
          sentence: sentence,
          team: userDatas.appUser?.team,
          userprofile: userDatas.appUser?.profile,
          city: userDatas.appUser?.city,
          date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          title: title,
          load: load,
          main: main);

      if (eLocalPath != null && eLocalPath!.isNotEmpty) {
        try {
          await File(eLocalPath!).delete();
          print('*********** LOCALPATH CMPLTD');
        } catch (e) {
          print('*********** LOCALPATH FAILED : $e');
        }
      } else {
        print("djgfkiwrngrhnjgrj");
      }
    } catch (e) {
      print(">>>>>>>>>>>>>>>AUdio play Failed : : : $e");
    }
  }

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    Get.dialog(Container(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        child: SpeechAnalyticsDialog(
          false,
          isShowDidNotCatch: notCatch,
          word: word,
          title: widget.title,
          load: widget.load,
          main: main,
        ),
      ),
    )).then((value) {
      if (value != null && value.isCorrect == "true" || value.isCorrect == "false") {
        showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              child: SentenceResultDialog(
                correctedWidget: value.formatedWords,
                score: value.wordPer,
                word: word,
                isCorrect: value.isCorrect == "true" ? true : false,
                practiceType: 'Sentence Construction Lab Report',
              ),
            );
          },
        );
      } else if (value != null && value.isCorrect == "notCatch") {
        _showDialog(word, true, context);
      } else if (value != null && value.isCorrect == "openDialog") {
        _showDialog(word, false, context);
      }
    });
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
      var response = await http.post(Uri.parse(url),
          body: {"userid": userId, "practicetype": "Sentence Construction Lab Report", "action": action});

      print("response start practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
        appBar: CommonAppBar(
          title: widget.title,
          onPressBool: true,
          onPressedEvent: () {
            print("backkk buttonn tappeedddddddd");
            if (widget.check == null) {
              Navigator.pop(context);
            } else if (widget.check!) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SentenceScreen(
                            index: widget.index,
                            itemWordList: widget.itemWordList,
                            user: widget.user,
                            title: widget.itemWordList![widget.index!].title ?? "",
                            load: widget.itemWordList![widget.index!].title ?? "",
                            main: widget.load,
                            // check: true,
                          )));
            }
          },
          // height: displayHeight(context) / 12.6875,
        ),
        body: _sentences.length == 0 && !_isLoading
            ? Center(
                child: Text(
                  "List is empty",
                  style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily),
                ),
              )
            : Stack(
                children: [
                  ListView.builder(
                      padding: EdgeInsets.only(top: 10),
                      itemCount: _sentences.length,
                      itemBuilder: (BuildContext context, int index) {
                        print("AUDIO URL: ${_sentences[index].file}");
                        return DropDownWordItem(
                          index: index,
                          isDownloaded: _sentences[index].localPath != null && _sentences[index].localPath!.isNotEmpty,
                          localPath: _sentences[index].localPath,
                          load: widget.load,
                          maintitle: widget.title,
                          url: _sentences[index].file,
                          onExpansionChanged: (val) {
                            if (val) {
                              _selectedSentence = _sentences[index];
                              setState(() {});
                            }
                          },
                          initiallyExpanded: _selectedSentence != null && _selectedSentence == _sentences[index],
                          isFav: _sentences[index].isFav!,
                          wordId: _sentences[index].id!,
                          isWord: false,
                          isRefresh: (val) {
                            if (val) _getSentences(isRefresh: true);
                          },
                          title: _sentences[index].text!,
                          onTapForThreePlayerStop: () {},
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 30, right: 30),
                              child: Container(
                                height: 59,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        print('INDEX : : : $index');
                                        if (_isPlaying && _currentPlayingIndex == index) {
                                          print("checkkkkkk222222222222");
                                          _audioPlayerManager.stop();
                                        } else {
                                          startPractice(actionType: 'listening');
                                          print("checkkkkkk111111111111");
                                          _play(
                                            _sentences[index].text!, index,
                                            url: _sentences[index].file!,
                                            // localPath:
                                            //     _sentences[index].localPath!,
                                          );

                                          /* String? sentenceFileUrl = _sentences[index].file;
                                          print("sentenceFileUrl:${_sentences[index].file}");
                                          fileUrl?.add(sentenceFileUrl!);
                                          FirebaseFirestore firestore = FirebaseFirestore.instance;
                                          String userId = await SharedPref.getSavedString('userId');
                                          DocumentReference wordFileUrlDocument =
                                              firestore.collection('proFluentEnglishReport').doc(userId);

                                          await wordFileUrlDocument.update({
                                            'SentencesTapped': FieldValue.arrayUnion([_sentences[index].file]),
                                          }).then((_) {
                                            print('Link added to Firestore: ${_sentences[index].file}');
                                          }).catchError((e) {
                                            print('Error updating Firestore: $e');
                                          });
                                          print("fileUrl:${_sentences[index].file}");
                                          print("sdhhvgfrhngkihri");*/
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          SPW(35),
                                          Icon(
                                            _isPlaying && _currentPlayingIndex == index
                                                ? Icons.pause_circle_outline
                                                : Icons.play_circle_outline,
                                            color: AppColors.black,
                                          ),
                                          SPW(5),
                                          Text(
                                            "Native Speaker",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // if (_isPlaying)
                                    //   InkWell(
                                    //       onTap: () {
                                    //         _audioPlayerManager.stop();
                                    //       },
                                    //       child: Icon(
                                    // Icons.pause_circle_outline,
                                    // color: AppColors.black,
                                    //       )),
                                    InkWell(
                                      onTap: () async {
                                        startPractice(actionType: 'practice');
                                        _showDialog(_sentences[index].text!, false, context);
                                        String? sentenceFileUrl = _sentences[index].file;
                                        print("sentenceFileUrl:${_sentences[index].file}");
                                        fileUrl?.add(sentenceFileUrl!);
                                        FirebaseFirestore firestore = FirebaseFirestore.instance;
                                        String userId = await SharedPref.getSavedString('userId');
                                        DocumentReference wordFileUrlDocument =
                                            firestore.collection('proFluentEnglishReport').doc(userId);

                                        await wordFileUrlDocument.update({
                                          'SentencesTapped': FieldValue.arrayUnion([_sentences[index].file]),
                                        }).then((_) {
                                          print('Link added to Firestore: ${_sentences[index].file}');
                                        }).catchError((e) {
                                          print('Error updating Firestore: $e');
                                        });
                                        print("fileUrl:${_sentences[index].file}");
                                        print("sdhhvgfrhngkihri");
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.mic,
                                          ),
                                          SPW(5),
                                          Text(
                                            "Practice",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          SPW(35),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  if (_isLoading) Center(child: CircularProgressIndicator(color: Colors.white))
                ],
              ),
        floatingActionButton: buildBoomMenu());
  }

  BoomMenu buildBoomMenu() {
    return BoomMenu(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0, color: AppColors.white),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        backgroundColor: Color(0xFF6C63FE),
        overlayColor: Colors.black,
        overlayOpacity: 0.96,
        children: [
          bm.MenuItem(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.home,
                color: Colors.grey,
                size: 18,
              ),
            ),
            title: "Home",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          bm.MenuItem(
            child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Image.asset("assets/images/filter.png", color: Colors.grey)),
            title: "Filter Priority",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () async {
              print("user : $sentenceRepeatUser");
              print("main : $sentenceRepeatLoad");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('SentenceScreen', ["Priority List", "", sentenceRepeatLoad]);
              await prefs.setString('lastAccess', 'SentenceScreen');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SentenceScreen(
                            user: sentenceRepeatUser,
                            title: "Priority List",
                            load: "",
                            main: sentenceRepeatLoad,
                            filterLoad: sentenceRepeatLoad,
                          ))).then((val) => _getSentences(isRefresh: false));
            },
          ),
          bm.MenuItem(
            child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Image.asset("assets/images/filter_all.png", color: Colors.grey)),
            title: "Filter All Priority",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('SentenceScreen', ["All Priority List", "", widget.load]);
              await prefs.setString('lastAccess', 'SentenceScreen');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SentenceScreen(
                            user: widget.user,
                            title: "All Priority List",
                            load: "",
                            main: widget.load,
                          ))).then((val) => _getSentences(isRefresh: false));
            },
          ),
        ]);
  }
}
