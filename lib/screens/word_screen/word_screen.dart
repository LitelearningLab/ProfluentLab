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
import 'package:wakelock_plus/wakelock_plus.dart';

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
  List<GlobalKey<AppExpansionTileState>> wordTileKeys = [];

  // List<GlobalKey> itemKeys = [];

  late AutoScrollController controller;

  final _audioPlayerManager = AudioPlayerManager();
  bool isMenu = false;
  String selectedMenuOption = "";
  final AutoScrollController scrollController = AutoScrollController();
  Future<void> scrollToIndex(int index) async {
    if (!controller.hasClients) return;

    // Get item context
    // final context = itemKeys[index].currentContext;
    // if (context == null) return;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (controller.hasClients) {
        await controller.animateTo(
          controller.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }

      if (mounted) setState(() {});
    });
  }

  pronunciationLabReport({required actionType, required word}) async {
    String userId = await SharedPref.getSavedString('userId');
    String action = actionType;
    String url = baseUrl + pronunciationLabReportApi;
    try {
      var response = await http.post(Uri.parse(url),
          body: {"userid": userId, "type": action, "word": word});
    } catch (e) {
      print("error login : $e");
    }
  }

  endPractice({required practiceType, required successCount}) async {
    String userId = await SharedPref.getSavedString('userId');

    String url = baseUrl + endPracticeApi;

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
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    await dbRef.setFav(word.id!, 1, eLocalPath1!);
    setState(() {
      word.isFav = 1;
    });
  }

  Future<void> addInitialFav() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String? localPath1;
      String? eLocalPath1;
      for (var i = 0; i < _words.length; i++) {
        if (_words[i].isPriority == "true") {
          AuthState userDatas = Provider.of<AuthState>(context, listen: false);

          localPath1 = await Utils.downloadFile(userDatas, _words[i].file!,
              '${_words[i].text}.mp3', '$appDocPath/${widget.load}');
          eLocalPath1 = EncryptData.encryptFile(localPath1, userDatas);

          _words[i].localPath = eLocalPath1;

          try {
            await File(localPath1).delete();
          } catch (e) {}
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

    setState(() {});
    if (wordsFirstTime1 == true) {
      wordsFirstTime = !wordsFirstTime1;
      setState(() {});
      await addInitialFav();
      await prefs.setBool(widget.title.removeAllWhitespace, false);
      wordsFirstTime =
          await prefs.getBool(widget.title.removeAllWhitespace) ?? false;
      setState(() {});
    } else {
      wordsFirstTime = false;
      setState(() {});
    }
    _isLoading = false;
    setState(() {});
  }

  void _getWords({String? searchTerm, required bool isRefresh}) async {
    _isLoading = true;
    startTimerMainCategory("name");
    sessionName = widget.title;

    if ((searchTerm == null || searchTerm.isEmpty) && !isRefresh)
      setState(() {});

    _words = [];

    // MAIN FETCH LOGIC
    if (widget.load.isNotEmpty) {
      if (kIsWeb) {
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
        });
      } else {
        _words = await db.getWords(widget.load);
      }

      // Common for both
      isPlaying = List.generate(_words.length, (index) => false.obs);
      wordTileKeys = List.generate(
        _words.length,
        (index) => GlobalKey<AppExpansionTileState>(),
      );

      // itemKeys = List.generate(_words.length, (_) => GlobalKey());

      await _checkAndPerformInitialFav();
    } else {
      // 🔶 Local Favorites (or offline fallback)

      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
      List<Word> words = await dbRef.getWords();

      isPlaying = List.generate(words.length, (index) => false.obs);
      // itemKeys = List.generate(_words.length, (_) => GlobalKey());

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
            SizedBox(
              width: getWidgetWidth(width: 25),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: isAllPlaying || isAllPlaying3
                    ? () {}
                    : () {
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
                onPressed: isAllPlaying3 || isAllPlaying
                    ? () {}
                    : () {
                        isAllPlaying3 = false;
                        setState(() {
                          closePlay3StopDialog = true;
                          openPlay1StopDialog = true;
                          closePlay1StopDialog = false;
                          _isPaused = false;
                          _currentIndex = 0;
                          switchingKey = true;
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
              closePlay1StopDialog = true;
              _isPaused = false;
              _currentIndex = 0;
              switchingKey = true;
              // });
              isAllPlaying = false;
              // setState(() {
              closePlay1StopDialog = true;
              openPlay3StopDialog = true;
              closePlay3StopDialog = true;
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
                onPressed: () {},
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
                  setState(() {});
                },
              ),
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

  Future<void> _scrollToItem(int index) async {
    if (!scrollController.hasClients) return;

    final keyContext = wordTileKeys[index].currentContext;
    if (keyContext == null) return;

    await Scrollable.ensureVisible(
      keyContext,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      alignment: 0.5, // keep above center
    );
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
        _selectedWord = word;
        _isCorrect = value.isCorrect == "true" ? true : false;

        //value.isCorrect ? pronunciationLabReport(actionType: "correct", word: widget.word) : "";

        setState(() {
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
        _showDialog(word, true, context);
      } else if (value != null && value.isCorrect == "openDialog") {
        _showDialog(word, false, context);
      }
    }).onError((error, stackTrace) {
      log(error.toString());
    });
  }

  void _playAll() async {
    if (isAllPlaying3) {
      return;
    }
    await WakelockPlus.enable();
    _isPaused = false;
    isAllPlaying = true;
    audioLoading = false;
    String? eLocalPath;
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    // setState(() {});
    isPlaying = List.generate(_words.length, (index) => false.obs);
    wordTileKeys = List.generate(
      _words.length,
      (index) => GlobalKey<AppExpansionTileState>(),
    );

    // itemKeys = List.generate(_words.length, (_) => GlobalKey());
    // setState(() {});

    for (int i = _currentIndex; i < _words.length; i++) {
      await Future.delayed(Duration(seconds: 1));
      if (_isPaused) {
        _currentIndex = i;
        break; // Exit the loop if paused
      }
      if (!isAllPlaying) {
        break;
      }
      _selectedWordOnClick = _words[i].text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wordTileKeys[i].currentState?.expand();
        _scrollToItem(i);
      });
      // }
      // setState(() {});

      if (isAllPlaying &&
          _words[i].file != null &&
          _words[i].file!.isNotEmpty) {
        _words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});
        if (kIsWeb) {
          await audioPlayerManager.play(
            _words[i].file!,
            context: context,
            decodedPath: null, // skip decoded path on web
          );
        } else {
          await _audioPlayerManager.play(_words[i].file!,
              context: context,
              localPath: _words[i].localPath, decodedPath: (val) {
            eLocalPath = val;
          });
        }

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
      // scrollToIndex(i);

      // setState(() {});
    }
    if (!_isPaused) {
      _currentIndex = _words.length - 1;
      // _currentIndex = 0;
      isAllPlaying = false;
      if (_currentIndex == _words.length - 1) {
        closePlay1StopDialog = true;
      }
    }
    await resetState();
    await WakelockPlus.disable();
    setState(() {});
  }

  void pauseAll() {
    if (isAllPlaying) {
      _audioPlayerManager.pause();
      setState(() {
        _isPaused = true;
      });
      isAllPlaying = false;
    }
  }

  void resumeAll() async {
    if (_isPaused) {
      audioLoading = true;
      setState(() {});
      await Future.delayed(Duration(seconds: 2));

      _audioPlayerManager.resume();

      _playAll();
    }
  }

  void _playAll3Times() async {
    _isPaused3 = false;
    audioLoading = false;
    isAllPlaying3 = true;
    await WakelockPlus.enable();

    AuthState user = Provider.of<AuthState>(context, listen: false);

    // Reset UI flags
    isPlaying = List.generate(_words.length, (_) => false.obs);
    wordTileKeys = List.generate(
      _words.length,
      (index) => GlobalKey<AppExpansionTileState>(),
    );

    setState(() {});

    String? decodedPath;

    // Loop through words from current index
    for (int i = _currentIndex3; i < _words.length; i++) {
      if (!isAllPlaying3) break;
      _selectedWordOnClick = _words[i].text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wordTileKeys[i].currentState?.expand();
        _scrollToItem(i);
      });
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
        if (kIsWeb) {
          await audioPlayerManager.play3(
            _words[i].file!,
            context: context,
            decodedPath: null,
          );
        } else {
          await _audioPlayerManager.play3(
            _words[i].file!,
            context: context,
            localPath: _words[i].localPath,
            decodedPath: (val) => decodedPath = val,
          );
        }
        // Play audio

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
      setState(() {});
    }

    if (!_isPaused3) {
      _currentIndex3 = _words.length - 1;
      _currentPlayCount3 = 0;
      isAllPlaying3 = false;

      if (_currentIndex3 == _words.length - 1) {
        closePlay3StopDialog = true;
        log("✔ Completed all three-round plays");
      }
    }
    await resetState();
    await WakelockPlus.disable();
    setState(() {});
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

      _audioPlayerManager.resume();

      _playAll3Times();
    }
  }

  updateThreePlayerFlag() {
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
            icon: Icon(
                _isSearching ? Icons.close : Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              isAllPlaying3 = false;
              // setState(() {
              closePlay3StopDialog = false;
              openPlay1StopDialog = false;
              closePlay1StopDialog = false;
              _isPaused = false;
              _currentIndex = 0;
              switchingKey = true;
              // });
              isAllPlaying = false;
              // setState(() {
              closePlay1StopDialog = false;
              openPlay3StopDialog = false;
              closePlay3StopDialog = false;
              _isPaused3 = false;
              _currentIndex3 = 0;
              if (_isSearching) {
                _isSearching = false;
                _getWords(searchTerm: "", isRefresh: false);
                setState(() {});
              } else {
                stopTimerMainCategory();

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
        body: _words.length == 0 && !_isLoading
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
                              color: context.read<AuthState>().currentIndex == 0
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
                                color:
                                    context.read<AuthState>().currentIndex == 1
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
                                color:
                                    context.read<AuthState>().currentIndex == 2
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
                                color:
                                    context.read<AuthState>().currentIndex == 3
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
                                color:
                                    context.read<AuthState>().currentIndex == 4
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
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
                                padding: EdgeInsets.only(
                                    top: isSplitScreen
                                        ? getFullWidgetHeight(height: 10)
                                        : getWidgetHeight(height: 10)),
                                itemCount: _words.length,
                                controller: scrollController,
                                itemBuilder: (BuildContext context, int index) {
                                  if (!isAllPlaying && !isAllPlaying3) {
                                    isPlaying = List.generate(
                                        _words.length, (index) => false.obs);
                                  }

                                  return AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: controller,
                                    index: index,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: index == _words.length - 1
                                              ? isSplitScreen
                                                  ? getFullWidgetHeight(
                                                      height: 60)
                                                  : getWidgetHeight(height: 60)
                                              : 0),
                                      child: Container(
                                        // key: itemKeys[index],
                                        child: DropDownWordItem(
                                          key: wordTileKeys[index],
                                          localPath: _words[index].localPath,
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
                                            setState(() {
                                              _selectedWord = '';
                                            });
                                            if (val) {
                                              _selectedWordOnClick =
                                                  _words[index].text;
                                              setState(() {});
                                              if (_words.length - 2 <= index) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  // _scrollToItem(index);
                                                });
                                              }
                                            }
                                          },
                                          initiallyExpanded:
                                              _selectedWordOnClick != null &&
                                                  _selectedWordOnClick ==
                                                      _words[index].text,
                                          isWord: true,
                                          isRefresh: (val) {
                                            if (val) _getWords(isRefresh: true);
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
                                                _showDialog(_words[index].text!,
                                                    false, context);
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
                                        : 105,
                                    top: 5,
                                    child: Container(
                                      height: isSplitScreen
                                          ? getFullWidgetHeight(height: 45)
                                          : getWidgetHeight(height: 45),
                                      width: !kIsWeb
                                          ? getWidgetWidth(width: 150)
                                          : getWidgetWidth(width: 108),
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
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              Color(0XFF34425D),
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
                                                          color:
                                                              Color(0XFF34425D),
                                                          size: 30))
                                              : audioLoading
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color:
                                                              Color(0XFF34425D),
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        pauseAll3();
                                                      },
                                                      child: Icon(Icons.pause,
                                                          color:
                                                              Color(0XFF34425D),
                                                          size: 30)),
                                          IconButton(
                                              onPressed: () async {
                                                _audioPlayerManager.stop();
                                                isAllPlaying3 = false;
                                                setState(() {
                                                  openPlay3StopDialog = false;
                                                });
                                                resetState();
                                                await WakelockPlus.disable();
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
                                        right: kIsWeb
                                            ? displayWidth(context) / 3
                                            : 105,
                                        top: 5,
                                        child: Container(
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 45)
                                              : getWidgetHeight(height: 45),
                                          width: !kIsWeb
                                              ? getWidgetWidth(width: 150)
                                              : getWidgetWidth(width: 108),
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
                                                              strokeWidth: 2,
                                                            ),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            resumeAll();
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
                                                            pauseAll();
                                                          },
                                                          child: Icon(
                                                            Icons.pause,
                                                            color: Color(
                                                                0XFF34425D),
                                                            size: 30,
                                                          )),
                                              InkWell(
                                                  onTap: () async {
                                                    _audioPlayerManager.stop();
                                                    isAllPlaying = false;
                                                    setState(() {
                                                      openPlay1StopDialog =
                                                          false;
                                                      resetState();
                                                    });
                                                    await WakelockPlus.enable();
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  icon: ImageIcon(
                                    AssetImage(AllAssets.bottomHome),
                                    color: context
                                                .read<AuthState>()
                                                .currentIndex ==
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPL),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomIS),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPE),
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
                                  icon: ImageIcon(
                                      AssetImage(AllAssets.bottomPT),
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
                        color: Colors.grey)),
                title: "Filter Priority",
                titleColor: Colors.white,
                backgroundColor: Colors.transparent,
                onTap: () {
                  isAllPlaying = false;
                  isAllPlaying3 = false;

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
