import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/screens/word_screen/widgets/word_menu.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/FirestoreService.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:litelearninglab/common_widgets/boom_menu_item.dart' as bm;

import 'package:scroll_to_index/scroll_to_index.dart';

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
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    List<Word> wordsList = await dbRef.getWords();
    print('words list length :${wordsList.length}');
    soundPractice =
        wordsList.where((element) => element.cat == widget.load).toList();
    print("soundkfidj:${soundPractice.length}");
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

  Future<void> _fetchWordSamples() async {
    setState(() {
      isloading = true;
    });
    print("sounds practice : ${widget.soundPractice}");
    print("sound practice length : ${widget.soundPractice.length}");
    await getSoundPracticeWords();
    // words.clear();
    words = soundPractice;
    print("words practice : ${words}");
    print("words practice length : ${words.length}");
    print("words practice syllables : ${words.first.syllables}");
    isloading = false;
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
        padding: const EdgeInsets.only(bottom: 5, left: 45),
        child: TextField(
          controller: _searchQueryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Search Word...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          onChanged: (query) {
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
    if (_isSearching) {
      return <Widget>[
        Spacer(),
        IconButton(
          icon: ImageIcon(AssetImage(AllAssets.pfSearch)),
          onPressed: () {
            if (_searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            // _getWords(
            //     searchTerm: _searchQueryController.text, isRefresh: false);
          },
        ),
        SPW(displayWidth(context) / 37.5)
      ];
    }

    return <Widget>[
      if (widget.title.trim() == "Priority List" && !isAllPlaying3 ||
          widget.title.trim() == "All Priority List" && !isAllPlaying3)
        IconButton(
            icon: Icon(Icons.looks_3),
            onPressed: () {
              _audioPlayerManager.stop();
              isAllPlaying = false;

              setState(() {});
              // _playAll3Times();
            }),
      if (widget.title.trim() == "Priority List" && isAllPlaying3 ||
          widget.title.trim() == "All Priority List" && isAllPlaying3)
        IconButton(
          icon: Icon(Icons.stop_circle_outlined),
          onPressed: () {
            _audioPlayerManager.stop();
            isAllPlaying3 = false;
            setState(() {});
          },
        ),
      if (widget.title.trim() == "Priority List" && !isAllPlaying ||
          widget.title.trim() == "All Priority List" && !isAllPlaying)
        IconButton(
          icon: Image.asset(
            AllAssets.playAll3,
            width: 25,
            color: AppColors.green,
          ),
          onPressed: () {
            _audioPlayerManager.stop();
            isAllPlaying3 = false;
            setState(() {});
            // _playAll();
          },
        ),
      if (widget.title.trim() == "Priority List" && isAllPlaying ||
          widget.title.trim() == "All Priority List" && isAllPlaying)
        IconButton(
          icon: Image.asset(
            AllAssets.stopAll,
            width: 25,
            color: AppColors.green,
          ),
          onPressed: () {
            log("pause button clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
            _audioPlayerManager.stop();
            isAllPlaying = false;
            setState(() {});
          },
        ),
      IconButton(
        icon: ImageIcon(AssetImage(AllAssets.searchIcon)),
        onPressed: _startSearch,
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

  void _scrollToItem(int index) {
    final double itemHeight = 200.0;
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

  void _playAll() async {
    isAllPlaying = true;
    String? eLocalPath;
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    setState(() {});
    isPlaying1 = List.generate(words.length, (index) => false.obs);
    for (int i = 0; i < words.length; i++) {
      print("Current Index: $i");
      if (isAllPlaying && words[i].file != null && words[i].file!.isNotEmpty) {
        words[i].isPlaying = true;
        isPlaying1[i].value = true;
        setState(() {});
        await _audioPlayerManager.play(words[i].file!,
            context: context,
            localPath: words[i].localPath, decodedPath: (val) {
          eLocalPath = val;
        });
        await Future.delayed(Duration(seconds: 2));
        words[i].isPlaying = false;
        isPlaying1[i].value = false;
        if (eLocalPath != null && eLocalPath!.isNotEmpty) {
          try {
            File(eLocalPath!).delete();
          } catch (e) {}
        }

        if (eLocalPath != null && eLocalPath!.isNotEmpty) {
          await Future.delayed(Duration(seconds: 3));
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
            date: DateFormat('dd-MMM-yyyy').format(DateTime.now()));
      }
    }
    isAllPlaying = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              print("back button calleddddfgd");
              Navigator.pop(context, "from");
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          flexibleSpace: !_isSearching
              ? Padding(
                  padding: const EdgeInsets.only(left: 50),
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
                              fontFamily: Keys.lucidaFontFamily,
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
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: words.length,
                            controller: controller,
                            itemBuilder: (BuildContext context, int index) {
                              return AutoScrollTag(
                                key: ValueKey(words[index].text),
                                controller: controller,
                                index: index,
                                child: DropDownWordItemProluentEnglish(
                                  onFavoriteToggle: updateFavorite,
                                  localPath: words[index].localPath,
                                  load: widget.load,
                                  length: words.length,
                                  index: index,
                                  // isPlaying: words[index].isPlaying1,
                                  isDownloaded:
                                      words[index].localPath != null &&
                                          words[index].localPath!.isNotEmpty,
                                  maintitle: 'words',
                                  onExpansionChanged: (val) {
                                    _toggleExpansion(index);
                                    print("check1111111111111111111111111>");
                                    setState(() {
                                      print("dgigi:${_selectedWord}");
                                      print("dngr:${words[index].text}");
                                      print("didjgig:${index}");
                                      // _selectedWord = '';
                                      _expandedIndex = index;
                                    });
                                    if (val) {
                                      _selectedWordOnClick = words[index].text;
                                      setState(() {});
                                      if (words.length - 2 <= index) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          _scrollToItem(index);
                                        });
                                      }
                                    }
                                  },
                                  initiallyExpanded: _expandedIndex == index,
                                  // _selectedWordOnClick != null && _selectedWordOnClick == words[index].text,
                                  isWord: true,
                                  isRefresh: (val) {
                                    // if (val) _getWords(isRefresh: true);
                                  },
                                  // words: words,
                                  wordId: words[index].id!,
                                  isFav: words[index].isFav!,
                                  title: words[index].text!,
                                  url: words[index].file!,
                                  // onTapForThreePlayerStop:
                                  //     updateThreePlayerFlag,
                                  children: [
                                    WordMenu(
                                      pronun: words[index].pronun!,
                                      selectedWord: _selectedWord,
                                      isCorrect:
                                          _selectedWord == words[index].text &&
                                              _isCorrect,
                                      text: words[index].text!,
                                      syllables: words[index].syllables!,
                                      url: words[index].file!,
                                      onTapHeadphone: () async {},
                                      onTapMic: () async {
                                        _showDialog(
                                            words[index].text!, false, context);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }),
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
                  ),
        floatingActionButton: isloading ? SizedBox() : buildBoomMenu());
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordScreen(
                            // index: 5,
                            itemWordList:
                                convertWordListToMapList(widget.soundPractice),
                            //controllerList: widget.controllerList,
                            title: "Priority List",
                            load: "",
                            check: false,
                            backButtonCheck: true,
                            checkTitle: widget.load,
                            soundPractice: widget.soundPractice,
                            filterLoad: repeatLoads //widget.title,
                            )));
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordScreen(
                              title: "All Priority List",
                              load: "",
                              checkTitle: widget.load,
                              check: false,
                              backButtonCheck: true,
                              soundPractice: widget.soundPractice,
                              // filterLoad: repeatLoads //widget.title,
                            )));
              },
            ),
          ]),
    );
  }
}
