import 'dart:developer';
import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/boom_menu.dart';
import 'package:litelearninglab/common_widgets/boom_menu_item.dart' as bm;
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/database/WordsDatabaseRepository.dart';
import 'package:litelearninglab/database/databaseProvider.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/models/Word.dart';
import 'package:litelearninglab/screens/dialogs/own_word_dialog.dart';
import 'package:litelearninglab/screens/dialogs/speech_analytics_dialog.dart';
import 'package:litelearninglab/screens/profluent_english/profluent_english_screen.dart';
import 'package:litelearninglab/screens/profluent_english/word_screen.dart';
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/screens/word_screen/widgets/word_menu.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:litelearninglab/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../states/auth_state.dart';
import '../../utils/audio_player_manager.dart';
import '../../utils/firebase_helper.dart';
import '../profluent_english/new_profluent_english_screen.dart';
import 'package:http/http.dart' as http;

enum PlayingRouteState { speakers, earpiece }

bool isAllPlaying3 = false;
bool isAllPlaying = false;

class WordScreen extends StatefulWidget {
  WordScreen({
    Key? key,
    this.check,
    this.index,
    required this.title,
    required this.load,
    this.word,
    this.filterLoad,
    this.controllerList,
    this.itemWordList,
    this.soundPractice,
    this.checkTitle,
    this.backButtonCheck,
  }) : super(key: key);
  final String title;
  final String load;
  final ProLab? word;
  final String? filterLoad;
  final List<Word>? soundPractice;
  int? index;
  bool? check;
  bool? backButtonCheck;
  String? checkTitle;
  List<Map<String, dynamic>>? controllerList;
  List<Map<String, dynamic>>? itemWordList;

  @override
  _WordScreenState createState() {
    return _WordScreenState();
  }
}

class _WordScreenState extends State<WordScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final db = new FirebaseHelperRTD();
  FirebaseHelper _firestore = new FirebaseHelper();
  bool openPlay1StopDialog = false;
  bool openPlay3StopDialog = false;
  bool closePlay1StopDialog = false;
  bool closePlay3StopDialog = false;
  bool _isPaused = false;
  bool _isPaused3 = false;
  int _currentIndex = 0;
  int _currentIndex3 = 0;
  int _currentPlayCount3 = 0;
  bool switchingKey = false;
  bool wordsFirstTime = true;

  List<Word> _words = [];
  final _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isCorrect = false;
  String _selectedWord = "";
  String? _selectedWordOnClick;
  bool open = false;
  bool audioLoading = false;
  final Map<String, GlobalKey> _itemKeys = {};

  late AutoScrollController controller;

  final _audioPlayerManager = AudioPlayerManager();

  pronunciationLabReport({required actionType, required word}) async {
    print("pronunciation lab report tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    print("wordddddd:$word");
    String action = actionType;
    print("action:${action}");
    String url = baseUrl + pronunciationLabReportApi;
    print("url : $url");
    try {
      print("responseeeeeeee");
      var response = await http.post(Uri.parse(url), body: {"userid": userId, "type": action, "word": word});

      print("response for pronunciation lab report for correct words : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  endPractice({required practiceType, required successCount}) async {
    print("practice Type: $practiceType");
    print("end practice Tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd:$userId");
    String url = baseUrl + endPracticeApi;
    print("url : $url");
    print("successCount:$successCount");
    /* print("scoreeeeetypeee:${widget.score.runtimeType}");
    print("scoreeee:${widget.score}");*/
    try {
      var response = await http
          .post(Uri.parse(url), body: {"userid": userId, "practicetype": practiceType, "score": "", "action": "practice", "successCount": successCount});

      print("response end practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical);

    _getWords(isRefresh: false);
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

  Future toggleWordFavorite(String? eLocalPath1, Word word) async {
    print("togglewordfavorite function calleddd");
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    await dbRef.setFav(word.id!, 1, eLocalPath1!);
    setState(() {
      word.isFav = 1;
    });
  }

  Future<void> addInitialFav() async {
    print("save First Five items in the list");
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String? localPath1;
      String? eLocalPath1;
      for (var i = 0; i < _words.length; i++) {
        print("sjfjdijfiejifjeiji");
        print("wordspriority:${_words[i].isPriority}");
        print("wordstext: ${_words[i].text}");
        print("wordfile: ${_words[i].file}");
        if (_words[i].isPriority == "true") {
          print("dsjfirjfiejf");
          print("isPriorityStatus:${_words[i].isPriority}");
          AuthState userDatas = Provider.of<AuthState>(context, listen: false);

          localPath1 = await Utils.downloadFile(userDatas, _words[i].file!, '${_words[i].text}.mp3', '$appDocPath/${widget.load}');
          eLocalPath1 = EncryptData.encryptFile(localPath1, userDatas);
          print("localllpathh11:$localPath1");
          print('eLocalPathhh111 :${eLocalPath1}');
          print('localpathhhh<<<:${_words[0].localPath}');
          _words[i].localPath = eLocalPath1;

          try {
            await File(localPath1).delete();
          } catch (e) {}
          print("sdidjgidjgijfg");
          await toggleWordFavorite(eLocalPath1, _words[i]);
        }
        /* if (_words[i].isPriority == "false") {
          print("ispriority false function calleddd");
          AuthState userDatas = Provider.of<AuthState>(context, listen: false);

          localPath1 = await Utils.downloadFile(
              userDatas, _words[i].file!, '${_words[i].text}.mp3', '$appDocPath/${widget.load}');
          eLocalPath1 = EncryptData.encryptFile(localPath1, userDatas);
          print("localllpathh11:$localPath1");
          print('eLocalPathhh111 :${eLocalPath1}');

          try {
            await File(localPath1).delete();
          } catch (e) {}
          await toggleWordFavorite(eLocalPath1, _words[i]);
        }*/
      }
    } catch (e) {}
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
    _isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = await SharedPref.getSavedString('userId');
    bool isFirstTime = await _isFirstTimeUser(userId);
    bool wordsFirstTime1 = prefs.getBool(widget.title.removeAllWhitespace) ?? true;
    print("world ${wordsFirstTime1}");
    setState(() {});
    if (wordsFirstTime1 == true) {
      print("smgojf");
      wordsFirstTime = !wordsFirstTime1;
      setState(() {});
      await addInitialFav();
      await prefs.setBool(widget.title.removeAllWhitespace, false);
      wordsFirstTime = await prefs.getBool(widget.title.removeAllWhitespace) ?? false;
      setState(() {});
    } else {
      print("wdfdjgi:${wordsFirstTime}");
      wordsFirstTime = false;
      print("wordsfirstTime:${wordsFirstTime}");
      setState(() {});
    }
    _isLoading = false;
    setState(() {});

/*    if (widget.load == "daysdates") {
      bool dayDatesFirstTime = prefs.getBool("dayDatesFirstTime") ?? false;
      if (dayDatesFirstTime == false) {
        await addInitialFav();
        prefs.setBool("dayDatesFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "Latters and NATO") {
      bool lettersEnglishFirstTime = prefs.getBool("lettersEnglishFirstTime") ?? false;
      if (lettersEnglishFirstTime == false) {
        await addInitialFav();
        prefs.setBool("lettersEnglishFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "States and Cities") {
      bool stateCitiesFirstTime = prefs.getBool("stateCitiesFirstTime") ?? false;
      if (stateCitiesFirstTime == false) {
        await addInitialFav();
        prefs.setBool("stateCitiesFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "ProcessWords") {
      bool ProcessWordsFirstTime = prefs.getBool("ProcessWordsFirstTime") ?? false;
      if (ProcessWordsFirstTime == false) {
        await addInitialFav();
        prefs.setBool("ProcessWordsFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "CommonWords") {
      bool commonWordsFirstTime = prefs.getBool("commonWordsFirstTime") ?? false;
      if (commonWordsFirstTime == false) {
        await addInitialFav();
        prefs.setBool("commonWordsFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "US Healthcare") {
      bool UsHealthCareFirstTime = prefs.getBool("UsHealthCareFirstTime") ?? false;
      if (UsHealthCareFirstTime == false) {
        await addInitialFav();
        prefs.setBool("UsHealthCareFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "Restaurant Hotel Travel") {
      bool RestaurantFirstTime = prefs.getBool("RestaurantFirstTime") ?? false;
      if (RestaurantFirstTime == false) {
        await addInitialFav();
        prefs.setBool("RestaurantFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "Business Words") {
      bool businessWordsFirstTime = prefs.getBool("businessWordsFirstTime") ?? false;
      if (businessWordsFirstTime == false) {
        await addInitialFav();
        prefs.setBool("businessWordsFirstTime", true);
        setState(() {});
      }
    } else if (widget.load == "Information Technology") {
      bool ITFirstTime = prefs.getBool("ITFirstTime") ?? false;
      if (ITFirstTime == false) {
        await addInitialFav();
        prefs.setBool("ITFirstTime", true);
        setState(() {});
      }
    }*/

    /*  if (isFirstTime) {
      print(":sojdoifjrg");
      await addInitialFav();
      setState(() {
        // isfirst = false;
      });
      await _setFirstTimeFlag(userId, false);
    }*/
  }

  void _getWords({String? searchTerm, required bool isRefresh}) async {
    print("getwordsscalleddddddd>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print("searchTerm: ${searchTerm}");
    _isLoading = true;
    if ((searchTerm == null || searchTerm.length == 0) && !isRefresh) setState(() {});
    _words = [];
    if (widget.load.length > 0) {
      print("show the data from the firebase");
      _words = await db.getWords(widget.load);

      isPlaying = List.generate(_words.length, (index) => false.obs);
      // isPlaying = List.generate(_words.length, (index) => false);
      print('list first item from local:${_words.first.localPath}');

      await _checkAndPerformInitialFav();
    } else {
      print("show the data from the database");
      print("djfijuif");
      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
      List<Word> words = await dbRef.getWords();
      isPlaying = List.generate(_words.length, (index) => false.obs);
      // isPlaying = List.generate(_words.length, (index) => false);
      for (Word wr in words) {
        if ((wr.isFav == 1 && widget.filterLoad == null) || (wr.isFav == 1 && widget.filterLoad != null && widget.filterLoad == wr.cat)) {
          _words.add(wr);
          log("${wr.cat}");
          log("${wr.file}");
        }
      }
    }

    if (searchTerm != null && searchTerm.length > 0) {
      _words = _words.where((element) => element.text!.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    }
    if (widget.word != null) _selectedWordOnClick = widget.word?.id;
    _isLoading = false;

    if (widget.word != null) {
      await controller.scrollToIndex(_words.indexWhere((element) => element.text == widget.word?.id), preferPosition: AutoScrollPosition.begin);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchQueryController.dispose();
    // _audioPlayerManager.dispose();
    isAllPlaying3 = false;
    isAllPlaying = false;
    super.dispose();
  }

  Widget _buildSearchField() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 5, left: 45),
        child: TextField(
          controller: _searchQueryController,
          autofocus: true,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder: UnderlineInputBorder(),
            disabledBorder: UnderlineInputBorder(),
            hintText: "Search",
            hintStyle: TextStyle(
              fontFamily: Keys.fontFamily,
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            //   contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Color(0xFF324265),
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          onChanged: (query) {
            _getWords(searchTerm: query, isRefresh: false);
          },
        ),
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    _getWords(searchTerm: newQuery, isRefresh: false);
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        Spacer(),
        IconButton(
          icon: Icon(Icons.search_rounded, color: Colors.white),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _getWords(searchTerm: _searchQueryController.text, isRefresh: false);
          },
        ),
        SPW(displayWidth(context) / 37.5)
      ];
    }

    return <Widget>[
      if (widget.title.trim() == "Priority List" && !isAllPlaying3 || widget.title.trim() == "All Priority List" && !isAllPlaying3)
        _words.length == 0
            ? SizedBox()
            : IconButton(
                icon: Image.asset(
                  "assets/images/play_3new.png",
                  width: 25,
                  //color: Colors.white,
                ),
                onPressed: () {
                  print("dfnefjeijfoej");
                  //_audioPlayerManager.stop();
                  isAllPlaying = false;
                  setState(() {
                    closePlay1StopDialog = true;
                    openPlay3StopDialog = true;
                    closePlay3StopDialog = false;
                    _isPaused3 = false;
                    _currentIndex3 = 0;
                  });
                  _playAll3Times();
                }),
      if (widget.title.trim() == "Priority List" && isAllPlaying3 || widget.title.trim() == "All Priority List" && isAllPlaying3)
        _words.length == 0
            ? SizedBox()
            : IconButton(
                icon: Image.asset(
                  "assets/images/play_3new.png",
                  width: 25,
                  //color: Colors.white,
                ),
                onPressed: () {
                  print(" 3 icon calleddd");
                  // _audioPlayerManager.stop();
                  //isAllPlaying3 = false;
                  // setState(() {});
                },
              ),
      if (widget.title.trim() == "Priority List" && !isAllPlaying || widget.title.trim() == "All Priority List" && !isAllPlaying)
        _words.length == 0
            ? SizedBox()
            : IconButton(
                icon: Image.asset(
                  "assets/images/play_1new.png",
                  width: 25,
                  //color: Colors.white,
                ),
                onPressed: () {
                  print("play 1 icon pressed");
                  isAllPlaying3 = false;
                  setState(() {
                    closePlay3StopDialog = true;
                    openPlay1StopDialog = true;
                    closePlay1StopDialog = false;
                    _isPaused = false;
                    _currentIndex = 0;
                    switchingKey = true;
                    print("swithchingKey:${switchingKey}");
                  });
                  _playAll();
                },
              ),
      if (widget.title.trim() == "Priority List" && isAllPlaying || widget.title.trim() == "All Priority List" && isAllPlaying)
        _words.length == 0
            ? SizedBox()
            : IconButton(
                icon: Image.asset(
                  "assets/images/play_1new.png",
                  width: 25,
                  //color: Colors.white,
                ),
                onPressed: () {
                  log("pause button clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                  /*     _audioPlayerManager.stop();
            isAllPlaying = false;*/
                  setState(() {});
                },
              ),
      IconButton(
        icon: Icon(Icons.search_rounded, color: Colors.white),
        onPressed: _startSearch,
      ),
      SPW(displayWidth(context) / 37.5)
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  void _scrollToItem(int index) {
    final double itemHeight = 200.0; // Adjust based on your item height
    final position = index * itemHeight;
    final viewportHeight = controller.position.viewportDimension;
    final offset = controller.offset;

    if (position < offset || position + itemHeight > offset + viewportHeight) {
      controller.animateTo(
        position,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    // log("message");
    Get.dialog(
      Container(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: SpeechAnalyticsDialog(
            true,
            isShowDidNotCatch: notCatch,
            word: word,
            title: widget.title,
            load: widget.load,
          ),
        ),
      ),
    ).then((value) {
      if (value != null && value.isCorrect == "true" || value.isCorrect == "false") {
        print("checkkkkkkkkkkkkkk");
        _selectedWord = word;
        _isCorrect = value.isCorrect == "true" ? true : false;
        print("correct or wrong:${_isCorrect}");
        //value.isCorrect ? pronunciationLabReport(actionType: "correct", word: widget.word) : "";
        print("isCorrecttt:${_isCorrect}");
        setState(() {
          print('wordddddddd: ${word}');
          print("valueIsCorrect: ${_isCorrect}");
          _isCorrect ? pronunciationLabReport(actionType: "correct", word: word) : "";
          _isCorrect
              ? endPractice(practiceType: "Pronunciation Sound Lab Report", successCount: "correct")
              : endPractice(practiceType: "Pronunciation Sound Lab Report", successCount: "wrong");
        });
      } else if (value != null && value.isCorrect == "notCatch") {
        print("checkk222");
        _showDialog(word, true, context);
      } else if (value != null && value.isCorrect == "openDialog") {
        print("checkk11");
        _showDialog(word, false, context);
      }
    }).onError((error, stackTrace) {
      log(error.toString());
    });
  }

  void _playAll() async {
    if (isAllPlaying3) {
      print("sdjhdjuvgdrg");
      return;
    }
    _isPaused = false;
    isAllPlaying = true;
    audioLoading = false;
    String? eLocalPath;
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    setState(() {});
    isPlaying = List.generate(_words.length, (index) => false.obs);
    setState(() {});

    for (int i = _currentIndex; i < _words.length; i++) {
      print("Current Index: $i");

      if (_isPaused) {
        _currentIndex = i;
        print("Paused at index: $_currentIndex");
        break; // Exit the loop if paused
      }

      if (isAllPlaying && _words[i].file != null && _words[i].file!.isNotEmpty) {
        _words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});
        await _audioPlayerManager.play(_words[i].file!, context: context, localPath: _words[i].localPath, decodedPath: (val) {
          eLocalPath = val;
        });

        await Future.delayed(Duration(seconds: 2));
        _words[i].isPlaying = false;
        isPlaying[i].value = false;

        if (eLocalPath != null && eLocalPath!.isNotEmpty) {
          try {
            File(eLocalPath!).delete();
          } catch (e) {}
        }

        _firestore.saveWordListReport(
          isPractice: false,
          company: userDatas.appUser!.company!,
          name: userDatas.appUser!.UserMname,
          userID: userDatas.appUser!.id!,
          word: widget.title,
          team: userDatas.appUser?.team,
          userprofile: userDatas.appUser?.profile,
          city: userDatas.appUser?.city,
          load: widget.load,
          title: widget.title,
          time: 1,
          date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
        );
      }
    }
    if (!_isPaused) {
      _currentIndex = _words.length - 1;
      print("_currentIndexxxxxxxxxxxxx:${_currentIndex}");
      // _currentIndex = 0;
      isAllPlaying = false;
      if (_currentIndex == _words.length - 1) {
        print("sucessss>>>>>>>>>>>>>>>>>>");
        closePlay1StopDialog = true;
        print("opendialogplay1status:${openPlay1StopDialog}");
      }
      setState(() {});
    }
  }

  void pauseAll() {
    if (isAllPlaying) {
      print("Pause called");
      _audioPlayerManager.pause();
      setState(() {
        _isPaused = true;
      });
      isAllPlaying = false;
    }
  }

  void resumeAll() async {
    if (_isPaused) {
      print("Resume function called");
      audioLoading = true;
      setState(() {});
      await Future.delayed(Duration(seconds: 2));

      _audioPlayerManager.resume();

      _playAll();
    }
  }

  void _playAll3Times() async {
    log("three playing switch clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    _isPaused3 = false;
    audioLoading = false;
    isAllPlaying3 = true;
    String? eLocalPath;
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    isPlaying = List.generate(_words.length, (index) => false.obs);
    setState(() {});

    for (int i = _currentIndex3; i < _words.length; i++) {
      if (!isAllPlaying3) break;

      if (_words[i].file != null && _words[i].file!.isNotEmpty) {
        for (int j = _currentPlayCount3; j < 3; j++) {
          print("jloooppppppppppppppp");
          if (!isAllPlaying3) {
            _currentIndex3 = i;
            _currentPlayCount3 = j;
            print("Paused at index: $_currentIndex3, play count: $_currentPlayCount3");
            return;
          }
          if (_isPaused3) {
            print("sjaoijdifjiwjr");
            _currentIndex3 = i;
            _currentPlayCount3 = j;
            print("Paused at index: $_currentIndex3, play count: $_currentPlayCount3");
            return;
          }

          log("Playing word at index: $i, play count: $j");
          _words[i].isPlaying = true;
          isPlaying[i].value = true;
          setState(() {});

          await _audioPlayerManager.play3(
            _words[i].file!,
            context: context,
            localPath: _words[i].localPath,
            decodedPath: (val) {
              eLocalPath = val;
            },
          );

          await Future.delayed(Duration(seconds: 2));
          _words[i].isPlaying = false;
          isPlaying[i].value = false;

          if (eLocalPath != null && eLocalPath!.isNotEmpty) {
            try {
              File(eLocalPath!).delete();
            } catch (e) {
              log("Failed to delete file: $e");
            }
          }

          _firestore.saveWordListReport(
            isPractice: false,
            company: userDatas.appUser!.company!,
            name: userDatas.appUser!.UserMname,
            userID: userDatas.appUser!.id!,
            word: widget.title,
            team: userDatas.appUser?.team,
            userprofile: userDatas.appUser?.profile,
            city: userDatas.appUser?.city,
            load: widget.load,
            title: widget.title,
            time: 1,
            date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          );
        }
        _currentPlayCount3 = 0;
      }
    }

    if (!_isPaused3) {
      // _currentIndex3 = 0;
      _currentIndex3 = _words.length - 1;
      _currentPlayCount3 = 0;
      print("jfijedfijerjedj");
      print("CurrentIndexCheck:${_currentIndex3}");
      print("worsLengthCheck:${_words.length - 1}");
      isAllPlaying3 = false;
      if (_currentIndex3 == _words.length - 1) {
        print("sucessss>>>>>>>>>>>>>>>>>>");
        closePlay3StopDialog = true;
        print("opendialogplay1status:${openPlay3StopDialog}");
      }
      setState(() {});
    }
  }

  void pauseAll3() {
    if (isAllPlaying3) {
      print("Pause called");

      _audioPlayerManager.pause();
      _isPaused3 = true;
      isAllPlaying3 = false;
      setState(() {});
    }
  }

  void resumeAll3() async {
    if (_isPaused3) {
      audioLoading = true;
      setState(() {});
      await Future.delayed(Duration(seconds: 2));

      print("Resume function called");
      _audioPlayerManager.resume();

      _playAll3Times();
    }
  }

  updateThreePlayerFlag() {
    log("working the threeplayer switch>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    isAllPlaying3 = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              print("back button is callingggggg");
              if (widget.check == null) {
                print("check is empty");
                Navigator.pop(context);
              } else if (widget.check!) {
                print("checkingggg:${widget.check}");
                print("checkvjdiv");
                print("titlecheckkk:${widget.itemWordList![widget.index!]['title']}");
                Navigator.pop(context);
                // Navigator.pop(context);
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                //   return WordScreen(
                //     itemWordList: widget.itemWordList,
                //     controllerList: widget.controllerList,
                //     title: widget.itemWordList![widget.index!]['title'],
                //     load: widget.itemWordList![widget.index!]['load'],
                //   );
                // }));
              } else if (widget.check == null && widget.backButtonCheck == null) {
                print("djgirhivgh");
                Navigator.pop(context);
              } else if (widget.check == false && widget.backButtonCheck!) {
                print("djighrijv");
                Navigator.pop(context);
                // Navigator.pop(context);
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => WordScreenProfluentEnglish(
                //               title: widget.checkTitle!,
                //               load: widget.checkTitle!,
                //               soundPractice: widget.soundPractice!,
                //             )));
              } else {
                print("calleddddddfgnirfjgirfjgi");
                Navigator.pop(context);
              }
              /*     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return LabS
              }));*/
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          flexibleSpace: !_isSearching
              ? Padding(
                  padding: EdgeInsets.only(left: getWidgetWidth(width: 50)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: displayWidth(context) / 1.4,
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          style: TextStyle(
                              fontFamily: Keys.fontFamily,
                              fontSize: globalFontSize(18, context),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildSearchField(),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: false,
          actions: _buildActions(),
          backgroundColor: Color(0xFF324265),
        ),
        body:
            //  _isConnected == false
            //     ? Center(
            //         child: Text(
            //           "No Network Connection",
            //           style: TextStyle(
            //               color: AppColors.white, fontFamily: Keys.fontFamily),
            //         ),
            //       )
            //     :
            _words.length == 0 && !_isLoading
                ? Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            "Not Found",
                            style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily),
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
                  )
                : _isLoading
                    ? !wordsFirstTime
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "This may take a couple of minutes \n(only during the first time).",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "Please stay on this page, do \nnot go back or close the app.",
                                  style: TextStyle(color: Colors.red, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 13),
                                CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                    : Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ListView.builder(
                                    padding: EdgeInsets.only(top: isSplitScreen ? getFullWidgetHeight(height: 10) : getWidgetHeight(height: 10)),
                                    itemCount: _words.length,
                                    controller: controller,
                                    itemBuilder: (BuildContext context, int index) {
                                      if (!isAllPlaying && !isAllPlaying3) {
                                        print("listWordLength:${_words.length}");
                                        print("dfjusfeiujfejdsfj");
                                        print("currentIndex : ${_currentIndex}");
                                        print("wordLengthIndex:${_words.length - 1}");
                                        isPlaying = List.generate(_words.length, (index) => false.obs);

                                        /* if (_currentIndex == _words.length - 1) {
                                          print("sucessss>>>>>>>>>>>>>>>>>>");
                                          closePlay1StopDialog = true;
                                        }*/
                                        //_getWords(isRefresh: false);
                                      }
                                      return AutoScrollTag(
                                        key: ValueKey(_words[index].text),
                                        controller: controller,
                                        index: index,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: index == _words.length - 1
                                                  ? isSplitScreen
                                                      ? getFullWidgetHeight(height: 60)
                                                      : getWidgetHeight(height: 60)
                                                  : 0),
                                          child: DropDownWordItem(
                                            localPath: _words[index].localPath,
                                            load: widget.load,
                                            length: _words.length,
                                            index: index,
                                            // isPlaying: _words[index].isPlaying,
                                            isDownloaded: (_words[index].localPath != null && _words[index].localPath!.isNotEmpty),
                                            maintitle: widget.title,
                                            onExpansionChanged: (val) {
                                              print("check1111111111111111111111111444>");
                                              print("djfdjfihdifhidfid:${_words[index].localPath}");
                                              setState(() {
                                                _selectedWord = '';
                                              });
                                              if (val) {
                                                _selectedWordOnClick = _words[index].text;
                                                print("sajidjg:${_words[index].text}");
                                                setState(() {});
                                                if (_words.length - 2 <= index) {
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    _scrollToItem(index);
                                                  });
                                                }
                                              }
                                            },
                                            initiallyExpanded: _selectedWordOnClick != null && _selectedWordOnClick == _words[index].text,
                                            isWord: true,
                                            isRefresh: (val) {
                                              if (val) _getWords(isRefresh: true);
                                            },
                                            // words: _words,
                                            wordId: _words[index].id!,
                                            isFav: _words[index].isFav!,
                                            title: _words[index].text!,
                                            url: _words[index].file,
                                            onTapForThreePlayerStop: updateThreePlayerFlag,
                                            children: [
                                              WordMenu(
                                                pronun: _words[index].pronun!,
                                                selectedWord: _selectedWord,
                                                isCorrect: _selectedWord == _words[index].text && _isCorrect,
                                                text: _words[index].text!,
                                                syllables: _words[index].syllables!,
                                                onTapHeadphone: () async {},
                                                url: _words[index].file,
                                                onTapMic: () async {
                                                  _showDialog(_words[index].text!, false, context);
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                openPlay3StopDialog && !closePlay3StopDialog
                                    ? Positioned(
                                        right: 120,
                                        top: 5,
                                        child: Container(
                                          height: isSplitScreen ? getFullWidgetHeight(height: 45) : getWidgetHeight(height: 45),
                                          width: getWidgetWidth(width: 108),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, top: 5),
                                                child: Image.asset(
                                                  "assets/images/Play_thrice_icon.png",
                                                  // height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                              !isAllPlaying3
                                                  ? audioLoading
                                                      ? Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: CircularProgressIndicator(
                                                              color: Color(0XFF34425D),
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            resumeAll3();
                                                          },
                                                          child: Icon(Icons.play_arrow, color: Color(0XFF34425D), size: 30))
                                                  : audioLoading
                                                      ? Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: CircularProgressIndicator(
                                                              color: Color(0XFF34425D),
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            pauseAll3();
                                                          },
                                                          child: Icon(Icons.pause, color: Color(0XFF34425D), size: 30)),
                                              IconButton(
                                                  onPressed: () {
                                                    _audioPlayerManager.stop();
                                                    isAllPlaying3 = false;
                                                    setState(() {
                                                      openPlay3StopDialog = false;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.stop,
                                                    color: Color(0XFF34425D),
                                                    size: 26,
                                                  )),
                                            ],
                                          ),
                                        ))
                                    : openPlay1StopDialog && !closePlay1StopDialog
                                        ? Positioned(
                                            right: 120,
                                            top: 5,
                                            child: Container(
                                              height: isSplitScreen ? getFullWidgetHeight(height: 45) : getWidgetHeight(height: 45),
                                              width: getWidgetWidth(width: 108),
                                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8, top: 5),
                                                    child: Image.asset(
                                                      "assets/images/Play_once_icon.png",
                                                      // height: 15,
                                                      width: 30,
                                                    ),
                                                  ),
                                                  _isPaused
                                                      ? audioLoading
                                                          ? Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child: CircularProgressIndicator(
                                                                  color: Color(0XFF34425D),
                                                                  strokeWidth: 2,
                                                                ),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                print("checkkkkkkkkk11");
                                                                resumeAll();
                                                              },
                                                              child: Icon(Icons.play_arrow, color: Color(0XFF34425D), size: 30))
                                                      : audioLoading
                                                          ? Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child: CircularProgressIndicator(
                                                                  color: Color(0XFF34425D),
                                                                  strokeWidth: 2,
                                                                ),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                print("checkkk222");
                                                                pauseAll();
                                                              },
                                                              child: Icon(
                                                                Icons.pause,
                                                                color: Color(0XFF34425D),
                                                                size: 30,
                                                              )),
                                                  InkWell(
                                                      onTap: () {
                                                        _audioPlayerManager.stop();
                                                        isAllPlaying = false;
                                                        setState(() {
                                                          openPlay1StopDialog = false;
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.stop,
                                                        color: Color(0XFF34425D),
                                                        size: 30,
                                                      )),
                                                ],
                                              ),
                                            ))
                                        : SizedBox()
                              ],
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
        floatingActionButton: _isLoading ? SizedBox() : buildBoomMenu());
  }

  buildBoomMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getWidgetHeight(height: 80)),
      child: BoomMenu(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0, color: AppColors.white),
          onOpen: () {
            print('OPENING DIAL');
          },
          onClose: () {
            print('DIAL CLOSED');
          },
          backgroundColor: Color(0xFF6C63FE),
          overlayColor: Color(0Xff293750), //Colors.transparent,
          overlayOpacity: 0.9,
          children: [
            bm.MenuItem(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: getWidgetWidth(width: 12), vertical: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  Icons.home,
                  color: Colors.grey,
                  size: isSplitScreen ? getFullWidgetHeight(height: 18) : getWidgetHeight(height: 18),
                ),
              ),
              title: "Home",
              titleColor: Colors.white,
              backgroundColor: Color(0x00000000),
              onTap: () {
                context.read<AuthState>().changeIndex(0);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
              },
            ),
            bm.MenuItem(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: getWidgetWidth(width: 12), vertical: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  Icons.keyboard,
                  color: Colors.grey,
                  size: isSplitScreen ? getFullWidgetHeight(height: 18) : getWidgetHeight(height: 18),
                ),
              ),
              title: "Try Unlisted Words",
              titleColor: Colors.white,
              backgroundColor: Colors.transparent,
              onTap: () {
                isAllPlaying = false;
                isAllPlaying = false;

                setState(() {});
                showDialog(
                  useRootNavigator: true,
                  context: context,
                  builder: (BuildContext context) {
                    return OwnWordDialog(
                      isFromWord: true,
                    );
                    // return OwnWordResultDialog();
                  },
                );
              },
            ),
            bm.MenuItem(
              child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 12), vertical: isSplitScreen ? getFullWidgetHeight(height: 12) : getWidgetHeight(height: 12)),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Image.asset("assets/images/filter.png",
                      color: Colors
                          .grey) /*
          child: Icon(
            Icons.check_box,
            color: Colors.grey,
            size: 18,
          ),*/
                  ),
              title: "Filter Priority",
              titleColor: Colors.white,
              backgroundColor: Colors.transparent,
              onTap: () {
                isAllPlaying = false;
                isAllPlaying3 = false;

                print("indexCheckkkk:${widget.index}");
                print("itemWordList:${widget.itemWordList}");
                print("controllerList:${widget.controllerList}");

                setState(() {});
                log("dohdougdugdugdudjuedfu: ${repeatLoads}");
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordScreen(
                              index: widget.index,
                              itemWordList: widget.itemWordList,
                              controllerList: widget.controllerList,
                              title: "Priority List",
                              load: "",
                              check: true,
                              filterLoad: repeatLoads,
                            ))).then((val) => _getWords(isRefresh: false));
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
              onTap: () {
                print("aall priorityyyy calllleddddd>>>>>>>");
                isAllPlaying = false;
                isAllPlaying3 = false;

                setState(() {});
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordScreen(
                              title: "All Priority List",
                              load: "",
                            ))).then((val) => _getWords(isRefresh: false));
              },
            ),
          ]),
    );
  }
}
