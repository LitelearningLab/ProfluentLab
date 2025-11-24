import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/screens/word_screen/widgets/word_menu.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
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

class _WordScreenState extends State<WordScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
  List<GlobalKey> itemKeys = [];

  late AutoScrollController controller;

  final _audioPlayerManager = AudioPlayerManager();
  bool isMenu = false;
  String selectedMenuOption = "";
  final ScrollController scrollController = ScrollController();
  Future<void> scrollToIndex(int index) async {
    if (!controller.hasClients) return;

    // Get item context
    final context = itemKeys[index].currentContext;
    if (context == null) return;

    final itemBox = context.findRenderObject() as RenderBox;
    final itemPosition = itemBox.localToGlobal(Offset.zero, ancestor: null).dy;
    final itemHeight = itemBox.size.height;

    final viewportHeight = controller.position.viewportDimension;
    final currentOffset = controller.offset;

    final itemTop = itemPosition + currentOffset;
    final itemBottom = itemTop + itemHeight;

    final visibleTop = currentOffset;
    final visibleBottom = currentOffset + viewportHeight;

    final bool isFullyVisible =
        itemTop >= visibleTop && itemBottom <= visibleBottom;

    // Only scroll if needed
    if (!isFullyVisible) {
      await controller.scrollToIndex(
        index,
        preferPosition: AutoScrollPosition.begin,
      );

      // Center a little for nicer UI
      await controller.animateTo(
        controller.offset - viewportHeight * 0.3,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> resetState() async {
    // Smoothly scroll back to the top
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }

    setState(() {});
  }

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
      var response = await http.post(Uri.parse(url),
          body: {"userid": userId, "type": action, "word": word});

      print(
          "response for pronunciation lab report for correct words : ${response.body}");
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
      var response = await http.post(Uri.parse(url), body: {
        "userid": userId,
        "practicetype": practiceType,
        "score": "",
        "action": "practice",
        "successCount": successCount
      });

      print("response end practice : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // startTimerMainCategory("name");
    // subCategoryTitile = widget.title;
    WidgetsBinding.instance.addObserver(this);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

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

          localPath1 = await Utils.downloadFile(userDatas, _words[i].file!,
              '${_words[i].text}.mp3', '$appDocPath/${widget.load}');
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
    bool wordsFirstTime1 =
        prefs.getBool(widget.title.removeAllWhitespace) ?? true;
    print("world ${wordsFirstTime1}");
    setState(() {});
    if (wordsFirstTime1 == true) {
      print("smgojf");
      wordsFirstTime = !wordsFirstTime1;
      setState(() {});
      await addInitialFav();
      await prefs.setBool(widget.title.removeAllWhitespace, false);
      wordsFirstTime =
          await prefs.getBool(widget.title.removeAllWhitespace) ?? false;
      setState(() {});
    } else {
      print("wdfdjgi:${wordsFirstTime}");
      wordsFirstTime = false;
      print("wordsfirstTime:${wordsFirstTime}");
      setState(() {});
    }
    _isLoading = false;
    setState(() {});
  }

  void _getWords({String? searchTerm, required bool isRefresh}) async {
    print("getwordsscalleddddddd>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print("searchTerm: $searchTerm");

    _isLoading = true;
    startTimerMainCategory("name");
    sessionName = widget.title;

    if ((searchTerm == null || searchTerm.isEmpty) && !isRefresh)
      setState(() {});

    _words = [];

    // MAIN FETCH LOGIC
    if (widget.load.isNotEmpty) {
      print("Loading data for category: ${widget.load}");

      if (kIsWeb) {
        // 🟢 WEB MODE — Directly from Firebase (no DB insert)
        print("Running in WEB environment — fetching directly from Firebase");
        final FirebaseDatabase _database = FirebaseDatabase.instance;

        await _database
            .ref(widget.load)
            .orderByValue()
            .once()
            .then((DatabaseEvent snap) {
          var keys = snap.snapshot.children;
          List<Word> tempWords = [];

          for (DataSnapshot key in keys) {
            var data = json.decode(json.encode(key.value));
            Word d = Word()
              ..id = 0
              ..file = data['file'] ?? ""
              ..pronun = data['pronun'] ?? ""
              ..syllables = data['syllables']?.toString() ?? ""
              ..text = data['text']?.toString() ?? ""
              ..cat = widget.load
              ..isFav = 0
              ..isPriority = data['isPriority'] ?? ""
              ..localPath = data['path'] ?? "";

            tempWords.add(d);
          }

          _words = tempWords;
          print("✅ Words fetched from Firebase (web): ${_words.length}");
        });
      } else {
        // 🔵 MOBILE MODE — Local DB + Firebase caching
        print("Running in MOBILE environment — using local DB/Firebase cache");
        _words = await db.getWords(widget.load);
      }

      // Common for both
      isPlaying = List.generate(_words.length, (index) => false.obs);
      itemKeys = List.generate(_words.length, (_) => GlobalKey());

      if (_words.isNotEmpty) {
        print('First local word path: ${_words.first.localPath}');
      }

      await _checkAndPerformInitialFav();
    } else {
      // 🔶 Local Favorites (or offline fallback)
      print("Showing data from local database (favorites, offline, etc.)");

      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
      List<Word> words = await dbRef.getWords();

      isPlaying = List.generate(words.length, (index) => false.obs);
      itemKeys = List.generate(_words.length, (_) => GlobalKey());

      for (Word wr in words) {
        bool matchesFilter = (wr.isFav == 1 && widget.filterLoad == null) ||
            (wr.isFav == 1 && widget.filterLoad == wr.cat);

        if (matchesFilter) {
          _words.add(wr);
          log("${wr.cat}");
          log("${wr.file}");
        }
      }
    }

    // 🔍 Search Filter
    if (searchTerm != null && searchTerm.isNotEmpty) {
      _words = _words
          .where((element) =>
              element.text!.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    // 🎯 Auto-scroll & UI update
    if (widget.word != null) _selectedWordOnClick = widget.word?.id;
    _isLoading = false;

    if (widget.word != null) {
      await controller.scrollToIndex(
        _words.indexWhere((element) => element.text == widget.word?.id),
        preferPosition: AutoScrollPosition.begin,
      );
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
        padding: EdgeInsets.only(bottom: 5, left: 0),
        child: TextField(
          controller: _searchQueryController,
          autofocus: true,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
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
    if (!isMenu) {
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flexible(
            //   child: Text(
            //     widget.title,
            //     maxLines: 1,
            //     style: TextStyle(
            //       fontFamily: Keys.fontFamily,
            //       fontSize: globalFontSize(18, context),
            //       color: Colors.white,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
            // Spacer(),
            // kIsWeb
            //     ? Spacer()
            //     : SizedBox(
            //         width: 5,
            //       ),
            SizedBox(
              width: getWidgetWidth(width: 25),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  isAllPlaying = false;
                  setState(() {
                    closePlay1StopDialog = true;
                    openPlay3StopDialog = true;
                    closePlay3StopDialog = false;
                    _isPaused3 = false;
                    _currentIndex3 = 0;
                  });
                  _playAll3Times();
                },
                icon: Image.asset(
                  AllAssets.playThree,
                  height: 35,
                  // width: 25,
                ),
              ),
            ),
            SizedBox(
              width: getWidgetWidth(width: 20),
            ),
            SizedBox(
              width: getWidgetWidth(width: 25),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
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
                icon: Image.asset(
                  AllAssets.playOne,
                  height: 35,
                  // width: 25,
                ),
              ),
            ),
            SizedBox(
              width: getWidgetWidth(width: 20),
            ),
          ],
        ),
        SizedBox(
          width: getWidgetWidth(width: 30),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: Colors.white,
            onSelected: (value) {
              isAllPlaying3 = false;
              // setState(() {
              closePlay3StopDialog = true;
              openPlay1StopDialog = true;
              closePlay1StopDialog = false;
              _isPaused = false;
              _currentIndex = 0;
              switchingKey = true;
              print("swithchingKey:${switchingKey}");
              // });
              isAllPlaying = false;
              // setState(() {
              closePlay1StopDialog = true;
              openPlay3StopDialog = true;
              closePlay3StopDialog = false;
              _isPaused3 = false;
              _currentIndex3 = 0;
              // });
              selectedMenuOption = value;

              if (value == 'all_priority') {
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
              } else if (value == 'unlisted') {
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
              } else if (value == 'priority') {
                // controller.applyDownloadedFilter(true);
                Navigator.push(
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
              } else if (value == 'clear') {
                if (widget.title == "Priority List") {
                  Navigator.pop(context);
                } else if (_isSearching) {
                  _isSearching = false;
                  _getWords(searchTerm: "", isRefresh: false);
                  setState(() {});
                }
                // controller.applyDownloadedFilter(false);
              } else if (value == 'search') {
                _isSearching = true;
              }
              setState(() {});
              // controller.update();
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'search',
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontWeight:
                        //  selectedMenuOption == 'search'
                        //     ? FontWeight.w600
                        //     :
                        FontWeight.normal,
                    color:
                        //  selectedMenuOption == 'search'
                        //     ? Colors.black
                        //     :
                        Colors.grey[800],
                  ),
                ),
              ),
              if (!kIsWeb)
                PopupMenuItem<String>(
                  value: 'priority',
                  child: Text(
                    'Filter Priority',
                    style: TextStyle(
                      fontWeight: widget.title == "Priority List"
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: widget.title == "Priority List"
                          ? Colors.black
                          : Colors.grey[800],
                    ),
                  ),
                ),
              // if (!kIsWeb)
              //   PopupMenuItem<String>(
              //     value: 'all_priority',
              //     child: Text(
              //       'All Filter Priority',
              //       style: TextStyle(
              //         fontWeight:
              //             // controller.selectedMenuOption == 'priority'
              //             //     ? FontWeight.w600
              //             //     :
              //             FontWeight.normal,
              //         color:
              //             //  controller.selectedMenuOption == 'priority'
              //             //     ? Colors.black
              //             // :
              //             Colors.grey[800],
              //       ),
              //     ),
              //   ),
              if (!kIsWeb)
                PopupMenuItem<String>(
                  value: 'unlisted',
                  child: Text(
                    'Try Unlisted Words',
                    style: TextStyle(
                      fontWeight:
                          // controller.selectedMenuOption == 'priority'
                          //     ? FontWeight.w600
                          //     :
                          FontWeight.normal,
                      color:
                          //  controller.selectedMenuOption == 'priority'
                          //     ? Colors.black
                          // :
                          Colors.grey[800],
                    ),
                  ),
                ),
              if (!kIsWeb)
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text(
                    'Clear Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Spacer(),
        // IconButton(
        //   icon: Icon(Icons.search_rounded, color: Colors.white),
        //   onPressed: () {
        //     if (_searchQueryController.text.isEmpty) {
        //       Navigator.pop(context);
        //       return;
        //     }
        //     _getWords(
        //         searchTerm: _searchQueryController.text, isRefresh: false);
        //   },
        // ),
        // SPW(displayWidth(context) / 37.5)
      ];
    }

    return <Widget>[
      if (widget.title.trim() == "Priority List" && !isAllPlaying3 ||
          widget.title.trim() == "All Priority List" && !isAllPlaying3)
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
      if (widget.title.trim() == "Priority List" && isAllPlaying3 ||
          widget.title.trim() == "All Priority List" && isAllPlaying3)
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
      if (widget.title.trim() == "Priority List" && !isAllPlaying ||
          widget.title.trim() == "All Priority List" && !isAllPlaying)
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
      if (widget.title.trim() == "Priority List" && isAllPlaying ||
          widget.title.trim() == "All Priority List" && isAllPlaying)
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
      // IconButton(
      //   icon: Icon(Icons.menu, color: Colors.white),
      //   onPressed: _startSearch,
      // ),
      SPW(displayWidth(context) / 37.5)
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        ?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
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
      if (value != null && value.isCorrect == "true" ||
          value.isCorrect == "false") {
        print("checkkkkkkkkkkkkkk");
        _selectedWord = word;
        _isCorrect = value.isCorrect == "true" ? true : false;
        print("correct or wrong:${_isCorrect}");
        //value.isCorrect ? pronunciationLabReport(actionType: "correct", word: widget.word) : "";
        print("isCorrecttt:${_isCorrect}");
        setState(() {
          print('wordddddddd: ${word}');
          print("valueIsCorrect: ${_isCorrect}");
          _isCorrect
              ? pronunciationLabReport(actionType: "correct", word: word)
              : "";
          _isCorrect
              ? endPractice(
                  practiceType: "Pronunciation Sound Lab Report",
                  successCount: "correct")
              : endPractice(
                  practiceType: "Pronunciation Sound Lab Report",
                  successCount: "wrong");
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
      _selectedWordOnClick = _words[i].text;
      print("selected word on click ${_selectedWordOnClick == _words[i].text}");
      setState(() {});
      if (_isPaused) {
        _currentIndex = i;
        print("Paused at index: $_currentIndex");
        break; // Exit the loop if paused
      }

      if (isAllPlaying &&
          _words[i].file != null &&
          _words[i].file!.isNotEmpty) {
        _words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});
        if (kIsWeb) {
          // 🌐 WEB MODE — Stream directly, no local file access
          print("WEB MODE: Streaming audio directly from URL");
          await audioPlayerManager.play(
            _words[i].file!,
            context: context,
            decodedPath: null, // skip decoded path on web
          );
        } else
          await _audioPlayerManager.play(_words[i].file!,
              context: context,
              localPath: _words[i].localPath, decodedPath: (val) {
            eLocalPath = val;
          });

        await Future.delayed(Duration(seconds: 3));
        _words[i].isPlaying = false;
        isPlaying[i].value = false;

        if (eLocalPath != null && eLocalPath!.isNotEmpty) {
          try {
            File(eLocalPath!).delete();
          } catch (e) {}
        }
        String company = await SharedPref.getSavedString("companyId");
        String batch = await SharedPref.getSavedString("batch");
        _firestore.saveWordListReport(
          companyId: company,
          batch: batch,
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
      scrollToIndex(i);

      // setState(() {});
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
    log("▶ PLAY ALL (3 times) started");

    _isPaused3 = false;
    audioLoading = false;
    isAllPlaying3 = true;

    AuthState user = Provider.of<AuthState>(context, listen: false);

    // Reset UI flags
    isPlaying = List.generate(_words.length, (_) => false.obs);
    setState(() {});

    String? decodedPath;

    // Loop through words from current index
    for (int i = _currentIndex3; i < _words.length; i++) {
      if (!isAllPlaying3) break;

      // Skip if no file
      if (_words[i].file == null || _words[i].file!.isEmpty) continue;

      // Play each word 3 times
      for (int playCount = _currentPlayCount3; playCount < 3; playCount++) {
        // Handle STOP or PAUSE
        if (!isAllPlaying3 || _isPaused3) {
          _currentIndex3 = i;
          _currentPlayCount3 = playCount;
          log("⏸ Paused at index: $i, count: $playCount");
          return;
        }

        log("🎵 Playing $i (repeat ${playCount + 1}/3)");

        // Update UI
        _words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});

        // Play audio
        await _audioPlayerManager.play3(
          _words[i].file!,
          context: context,
          localPath: _words[i].localPath,
          decodedPath: (val) => decodedPath = val,
        );

        // Small delay after each play
        await Future.delayed(const Duration(seconds: 2));

        // Stop UI animation
        _words[i].isPlaying = false;
        isPlaying[i].value = false;

        // Delete temporary file
        if (decodedPath != null && decodedPath!.isNotEmpty) {
          try {
            await File(decodedPath!).delete();
          } catch (e) {
            log("⚠ Failed to delete temp file: $e");
          }
        }

        // Save report
        await _savePracticeReport(user);
      }
      scrollToIndex(i);
      _currentPlayCount3 = 0;
      setState(() {}); // reset for next word
    }

    // Completed all words
    if (!_isPaused3) {
      _currentIndex3 = _words.length - 1;
      _currentPlayCount3 = 0;
      isAllPlaying3 = false;

      if (_currentIndex3 == _words.length - 1) {
        closePlay3StopDialog = true;
        log("✔ Completed all three-round plays");
      }

      setState(() {});
    }
  }

  Future<void> _savePracticeReport(AuthState user) async {
    String company = await SharedPref.getSavedString("companyId");
    String batch = await SharedPref.getSavedString("batch");

    await _firestore.saveWordListReport(
      companyId: company,
      batch: batch,
      isPractice: false,
      company: user.appUser!.company!,
      name: user.appUser!.UserMname,
      userID: user.appUser!.id!,
      word: widget.title,
      team: user.appUser!.team,
      userprofile: user.appUser!.profile,
      city: user.appUser!.city,
      load: widget.load,
      title: widget.title,
      time: 1,
      date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
    );
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
    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerMainCategory();
      },
      child: BackgroundWidget(
        appBar: AppBar(
          actionsPadding: EdgeInsets.zero,
          backgroundColor: const Color(0xFF324265),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.arrow_back),
            onPressed: () {
              isAllPlaying3 = false;
              // setState(() {
              closePlay3StopDialog = true;
              openPlay1StopDialog = true;
              closePlay1StopDialog = false;
              _isPaused = false;
              _currentIndex = 0;
              switchingKey = true;
              print("swithchingKey:${switchingKey}");
              // });
              isAllPlaying = false;
              // setState(() {
              closePlay1StopDialog = true;
              openPlay3StopDialog = true;
              closePlay3StopDialog = false;
              _isPaused3 = false;
              _currentIndex3 = 0;
              if (_isSearching) {
                _isSearching = false;
                _getWords(searchTerm: "", isRefresh: false);
                setState(() {});
              } else {
                stopTimerMainCategory();
                print("back button pressed");

                if (widget.check == null) {
                  Navigator.pop(context);
                } else if (widget.check!) {
                  Navigator.pop(context);
                } else if (widget.check == false &&
                    widget.backButtonCheck == true) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                }
              }
            },
          ),
          title: !_isSearching
              ? Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: Keys.fontFamily,
                    fontSize: globalFontSize(kIsWeb ? 18 : 16, context),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : _buildSearchField(),
          centerTitle: false,
          actions: _buildActions(),
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
                            style: TextStyle(
                                color: AppColors.white,
                                fontFamily: Keys.fontFamily),
                          ),
                        ),
                      ),
                      Container(
                        height: isSplitScreen
                            ? getFullWidgetHeight(height: 60)
                            : getWidgetHeight(height: 60),
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
                                  color:
                                      context.read<AuthState>().currentIndex ==
                                              0
                                          ? Color(0xFFAAAAAA)
                                          : Color.fromARGB(132, 170, 170, 170),
                                ),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(0);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            1
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(1);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            2
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(2);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            3
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(3);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                            IconButton(
                                icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
                                            4
                                        ? Color(0xFFAAAAAA)
                                        : Color.fromARGB(132, 170, 170, 170)),
                                onPressed: () {
                                  context.read<AuthState>().changeIndex(4);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BottomNavigation()));
                                }),
                          ],
                        ),
                      )
                    ],
                  )
                : _isLoading
                    ? !wordsFirstTime && !kIsWeb
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "This may take a couple of minutes \n(only during the first time).",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  "Please stay on this page, do \nnot go back or close the app.",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 15),
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
                                    padding: EdgeInsets.only(
                                        top: isSplitScreen
                                            ? getFullWidgetHeight(height: 10)
                                            : getWidgetHeight(height: 10)),
                                    itemCount: _words.length,
                                    controller: scrollController,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (!isAllPlaying && !isAllPlaying3) {
                                        print(
                                            "listWordLength:${_words.length}");
                                        print("dfjusfeiujfejdsfj");
                                        print(
                                            "currentIndex : ${_currentIndex}");
                                        print(
                                            "wordLengthIndex:${_words.length - 1}");
                                        isPlaying = List.generate(_words.length,
                                            (index) => false.obs);

                                        /* if (_currentIndex == _words.length - 1) {
                                            print("sucessss>>>>>>>>>>>>>>>>>>");
                                            closePlay1StopDialog = true;
                                          }*/
                                        //_getWords(isRefresh: false);
                                      }

                                      return AutoScrollTag(
                                        key: itemKeys[index],
                                        controller: controller,
                                        index: index,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: index == _words.length - 1
                                                  ? isSplitScreen
                                                      ? getFullWidgetHeight(
                                                          height: 60)
                                                      : getWidgetHeight(
                                                          height: 60)
                                                  : 0),
                                          child: Container(
                                            key: itemKeys[index],
                                            child: DropDownWordItem(
                                              localPath:
                                                  _words[index].localPath,
                                              load: widget.load,
                                              length: _words.length,
                                              index: index,
                                              // isPlaying: _words[index].isPlaying,
                                              isDownloaded:
                                                  (_words[index].localPath !=
                                                          null &&
                                                      _words[index]
                                                          .localPath!
                                                          .isNotEmpty),
                                              maintitle: widget.title,
                                              onExpansionChanged: (val) {
                                                print(
                                                    "check1111111111111111111111111444>");
                                                print(
                                                    "djfdjfihdifhidfid:${_words[index].localPath}");
                                                setState(() {
                                                  _selectedWord = '';
                                                });
                                                if (val) {
                                                  _selectedWordOnClick =
                                                      _words[index].text;
                                                  print(
                                                      "sajidjg:${_words[index].text}");
                                                  setState(() {});
                                                  if (_words.length - 2 <=
                                                      index) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      // _scrollToItem(index);
                                                    });
                                                  }
                                                }
                                              },
                                              initiallyExpanded:
                                                  _selectedWordOnClick !=
                                                          null &&
                                                      _selectedWordOnClick ==
                                                          _words[index].text,
                                              isWord: true,
                                              isRefresh: (val) {
                                                if (val)
                                                  _getWords(isRefresh: true);
                                              },
                                              // words: _words,
                                              wordId: _words[index].id!,
                                              isFav: _words[index].isFav!,
                                              title: _words[index].text!,
                                              url: _words[index].file,
                                              onTapForThreePlayerStop:
                                                  updateThreePlayerFlag,
                                              children: [
                                                WordMenu(
                                                  pronun: _words[index].pronun!,
                                                  selectedWord: _selectedWord,
                                                  isCorrect: _selectedWord ==
                                                          _words[index].text &&
                                                      _isCorrect,
                                                  text: _words[index].text!,
                                                  syllables:
                                                      _words[index].syllables!,
                                                  onTapHeadphone: () async {},
                                                  url: _words[index].file,
                                                  onTapMic: () async {
                                                    _showDialog(
                                                        _words[index].text!,
                                                        false,
                                                        context);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                openPlay3StopDialog && !closePlay3StopDialog
                                    ? Positioned(
                                        right: kIsWeb
                                            ? displayWidth(context) / 3
                                            : 120,
                                        top: 5,
                                        child: Container(
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 45)
                                              : getWidgetHeight(height: 45),
                                          width: getWidgetWidth(width: 108),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, top: 5),
                                                child: Image.asset(
                                                  "assets/images/Play_thrice_icon.png",
                                                  // height: 30,
                                                  width: 30,
                                                ),
                                              ),
                                              !isAllPlaying3
                                                  ? audioLoading
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Color(
                                                                  0XFF34425D),
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            resumeAll3();
                                                          },
                                                          child: Icon(
                                                              Icons.play_arrow,
                                                              color: Color(
                                                                  0XFF34425D),
                                                              size: 30))
                                                  : audioLoading
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color: Color(
                                                                  0XFF34425D),
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            pauseAll3();
                                                          },
                                                          child: Icon(
                                                              Icons.pause,
                                                              color: Color(
                                                                  0XFF34425D),
                                                              size: 30)),
                                              IconButton(
                                                  onPressed: () {
                                                    _audioPlayerManager.stop();
                                                    isAllPlaying3 = false;
                                                    setState(() {
                                                      openPlay3StopDialog =
                                                          false;
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
                                    : openPlay1StopDialog &&
                                            !closePlay1StopDialog
                                        ? Positioned(
                                            right: kIsWeb
                                                ? displayWidth(context) / 3
                                                : 120,
                                            top: 5,
                                            child: Container(
                                              height: isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 45)
                                                  : getWidgetHeight(height: 45),
                                              width: getWidgetWidth(width: 108),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8, top: 5),
                                                    child: Image.asset(
                                                      "assets/images/Play_once_icon.png",
                                                      // height: 15,
                                                      width: 30,
                                                    ),
                                                  ),
                                                  _isPaused
                                                      ? audioLoading
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Color(
                                                                      0XFF34425D),
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                print(
                                                                    "checkkkkkkkkk11");
                                                                resumeAll();
                                                              },
                                                              child: Icon(Icons.play_arrow,
                                                                  color: Color(
                                                                      0XFF34425D),
                                                                  size: 30))
                                                      : audioLoading
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: SizedBox(
                                                                height: 20,
                                                                width: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Color(
                                                                      0XFF34425D),
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                              ),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                print(
                                                                    "checkkk222");
                                                                pauseAll();
                                                              },
                                                              child: Icon(
                                                                Icons.pause,
                                                                color: Color(
                                                                    0XFF34425D),
                                                                size: 30,
                                                              )),
                                                  InkWell(
                                                      onTap: () {
                                                        _audioPlayerManager
                                                            .stop();
                                                        isAllPlaying = false;
                                                        setState(() {
                                                          openPlay1StopDialog =
                                                              false;
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.stop,
                                                        color:
                                                            Color(0XFF34425D),
                                                        size: 30,
                                                      )),
                                                ],
                                              ),
                                            ))
                                        : SizedBox()
                              ],
                            ),
                          ),
                          if (!_isSearching)
                            Container(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 60)
                                  : getWidgetHeight(height: 60),
                              width: kWidth,
                              decoration: BoxDecoration(
                                color: Color(0xFF34445F),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      icon: ImageIcon(
                                        AssetImage(AllAssets.bottomHome),
                                        color: context
                                                    .read<AuthState>()
                                                    .currentIndex ==
                                                0
                                            ? Color(0xFFAAAAAA)
                                            : Color.fromARGB(
                                                132, 170, 170, 170),
                                      ),
                                      onPressed: () {
                                        context
                                            .read<AuthState>()
                                            .changeIndex(0);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                      }),
                                  IconButton(
                                      icon: ImageIcon(
                                          AssetImage(AllAssets.bottomPL),
                                          color: context
                                                      .read<AuthState>()
                                                      .currentIndex ==
                                                  1
                                              ? Color(0xFFAAAAAA)
                                              : Color.fromARGB(
                                                  132, 170, 170, 170)),
                                      onPressed: () {
                                        context
                                            .read<AuthState>()
                                            .changeIndex(1);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                      }),
                                  IconButton(
                                      icon: ImageIcon(
                                          AssetImage(AllAssets.bottomIS),
                                          color: context
                                                      .read<AuthState>()
                                                      .currentIndex ==
                                                  2
                                              ? Color(0xFFAAAAAA)
                                              : Color.fromARGB(
                                                  132, 170, 170, 170)),
                                      onPressed: () {
                                        context
                                            .read<AuthState>()
                                            .changeIndex(2);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                      }),
                                  IconButton(
                                      icon: ImageIcon(
                                          AssetImage(AllAssets.bottomPE),
                                          color: context
                                                      .read<AuthState>()
                                                      .currentIndex ==
                                                  3
                                              ? Color(0xFFAAAAAA)
                                              : Color.fromARGB(
                                                  132, 170, 170, 170)),
                                      onPressed: () {
                                        context
                                            .read<AuthState>()
                                            .changeIndex(3);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                      }),
                                  IconButton(
                                      icon: ImageIcon(
                                          AssetImage(AllAssets.bottomPT),
                                          color: context
                                                      .read<AuthState>()
                                                      .currentIndex ==
                                                  4
                                              ? Color(0xFFAAAAAA)
                                              : Color.fromARGB(
                                                  132, 170, 170, 170)),
                                      onPressed: () {
                                        context
                                            .read<AuthState>()
                                            .changeIndex(4);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigation()));
                                      }),
                                ],
                              ),
                            )
                        ],
                      ),
        // floatingActionButton:
        //     _isLoading || _isSearching ? SizedBox() : buildBoomMenu(),
      ),
    );
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
                    horizontal: getWidgetWidth(width: 12),
                    vertical: isSplitScreen
                        ? getFullWidgetHeight(height: 12)
                        : getWidgetHeight(height: 12)),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(
                  Icons.home,
                  color: Colors.grey,
                  size: isSplitScreen
                      ? getFullWidgetHeight(height: 18)
                      : getWidgetHeight(height: 18),
                ),
              ),
              title: "Home",
              titleColor: Colors.white,
              backgroundColor: Color(0x00000000),
              onTap: () {
                context.read<AuthState>().changeIndex(0);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomNavigation()));
              },
            ),
            if (!kIsWeb)
              bm.MenuItem(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 12),
                      vertical: isSplitScreen
                          ? getFullWidgetHeight(height: 12)
                          : getWidgetHeight(height: 12)),
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    Icons.keyboard,
                    color: Colors.grey,
                    size: isSplitScreen
                        ? getFullWidgetHeight(height: 18)
                        : getWidgetHeight(height: 18),
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
            if (!kIsWeb)
              bm.MenuItem(
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: getWidgetWidth(width: 12),
                        vertical: isSplitScreen
                            ? getFullWidgetHeight(height: 12)
                            : getWidgetHeight(height: 12)),
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
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
            if (!kIsWeb)
              bm.MenuItem(
                child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Image.asset("assets/images/filter_all.png",
                        color: Colors.grey)),
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
