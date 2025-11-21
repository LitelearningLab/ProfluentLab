import 'dart:async';
import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/screens/profluent_english/new_profluent_english_screen.dart';
// import 'package:litelearninglab/screens/profluent_english/widgets/video_player_controller.dart';
import 'package:litelearninglab/screens/profluent_english/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../constants/app_colors.dart';
import '../../database/WordsDatabaseRepository.dart';
import '../../database/databaseProvider.dart';
import '../../models/ProfluentSubLink.dart';
import '../../models/Word.dart';
import '../../utils/sizes_helpers.dart';
import '../dialogs/speech_analytics_dialog.dart';

class ProfluentSubScreen extends StatefulWidget {
  ProfluentSubScreen(
      {Key? key,
      required this.links,
      required this.load,
      required this.title,
      this.ulr,
      this.soundPractice})
      : super(key: key);
  final ProfluentSubLink links;
  final String load;
  final String title;
  final List<Word>? soundPractice;
  String? ulr;

  @override
  _ProfluentSubScreenState createState() {
    return _ProfluentSubScreenState();
  }
}

class _ProfluentSubScreenState extends State<ProfluentSubScreen> {
  int _selected = 0;
  late VideoPlayerController _controller;
  late Future<VideoPlayerController> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  late AutoScrollController controller;
  // late ChewieController _chewieController;
  bool _isCorrect = false;
  String _selectedWord = "";
  List<Word> _words = [];
  late List<Word> soundPractice;
  bool isLoading = false;
  bool _isControllerVisible = false;
  Timer? _hideControllerTimer;
  int checkUrl = 0;
  bool _isControllerInitializing = false;
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    log("entering to the sound page init state. ");
    startTimerMainCategory("name");

    soundPractice = widget.soundPractice!;
    print("length of the soundpractice ${soundPractice.length}");
    if (!kIsWeb) {
      getSoundPracticeWords();
    }

    _initializeVideoPlayerFuture = _initVideoPlayer(url: widget.links.v1!);
    print(
        'intializeVideoPlayerFuture:${_initializeVideoPlayerFuture}'); //video link
  }

  refreshScreen(int no) {
    _initializeVideoPlayerFuture = _initVideoPlayer(url: widget.links.v1!);
    setState(() {
      _isPlaying = true;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  Future<VideoPlayerController> _initVideoPlayer({required String url}) async {
    log("printing url : ${url}");
    _isControllerInitializing = true;
    _hasInitError = false;
    _isPlaying = false;
    setState(() {});

    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      _controller = VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _controller.initialize();
      await _controller.setVolume(1);
      await _controller.play();
      _isPlaying = true;
      setState(() {});
    } catch (e1) {
      try {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        await _controller.initialize();
        await _controller.setVolume(1);
        await _controller.play();
        _isPlaying = true;
        setState(() {});
      } catch (e2) {
        log("Video init failed: $e2");
        _hasInitError = true;
      }
    }

    _isControllerInitializing = false;
    return _controller;
  }

  Future<void> getSoundPracticeWords() async {
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
    print("printing the length of the sound practice ${soundPractice.length}");

    setState(() {});
  }

  String formatDuration(Duration duration) {
    var remaining = duration - _controller.value.position;
    String minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() async {
    print("disposeddddd");
    log("disposed");
    try {
      // _chewieController.dispose();
      // await _controller.dispose();
    } catch (e) {
      print("Error disposing old controllers: $e");
    }

    super.dispose();
  }

  String getLetter(String input) {
    int spaceindex = input.indexOf(' ');
    if (spaceindex != -1 && spaceindex + 1 < input.length) {
      return input[spaceindex + 1];
    }

    return '';
  }

  void _onClick(int index) async {
    print("🔹 [onClick] START — tapped index: $index");

    try {
      isLoading = true;
      _isPlaying = false;
      _selected = index;
      setState(() {});
      print("✅ State updated — selected index = $_selected, loading started");

      // Pause & dispose current controller
      if (_controller.value.isInitialized) {
        print("⏸️ Controller is initialized — pausing...");
        await _controller.pause();
        print("🧹 Disposing controller...");
        await _controller.dispose();
        print("✅ Controller paused and disposed successfully");
      } else {
        print("⚠️ Controller not initialized — skipping pause/dispose");
      }

      // Choose URL
      late String url;
      if (index >= 0 && index <= 4) {
        print("🎯 Index $index is within range 0–4, selecting URL...");
        url = index == 0
            ? widget.links.v1!
            : index == 1
                ? widget.links.v2!
                : index == 2
                    ? widget.links.v3!
                    : index == 3
                        ? widget.links.v4!
                        : widget.links.v5!;
        print("🔗 Selected URL: $url");
      } else if (index == 5) {
        print("📘 Index = 5 — navigating to WordScreenProfluentEnglish");

        if (_controller.value.isInitialized) {
          await _controller.pause();
          print("⏸️ Controller paused before navigation");
        }

        print("📦 Fetching sound practice words...");
        if (!kIsWeb) {
          await getSoundPracticeWords();
        }
        print("✅ Sound practice words fetched: ${soundPractice.length}");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordScreenProfluentEnglish(
              title: 'Words',
              load: 'Words',
              soundPractice: soundPractice,
            ),
          ),
        );
        print("🚀 Navigation complete");
        return;
      } else {
        print("⚠️ Unexpected index value: $index — no URL selected");
        return;
      }

      // Platform check 👇
      if (kIsWeb) {
        print("🌐 Detected platform: WEB — using network controller");
        _controller = VideoPlayerController.network(url);
      } else {
        print("📱 Detected platform: MOBILE — using cached file");
        final file = await DefaultCacheManager().getSingleFile(url);
        print("📁 Cached file path: ${file.path}");
        _controller = VideoPlayerController.file(file);
      }

      print("🎬 Initializing controller...");
      await _controller.initialize();
      print("✅ Controller initialized");

      _controller.setLooping(false);
      _controller.setVolume(1.0);
      print("🔊 Volume set, looping disabled");

      await _controller.play();
      print("▶️ Playback started");

      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          print("🏁 Video playback completed");
        }
        setState(() {});
      });

      _isPlaying = true;
      setState(() {});
      print("✅ UI updated — video now playing");
    } catch (e, s) {
      print("❌ ERROR in _onClick (index: $index): $e");
      print("📄 Stack trace:\n$s");
    } finally {
      print("🏁 [onClick] END — index: $index\n");
    }
  }

  void toggleControllerVisibility() {
    if (_isControllerVisible) {
      // If currently visible, make it immediately invisible
      _hideControllerTimer?.cancel(); // Cancel any existing hide timer
      setState(() {
        _isControllerVisible = false;
      });
    } else {
      // If currently invisible, show it
      _showController();
    }
  }

  void togglePlayPauseControllerVisibility() {
    // Always show the controller for the play/pause action
    _showController();
  }

  void _showController() {
    // if (_isControllerVisible) {
    // If currently visible, make it immediately invisible
    _hideControllerTimer?.cancel(); // Cancel any existing hide timer
    // }
    setState(() {
      _isControllerVisible = true;
    });

    // Cancel any existing timer
    // _hideControllerTimer?.cancel();

    // Start a new timer to hide the controller
    _hideControllerTimer = Timer(Duration(seconds: 4), () {
      setState(() {
        _isControllerVisible = false;
      });
    });
  }

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    print("/////////SHOW DIALOGUE BOX");
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
      // print('/////////////// iscorrect : ${value.isCorrect}');
      if (value != null && value.isCorrect == "true" ||
          value.isCorrect == "false") {
        print("first test cases");
        // print('/////////////// iscorrect : ${value.isCorrect}');
        _selectedWord = word;
        _isCorrect = value.isCorrect == "true" ? true : false;
        print("is pronun correct : $_isCorrect");
        setState(() {});
        _WordAnalysisResult(context);
      } else if (value != null && value.isCorrect == "notCatch") {
        print("two test cases");
        _showDialog(word, true, context);
      } else if (value != null && value.isCorrect == "openDialog") {
        print("third test cases");
        _showDialog(word, false, context);
      }
    });
  }

  void _WordAnalysisResult(BuildContext context) async {
    print("////////////Analysing Result Dialogue");
    Get.dialog(
      Container(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: ListTile(
            title: Text(
              "Pronunciation Analysis Result",
              style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: kText.scale(13),
                  fontFamily: Keys.fontFamily),
            ),
            subtitle: Text(
              "Note: This result only indicates intelligibility and does not confirm the accuracy of pronunciation.",
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontFamily: Keys.fontFamily),
            ),
            trailing: Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color: _isCorrect ? AppColors.green : Colors.red,
              size: isSplitScreen
                  ? getFullWidgetHeight(height: 45)
                  : getWidgetHeight(height: 45),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _initializeVideoPlayerFuture = _initVideoPlayer(url: widget.links.v1!);
    return PopScope(
      onPopInvoked: (didPop) {
        // if (!didPop) {
        stopTimerMainCategory();
        // }
      },
      child: BackgroundWidget(
        appBar: CommonAppBar(
          title: widget.load,
          fontFamily: Keys.lucidaFontFamily,
          // height: displayHeight(context) / 12.6875,
        ),
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.connectionState == ConnectionState.done) {
              return displayWidth(context) > 1000
                  ? Center(
                      child: SizedBox(
                        width: kWidth / 1.2,
                        child: SingleChildScrollView(
                          // padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 40),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                    color: Color(0xFF3B465A),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 40,
                                          right: 10,
                                          top: 20,
                                          bottom: 20),
                                      child: SizedBox(
                                        // color: Colors.yellow,
                                        width: kWidth / 3,
                                        height: kWidth / 3.5,
                                        child: _isPlaying == false
                                            ? _hasInitError
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.error,
                                                            color: Colors.white,
                                                            size: 48),
                                                        SizedBox(height: 16),
                                                        Text(
                                                            "Video failed to load",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            try {
                                                              // Forcefully dispose current controllers before retrying
                                                              await _controller
                                                                  .pause();
                                                              await _controller
                                                                  .dispose();
                                                              // _chewieController.dispose();
                                                            } catch (e) {
                                                              log("Error disposing controllers before retry: $e");
                                                            }

                                                            _initializeVideoPlayerFuture =
                                                                _initVideoPlayer(
                                                                    url: widget
                                                                        .links
                                                                        .v1!);
                                                            setState(() {});
                                                          },
                                                          child: Text("Retry"),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Center(
                                                    child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                          color: Colors.white),
                                                      SizedBox(
                                                        height: isSplitScreen
                                                            ? getFullWidgetHeight(
                                                                height: 10)
                                                            : getWidgetHeight(
                                                                height: 10),
                                                      ),
                                                      Text(
                                                        'Loading...',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ))
                                            : Stack(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        toggleControllerVisibility();
                                                      },
                                                      child: VideoPlayer(
                                                          _controller)),
                                                  if (_isControllerVisible)
                                                    Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          togglePlayPauseControllerVisibility();
                                                        },
                                                        child: Container(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ValueListenableBuilder(
                                                                  valueListenable:
                                                                      _controller,
                                                                  builder: (context,
                                                                      VideoPlayerValue
                                                                          value,
                                                                      child) {
                                                                    return IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_controller
                                                                            .value
                                                                            .isPlaying) {
                                                                          _controller
                                                                              .pause();
                                                                        } else {
                                                                          _controller
                                                                              .play();
                                                                        }
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        _controller.value.isPlaying
                                                                            ? Icons.pause
                                                                            : Icons.play_arrow,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    );
                                                                  }),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    _controller,
                                                                builder: (context,
                                                                    VideoPlayerValue
                                                                        value,
                                                                    child) {
                                                                  return Text(
                                                                    _formatDuration(
                                                                        value
                                                                            .position),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  );
                                                                },
                                                              ),
                                                              Text(
                                                                " / ",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    _controller,
                                                                builder: (context,
                                                                    VideoPlayerValue
                                                                        value,
                                                                    child) {
                                                                  return Text(
                                                                    _formatDuration(
                                                                        value
                                                                            .duration),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  );
                                                                },
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    _controller,
                                                                builder: (context,
                                                                    VideoPlayerValue
                                                                        value,
                                                                    child) {
                                                                  return Expanded(
                                                                    child:
                                                                        Slider(
                                                                      value: value
                                                                          .position
                                                                          .inMilliseconds
                                                                          .toDouble(),
                                                                      min: 0,
                                                                      max: value
                                                                          .duration
                                                                          .inMilliseconds
                                                                          .toDouble(),
                                                                      onChanged:
                                                                          (newValue) {
                                                                        _controller
                                                                            .seekTo(
                                                                          Duration(
                                                                              milliseconds: newValue.toInt()),
                                                                        );
                                                                      },
                                                                      activeColor:
                                                                          Colors
                                                                              .white,
                                                                      inactiveColor:
                                                                          Colors
                                                                              .grey,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              // **Current Time**
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 0, right: 20, top: 20),
                                      child: SizedBox(
                                        height: kWidth / 3.6,
                                        width: kWidth / 3.3,
                                        child: GridView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 1,
                                            mainAxisSpacing: 15,
                                            crossAxisSpacing: 15,
                                            childAspectRatio: 8.2,
                                          ),
                                          itemCount: 6,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTapDown: (TapDownDetails
                                                  onTapDetails) async {
                                                log("entering and priniting the index ${index}");
                                                // if (checkUrl != index) {
                                                // checkUrl = index;
                                                if (((widget.links.v1 == null ||
                                                            widget.links.v1!
                                                                .isEmpty) &&
                                                        index == 0) ||
                                                    ((widget.links.v2 == null ||
                                                            widget.links.v2!
                                                                .isEmpty) &&
                                                        index == 1) ||
                                                    ((widget.links.v3 == null ||
                                                            widget.links.v3!
                                                                .isEmpty) &&
                                                        index == 2) ||
                                                    ((widget.links.v4 == null ||
                                                            widget.links.v4!
                                                                .isEmpty) &&
                                                        index == 3) ||
                                                    ((widget.links.v5 == null ||
                                                            widget.links.v5!
                                                                .isEmpty) &&
                                                        index == 4) ||
                                                    ((widget.links.words ==
                                                                null ||
                                                            widget.links.words!
                                                                .isEmpty) &&
                                                        index == 5)) {
                                                  await _controller.pause();
                                                  // await _controller.dispose();

                                                  repeatLoads = widget.load;
/////////// //
                                                  if (!kIsWeb) {
                                                    await getSoundPracticeWords();
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              WordScreenProfluentEnglish(
                                                                title:
                                                                    widget.load,
                                                                load: widget
                                                                    .load, //'Words',
                                                                soundPractice:
                                                                    soundPractice!,
                                                              ))).then((_) {
                                                    // print("sjfidhjvgirj");
                                                    // refreshScreen(1);
                                                  });
                                                } else {
                                                  if (index == 5) {
                                                    repeatLoads = widget.load;
//
                                                    if (!kIsWeb) {
                                                      await getSoundPracticeWords();
                                                    }
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                WordScreenProfluentEnglish(
                                                                  title: widget
                                                                      .load,
                                                                  load: widget
                                                                      .load, //'Words',
                                                                  soundPractice:
                                                                      soundPractice!,
                                                                ))).then(
                                                        (value) {
                                                      // print("valueee:$value");
                                                      // if (value == "from") {
                                                      refreshScreen(2);
                                                      // }
                                                    });
                                                    await _controller.pause();
                                                    // await _controller.dispose();
                                                  } else {
                                                    log("else part is working");
                                                    _onClick(index);
                                                  }
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF3B465A),
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.white,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      if (index != 5)
                                                        Image.asset(
                                                            "assets/images/pl${index + 1}.png",
                                                            width: displayWidth(
                                                                    context) *
                                                                0.05),
                                                      if (index == 5)
                                                        SizedBox(
                                                            width:
                                                                getWidgetWidth(
                                                                    width: 5)),
                                                      if (index == 5)
                                                        Icon(
                                                          Icons.mic,
                                                          color: Colors.white,
                                                          size: getWidgetHeight(
                                                              height: 33),
                                                        ),
                                                      if (index == 5)
                                                        SizedBox(
                                                          width: getWidgetWidth(
                                                              width: 7),
                                                        ),
                                                      SizedBox(
                                                          width: getWidgetWidth(
                                                              width: 8)),
                                                      Text(
                                                        index == 0
                                                            ? "Front View"
                                                            : index == 1
                                                                ? "Side View"
                                                                : index == 2
                                                                    ? "Front Closer"
                                                                    : index == 3
                                                                        ? "Side Closer"
                                                                        : index ==
                                                                                4
                                                                            ? "Animation"
                                                                            : "Practice",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                kText.scale(20),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: getWidgetWidth(width: 5)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: getWidgetWidth(width: 10),
                                    vertical: getWidgetHeight(height: 20)),
                                child: Column(
                                  children: [
                                    Text(
                                      "Usual Letter Representations",
                                      style: TextStyle(
                                          color: AppColors.pinkishGrey,
                                          fontFamily: Keys.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: kText.scale(15)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        widget.ulr ?? "Empty",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: Keys.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: kText.scale(15)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 60,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        SizedBox(
                            width: kWidth,
                            height: kIsWeb
                                ? displayHeight(context) * 0.5
                                : _controller.value.isInitialized
                                    ? kWidth / _controller.value.aspectRatio
                                    : displayWidth(context),
                            child: _isPlaying == false
                                ? _hasInitError
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.white, size: 48),
                                            SizedBox(height: 16),
                                            Text("Video failed to load",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  // Forcefully dispose current controllers before retrying
                                                  await _controller.pause();
                                                  await _controller.dispose();
                                                  // _chewieController.dispose();
                                                } catch (e) {
                                                  log("Error disposing controllers before retry: $e");
                                                }

                                                _initializeVideoPlayerFuture =
                                                    _initVideoPlayer(
                                                        url: widget.links.v1!);
                                                setState(() {});
                                              },
                                              child: Text("Retry"),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                              color: Colors.white),
                                          SizedBox(
                                            height: isSplitScreen
                                                ? getFullWidgetHeight(
                                                    height: 10)
                                                : getWidgetHeight(height: 10),
                                          ),
                                          Text(
                                            'Loading...',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ))
                                : Stack(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            toggleControllerVisibility();
                                          },
                                          child: VideoPlayer(_controller)),
                                      if (_isControllerVisible)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              togglePlayPauseControllerVisibility();
                                            },
                                            child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ValueListenableBuilder(
                                                      valueListenable:
                                                          _controller,
                                                      builder: (context,
                                                          VideoPlayerValue
                                                              value,
                                                          child) {
                                                        return IconButton(
                                                          onPressed: () {
                                                            if (_controller
                                                                .value
                                                                .isPlaying) {
                                                              _controller
                                                                  .pause();
                                                            } else {
                                                              _controller
                                                                  .play();
                                                            }
                                                          },
                                                          icon: Icon(
                                                            _controller.value
                                                                    .isPlaying
                                                                ? Icons.pause
                                                                : Icons
                                                                    .play_arrow,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ),
                                                        );
                                                      }),
                                                  ValueListenableBuilder(
                                                    valueListenable:
                                                        _controller,
                                                    builder: (context,
                                                        VideoPlayerValue value,
                                                        child) {
                                                      return Text(
                                                        _formatDuration(
                                                            value.position),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      );
                                                    },
                                                  ),
                                                  Text(
                                                    " / ",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable:
                                                        _controller,
                                                    builder: (context,
                                                        VideoPlayerValue value,
                                                        child) {
                                                      return Text(
                                                        _formatDuration(
                                                            value.duration),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      );
                                                    },
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable:
                                                        _controller,
                                                    builder: (context,
                                                        VideoPlayerValue value,
                                                        child) {
                                                      return Expanded(
                                                        child: Slider(
                                                          value: value.position
                                                              .inMilliseconds
                                                              .toDouble(),
                                                          min: 0,
                                                          max: value.duration
                                                              .inMilliseconds
                                                              .toDouble(),
                                                          onChanged:
                                                              (newValue) {
                                                            _controller.seekTo(
                                                              Duration(
                                                                  milliseconds:
                                                                      newValue
                                                                          .toInt()),
                                                            );
                                                          },
                                                          activeColor:
                                                              Colors.white,
                                                          inactiveColor:
                                                              Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  // **Current Time**
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )),
                        Padding(
                          padding: EdgeInsets.only(
                              left: getWidgetWidth(width: 20),
                              right: getWidgetWidth(width: 20),
                              top: isSplitScreen
                                  ? getFullWidgetHeight(height: 20)
                                  : getWidgetHeight(height: 20)),
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // Number of columns in the grid
                              mainAxisSpacing: 18, // Spacing between rows
                              crossAxisSpacing: 19, // Spacing between columns
                              childAspectRatio:
                                  3, // Width to height ratio of each grid item
                            ),
                            itemCount: 6, // Total number of items in the grid
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                splashColor: Colors.transparent,
                                onTap: () async {
                                  log("entering and priniting the index ${index}");
                                  // if (checkUrl != index) {
                                  // checkUrl = index;
                                  if (((widget.links.v1 == null ||
                                              widget.links.v1!.isEmpty) &&
                                          index == 0) ||
                                      ((widget.links.v2 == null ||
                                              widget.links.v2!.isEmpty) &&
                                          index == 1) ||
                                      ((widget.links.v3 == null ||
                                              widget.links.v3!.isEmpty) &&
                                          index == 2) ||
                                      ((widget.links.v4 == null ||
                                              widget.links.v4!.isEmpty) &&
                                          index == 3) ||
                                      ((widget.links.v5 == null ||
                                              widget.links.v5!.isEmpty) &&
                                          index == 4) ||
                                      ((widget.links.words == null ||
                                              widget.links.words!.isEmpty) &&
                                          index == 5)) {
                                    await _controller.pause();
                                    // await _controller.dispose();

                                    repeatLoads = widget.load;
                                    if (!kIsWeb) {
                                      await getSoundPracticeWords();
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WordScreenProfluentEnglish(
                                                  title: widget.load,
                                                  load: widget.load, //'Words',
                                                  soundPractice: soundPractice!,
                                                ))).then((_) {
                                      // print("sjfidhjvgirj");
                                      // refreshScreen(1);
                                    });
                                  } else {
                                    if (index == 5) {
                                      repeatLoads = widget.load;
                                      if (!kIsWeb) {
                                        await getSoundPracticeWords();
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WordScreenProfluentEnglish(
                                                    title: widget.load,
                                                    load:
                                                        widget.load, //'Words',
                                                    soundPractice:
                                                        soundPractice!,
                                                  ))).then((value) {
                                        // print("valueee:$value");
                                        // if (value == "from") {
                                        refreshScreen(2);
                                        // }
                                      });
                                      await _controller.pause();
                                      // await _controller.dispose();
                                    } else {
                                      log("else part is working");
                                      _onClick(index);
                                    }
                                  }
                                  // }
                                  setState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getWidgetWidth(width: 10),
                                      vertical: isSplitScreen
                                          ? getFullWidgetHeight(height: 5)
                                          : getWidgetHeight(height: 5)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xff34425D),
                                  ),
                                  child: Row(
                                    children: [
                                      if (index != 5)
                                        Image.asset(
                                          "assets/images/pl${index + 1}.png",
                                          width: getWidgetWidth(width: 35),
                                        ),
                                      if (index == 5)
                                        SizedBox(
                                            width: getWidgetWidth(width: 5)),
                                      if (index == 5)
                                        Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                          size: isSplitScreen
                                              ? getFullWidgetHeight(height: 33)
                                              : getWidgetHeight(height: 33),
                                        ),
                                      if (index == 5)
                                        SizedBox(
                                          width: getWidgetWidth(width: 0),
                                        ),
                                      SizedBox(
                                          width: getWidgetWidth(width: 10)),
                                      Text(
                                        index == 0
                                            ? "Front View"
                                            : index == 1
                                                ? "Side View"
                                                : index == 2
                                                    ? "Front Closer"
                                                    : index == 3
                                                        ? "Side Closer"
                                                        : index == 4
                                                            ? "Animation"
                                                            : "Practice",
                                        style: TextStyle(
                                            color: (((widget.links.v1 == null ||
                                                            widget.links.v1!
                                                                .isEmpty) &&
                                                        index == 0) ||
                                                    ((widget.links.v2 == null ||
                                                            widget.links.v2!
                                                                .isEmpty) &&
                                                        index == 1) ||
                                                    ((widget.links.v3 == null ||
                                                            widget.links.v3!
                                                                .isEmpty) &&
                                                        index == 2) ||
                                                    ((widget.links.v4 == null ||
                                                            widget.links.v4!
                                                                .isEmpty) &&
                                                        index == 3) ||
                                                    ((widget.links.v5 == null ||
                                                            widget.links.v5!.isEmpty) &&
                                                        index == 4) ||
                                                    ((widget.links.words == null || widget.links.words!.isEmpty) && index == 5))
                                                ? Colors.white
                                                : Colors.white,
                                            fontSize: kText.scale(15),
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: getWidgetWidth(width: 5)),
                          padding: EdgeInsets.symmetric(
                              horizontal: getWidgetWidth(width: 10),
                              vertical: isSplitScreen
                                  ? getFullWidgetHeight(height: 10)
                                  : getWidgetHeight(height: 10)),
                          child: Column(
                            children: [
                              Text(
                                "Usual Letter Representations",
                                style: TextStyle(
                                    color: AppColors.pinkishGrey,
                                    fontFamily: Keys.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    fontSize: kText.scale(15)),
                              ),
                              Text(
                                widget.ulr ?? "Empty",
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: Keys.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    fontSize: kText.scale(15)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
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
                    );
            } else {
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
          },
        ),
      ),
    );
  }
}
