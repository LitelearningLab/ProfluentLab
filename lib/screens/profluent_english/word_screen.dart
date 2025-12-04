import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/boom_menu.dart';
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
import 'package:litelearninglab/screens/profluent_english/profluent_sub_screen.dart';
import 'package:litelearninglab/screens/profluent_english/widgets/dropdown_word_item_word_screen.dart';
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart'
    hide audioPlayerManager;
import 'package:litelearninglab/screens/word_screen/widgets/word_menu.dart';
// import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/FirestoreService.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:litelearninglab/common_widgets/boom_menu_item.dart' as bm;

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'new_profluent_english_screen.dart';

class WordScreenProfluentEnglish extends StatefulWidget {
  const WordScreenProfluentEnglish({
    Key? key,
    required this.title,
    required this.load,
    this.word,
    this.filterLoad,
    required this.soundPractice,
  }) : super(key: key);
  final String title;
  final String load;
  final ProLab? word;
  final String? filterLoad;
  final List<Word> soundPractice;

  @override
  State<WordScreenProfluentEnglish> createState() =>
      _WordScreenProfluentEnglishState();
}

class _WordScreenProfluentEnglishState extends State<WordScreenProfluentEnglish>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final db = new FirebaseHelperRTD();
  FirebaseHelper _firestore = new FirebaseHelper();
  List<Word> words = [];
  final _searchQueryController = TextEditingController();
  bool _isSearching = false;
  bool isloading = false;
  bool _isCorrect = false;
  String _selectedWord = "";
  String? _selectedWordOnClick;
  int? _expandedIndex;
  bool open = false;
  late AutoScrollController controller;
  final _audioPlayerManager = AudioPlayerManager();
  Map<String, bool> expandedItems = {};
  late List<Word> soundPractice;
  bool isMenu = false;
  bool isAllPlaying3 = false;
  bool isAllPlaying = false;
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
  bool audioLoading = false;
  List<GlobalKey<AppExpansionTileState>> wordTileKeys = [];
  final AutoScrollController scrollController = AutoScrollController();
  String title = '';
  void _toggleExpansion(int index) {
    setState(() {
      final word = words[index].text!;
      if (expandedItems.containsKey(word) && expandedItems[word] == true) {
        expandedItems[word] = false;
      } else {
        expandedItems[word] = true;
      }
    });
  }

  void updateFavorite(int index, int isFav) {
    setState(() {
      words[index].isFav = isFav; // Update the favorite status in the list
    });
  }

  List<Map<String, dynamic>> convertWordListToMapList(List<Word> wordList) {
    return wordList.map((word) {
      return {
        'id': word.id?.toString() ?? '', // Convert int to String
        'key': word.key ?? '', // Already a String, use as is
        'file': word.file ?? '',
        'pronun': word.pronun ?? '',
        'syllables': word.syllables ?? '',
        'text': word.text ?? '',
        'isPriority': word.isPriority ?? '',
        'cat': word.cat ?? '',
        'localPath': word.localPath ?? '',
        'isFav': word.isFav?.toString() ?? '', // Convert int to String
        'isPlaying':
            word.isPlaying?.toString() ?? 'false' // Convert bool to String
      };
    }).toList();
  }

  Future<void> getSoundPracticeWords() async {
    setState(() {
      isloading = true;
    });
    FirebaseHelperRTD firebaseHelperRTD = FirebaseHelperRTD();

    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    List<Word> wordsList = [];
    if (kIsWeb) {
      wordsList = await firebaseHelperRTD.getWords(widget.load);
      soundPractice = wordsList;
    } else {
      wordsList = await dbRef.getWords();
      soundPractice =
          wordsList.where((element) => element.cat == widget.load).toList();
    }
    words = soundPractice;
    isPlaying = List.generate(soundPractice.length, (index) => false.obs);
    setState(() {});
    isloading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    // getSoundPracticeWords();
    _fetchWordSamples();
    print("edighfijfewsfeswfg:${widget.soundPractice.length}");
    // soundPractice = widget.soundPractice!;
    print("edighfijg:${widget.soundPractice.length}");
    //soundPractice = widget.soundPractice!;
    // getSoundPracticeWords();
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  Future<void> _fetchWordSamples({
    String? searchTerm,
    bool isRefresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      isloading = true;
    });

    // ✅ Step 1: Fetch base data
    if (!kIsWeb) {
      await getSoundPracticeWords(); // fills soundPractice safely
    } else {
      soundPractice = List<Word>.from(widget.soundPractice);
    }

    // ✅ Step 2: Always reset from original source
    List<Word> tempWords = List.from(soundPractice);

    // ✅ Step 3: Apply SEARCH (SAFE)
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      tempWords = tempWords.where((w) {
        final text = w.text ?? "";
        return text.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    }

    // ✅ Step 4: Assign to UI list
    words = tempWords;

    // ✅ Step 5: Rebuild UI state safely
    isPlaying = List.generate(words.length, (_) => false.obs);

    wordTileKeys = List.generate(
      words.length,
      (_) => GlobalKey<AppExpansionTileState>(),
    );

    // ✅ Step 6: Safe auto-scroll to selected word
    if (widget.word != null && words.isNotEmpty) {
      final scrollIndex = words.indexWhere(
        (e) => e.text == widget.word?.id,
      );

      if (scrollIndex != -1 && controller.hasClients) {
        await controller.scrollToIndex(
          scrollIndex,
          preferPosition: AutoScrollPosition.begin,
        );
      }
    }

    // ✅ Step 7: Final UI update
    if (mounted) {
      setState(() {
        isloading = false;
      });
    }
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
    isPlaying = List.generate(soundPractice.length, (index) => false.obs);

    // itemKeys = List.generate(words.length, (_) => GlobalKey());
    // setState(() {});

    for (int i = _currentIndex; i < words.length; i++) {
      await Future.delayed(Duration(seconds: 1));
      if (_isPaused) {
        _currentIndex = i;
        break; // Exit the loop if paused
      }
      if (!isAllPlaying) {
        break;
      }
      _selectedWordOnClick = words[i].text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wordTileKeys[i].currentState?.expand();
        _scrollToItem(i);
      });
      // }
      // setState(() {});

      if (isAllPlaying && words[i].file != null && words[i].file!.isNotEmpty) {
        words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});
        if (kIsWeb) {
          await audioPlayerManager.play(
            words[i].file!,
            context: context,
            decodedPath: null, // skip decoded path on web
          );
        } else {
          await _audioPlayerManager.play(words[i].file!,
              context: context,
              localPath: words[i].localPath, decodedPath: (val) {
            eLocalPath = val;
          });
        }

        await Future.delayed(Duration(seconds: 3));
        words[i].isPlaying = false;
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
      _currentIndex = words.length - 1;
      // _currentIndex = 0;
      isAllPlaying = false;
      if (_currentIndex == words.length - 1) {
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
    isPlaying = List.generate(words.length, (_) => false.obs);

    setState(() {});

    String? decodedPath;

    // Loop through words from current index
    for (int i = _currentIndex3; i < words.length; i++) {
      if (!isAllPlaying3) break;
      _selectedWordOnClick = words[i].text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wordTileKeys[i].currentState?.expand();
        _scrollToItem(i);
      });
      // Skip if no file
      if (words[i].file == null || words[i].file!.isEmpty) continue;

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
        words[i].isPlaying = true;
        isPlaying[i].value = true;
        setState(() {});
        if (kIsWeb) {
          await audioPlayerManager.play3(
            words[i].file!,
            context: context,
            decodedPath: null,
          );
        } else {
          await _audioPlayerManager.play3(
            words[i].file!,
            context: context,
            localPath: words[i].localPath,
            decodedPath: (val) => decodedPath = val,
          );
        }
        // Play audio

        // Small delay after each play
        await Future.delayed(const Duration(seconds: 2));

        // Stop UI animation
        words[i].isPlaying = false;
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
        // await _savePracticeReport(user);
      }
      scrollToIndex(i);
      _currentPlayCount3 = 0;
      setState(() {});
    }

    if (!_isPaused3) {
      _currentIndex3 = words.length - 1;
      _currentPlayCount3 = 0;
      isAllPlaying3 = false;

      if (_currentIndex3 == words.length - 1) {
        closePlay3StopDialog = true;
        log("✔ Completed all three-round plays");
      }
    }
    await resetState();
    await WakelockPlus.disable();
    setState(() {});
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

  void _applyPriorityFilter() {
    title = 'Priority List';
    // ✅ Filter only favorites
    final List<Word> filtered =
        soundPractice.where((word) => (word.isFav ?? 0) == 1).toList();

    // ✅ Replace current UI list
    words = filtered;

    // ✅ Rebuild isPlaying safely
    isPlaying = List.generate(words.length, (_) => false.obs);

    // ✅ Rebuild expansion keys

    // ✅ Reset selection
    _selectedWordOnClick = null;

    setState(() {});
  }

  void _clearFilter() {
    title = widget.title;
    // ✅ Restore full original list
    words = List<Word>.from(soundPractice);

    // ✅ Rebuild isPlaying safely
    isPlaying = List.generate(words.length, (_) => false.obs);

    // ✅ Rebuild expansion keys

    // ✅ Reset selections
    _selectedWordOnClick = null;
    _searchQueryController.clear();
    _isSearching = false;

    setState(() {});
  }

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
        padding: const EdgeInsets.only(bottom: 5, left: 0, right: 10),
        child: TextField(
          cursorColor: Colors.white,
          controller: _searchQueryController,
          autofocus: true,
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
            _fetchWordSamples(
              searchTerm: query,
              isRefresh: false,
            );
            // _getWords(searchTerm: query, isRefresh: false);
          },
        ),
      ),
    );
  }

  void updateSearchQuery(String newQuery) {
    // _getWords(searchTerm: newQuery, isRefresh: false);
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
              // selectedMenuOption = value;

              if (value == 'all_priority') {
                isAllPlaying = false;
                isAllPlaying3 = false;

                setState(() {});
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
                _applyPriorityFilter();
              } else if (value == 'clear') {
                _clearFilter();
                if (widget.title == "Priority List") {
                  Navigator.pop(context);
                } else if (_isSearching) {
                  _isSearching = false;
                  // _getWords(searchTerm: "", isRefresh: false);
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
                      fontWeight: title == "Priority List"
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: title == "Priority List"
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
        soundPractice.length == 0
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
                    // closePlay1StopDialog = true;
                    // openPlay3StopDialog = true;
                    // closePlay3StopDialog = false;
                    // _isPaused3 = false;
                    // _currentIndex3 = 0;
                  });
                  // _playAll3Times();
                }),
      if (widget.title.trim() == "Priority List" && isAllPlaying3 ||
          widget.title.trim() == "All Priority List" && isAllPlaying3)
        soundPractice.length == 0
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
        soundPractice.length == 0
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
                    // closePlay3StopDialog = true;
                    // openPlay1StopDialog = true;
                    // closePlay1StopDialog = false;
                    // _isPaused = false;
                    // _currentIndex = 0;
                    // switchingKey = true;
                    // print("swithchingKey:${switchingKey}");
                  });
                  _playAll();
                },
              ),
      if (widget.title.trim() == "Priority List" && isAllPlaying ||
          widget.title.trim() == "All Priority List" && isAllPlaying)
        soundPractice.length == 0
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
        setState(() {});
      } else if (value != null && value.isCorrect == "notCatch") {
        _showDialog(word, true, context);
      } else if (value != null && value.isCorrect == "openDialog") {
        _showDialog(word, false, context);
      }
    }).onError((error, stackTrace) {
      log(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBar(
        titleSpacing: 0,
        actionsPadding: EdgeInsets.zero,
        actions: _buildActions(),
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
            if (title == "Priority List" || title == "All Priority List") {
              title = widget.title;
              _clearFilter();
            } else if (_isSearching) {
              _isSearching = false;
              _clearFilter();
              _fetchWordSamples();
              setState(() {});
            } else {
              stopTimerMainCategory();
              Navigator.pop(context);
            }
          },
        ),
        title: !_isSearching
            ? Text(
                title == '' ? widget.title : title,
                maxLines: 2,
                style: TextStyle(
                    fontFamily: Keys.lucidaFontFamily,
                    fontSize: globalFontSize(18, context),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis),
              )
            : _buildSearchField(),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: false,
        // actions: _buildActions(),
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
          // words.length == 0 && !_isLoading
          //     ? Center(
          //         child: Text(
          //           "Not Found",
          //           style: TextStyle(
          //               color: AppColors.white, fontFamily: Keys.fontFamily),
          //         ),
          //       )
          isloading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              :
              //   FutureBuilder(
              // future: _fetchWordSamples(),
              // builder: ((context, snapshot) {
              //   if (snapshot.connectionState == ConnectionState.waiting) {
              //     return Center(child: CircularProgressIndicator());
              //   } else if (snapshot.hasError) {
              //     return Center(child: Text('Error fetching word samples'));
              //   } else if (!snapshot.hasData ||
              //       (snapshot.data as List<Word>).isEmpty) {
              //     return Center(
              //       child: Text(
              //         "Not Found",
              //         style: TextStyle(
              //             color: Colors.white, fontFamily: 'YourFontFamily'),
              //       ),
              //     );
              //   } else {
              // words = snapshot.data! as List<Word>;

              Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                              padding: EdgeInsets.only(
                                  top: isSplitScreen
                                      ? getFullWidgetHeight(height: 10)
                                      : getWidgetHeight(height: 10)),
                              itemCount: words.length,
                              controller: scrollController,
                              itemBuilder: (BuildContext context, int index) {
                                if (!isAllPlaying && !isAllPlaying3) {
                                  isPlaying = List.generate(
                                      words.length, (index) => false.obs);
                                }

                                return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: controller,
                                  index: index,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index == words.length - 1
                                            ? isSplitScreen
                                                ? getFullWidgetHeight(
                                                    height: 60)
                                                : getWidgetHeight(height: 60)
                                            : 0),
                                    child: Container(
                                      // key: itemKeys[index],
                                      child: DropDownWordItem(
                                        key: wordTileKeys[index],
                                        localPath: words[index].localPath,
                                        load: widget.load,
                                        length: words.length,
                                        index: index,
                                        // isPlaying: words[index].isPlaying,
                                        isDownloaded: (words[index].localPath !=
                                                null &&
                                            words[index].localPath!.isNotEmpty),
                                        maintitle: widget.title,
                                        onExpansionChanged: (val) {
                                          setState(() {
                                            _selectedWord = '';
                                          });
                                          if (val) {
                                            _selectedWordOnClick =
                                                words[index].text;
                                            setState(() {});
                                            if (words.length - 2 <= index) {
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
                                                    words[index].text,
                                        isWord: true,
                                        isRefresh: (val) {
                                          if (val) _fetchWordSamples();
                                        },
                                        // words: words,
                                        wordId: words[index].id ?? 0,
                                        isFav: words[index].isFav ?? 0,
                                        title: words[index].text ?? "",

                                        url: words[index].file,
                                        onTapForThreePlayerStop:
                                            updateThreePlayerFlag,
                                        children: [
                                          WordMenu(
                                            pronun: words[index].pronun!,
                                            selectedWord: _selectedWord,
                                            isCorrect: _selectedWord ==
                                                    words[index].text &&
                                                _isCorrect,
                                            text: words[index].text!,
                                            syllables: words[index].syllables!,
                                            onTapHeadphone: () async {},
                                            url: words[index].file,
                                            onTapMic: () async {
                                              _showDialog(words[index].text!,
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
                                  right:
                                      kIsWeb ? displayWidth(context) / 3 : 105,
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
                                                          color:
                                                              Color(0XFF34425D),
                                                          size: 30,
                                                        )),
                                            InkWell(
                                                onTap: () async {
                                                  _audioPlayerManager.stop();
                                                  isAllPlaying = false;
                                                  setState(() {
                                                    openPlay1StopDialog = false;
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
                                    context.read<AuthState>().currentIndex == 0
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
                                      context.read<AuthState>().currentIndex ==
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
                                  color:
                                      context.read<AuthState>().currentIndex ==
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
                                  color:
                                      context.read<AuthState>().currentIndex ==
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
                                  color:
                                      context.read<AuthState>().currentIndex ==
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
      //     isloading || kIsWeb ? SizedBox() : buildBoomMenu()
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
                setState(() {});
                log("dohdougdugdugdu : ${widget.load}");
                print("sjidjgij:${widget.title}");
                print("checkkkk:${widget.soundPractice.length}");
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => WordScreen(
                //             // index: 5,
                //             itemWordList:
                //                 convertWordListToMapList(widget.soundPractice),
                //             //controllerList: widget.controllerList,
                //             title: "Priority List",
                //             load: "",
                //             check: false,
                //             backButtonCheck: true,
                //             checkTitle: widget.load,
                //             soundPractice: widget.soundPractice,
                //             filterLoad: repeatLoads //widget.title,
                //             )));
              },
            ),
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
                print("filter all priority tappeddd>>>>>>>>>>>>");
                isAllPlaying = false;
                isAllPlaying3 = false;

                setState(() {});
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => WordScreen(
                //               title: "All Priority List",
                //               load: "",
                //               checkTitle: widget.load,
                //               check: false,
                //               backButtonCheck: true,
                //               soundPractice: widget.soundPractice,
                //               // filterLoad: repeatLoads //widget.title,
                //             )));
              },
            ),
          ]),
    );
  }
}
