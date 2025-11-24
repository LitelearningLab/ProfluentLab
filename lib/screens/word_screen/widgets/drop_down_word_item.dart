import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/database/SentencesDatabaseRepository.dart';
import 'package:litelearninglab/database/WordsDatabaseRepository.dart';
import 'package:litelearninglab/database/databaseProvider.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../utils/audio_player_manager.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/utils.dart';

AudioPlayerManager audioPlayerManager = AudioPlayerManager();
List<RxBool> isPlaying = [];
List<RxBool> audioLoading = [];

enum PlayingRouteState { speakers, earpiece }

class DropDownWordItem extends StatefulWidget {
  DropDownWordItem({
    Key? key,
    this.onTapForThreePlayerStop,
    // this.expKey,
    required this.children,
    this.icon,
    required this.title,
    required this.maintitle,
    this.url,
    required this.isWord,
    required this.wordId,
    this.localPath,
    required this.initiallyExpanded,
    required this.index,
    this.length,
    // this.isPlaying,
    required this.load,
    required this.isRefresh,
    this.onExpansionChanged,
    this.isFav = 0,
    this.onClick,
    this.isDownloaded,
    this.isCheckBoxDownloading = false,
    this.isButtonsVisible = true,
    this.underContruction = false,
    // required this.audioPlayerManager,
    this.mode = PlayerMode.mediaPlayer,
  }) : super(key: key);
  final List<Widget> children;
  final String title;
  final String? icon;
  final String maintitle;
  final String? url;
  final String? localPath;
  final String load;
  final bool isWord;
  int isFav;
  // final bool? isPlaying;
  final int index;
  int? length;
  bool? isDownloaded;
  bool isCheckBoxDownloading;
  final bool underContruction;
  final int wordId;
  final PlayerMode mode;
  final Function(bool) isRefresh;
  final bool initiallyExpanded;
  final bool isButtonsVisible;
  final Function(String)? onClick;
  final ValueChanged<bool>? onExpansionChanged;
  Function()? onTapForThreePlayerStop;
  // final AudioPlayerManager audioPlayerManager;
  // final VoidCallback onTapForThreePlayerStop;

  @override
  _DropDownWordItemState createState() {
    return _DropDownWordItemState(url, mode);
  }
}

class _DropDownWordItemState extends State<DropDownWordItem> {
  String? url;
  PlayerMode? mode;
  final GlobalKey<AppExpansionTileState> expansionTile = new GlobalKey();
  bool loading = false;
  bool _isDownloading = false;
  // bool _isPlaying = false;
  // List<bool> isPlay = [];
  bool _isAudioLoading = false;
  int _currentPLayingIndex = -1;

  bool _isAudioPlayed = true;
  late StreamSubscription _playerStateSubscription;
  List<String> wordsFileUrl = [];
  _DropDownWordItemState(this.url, this.mode);

  bool _isConnected = true;
  StreamSubscription? networkSubscription;

  // final _audioPlayerManager = AudioPlayerManager();

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
          "response for pronunciation lab report for listening : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  startPractice({required actionType}) async {
    print("Start practice Tappeddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIddd for startpractice:$userId");
    String action = actionType;
    print("action for start practice:${action}");
    String url = baseUrl + startPracticeApi;
    print("urlll : $url");
    try {
      print("responseeeeeeeedferferfwer");
      var response = await http.post(Uri.parse(url), body: {
        "userid": userId,
        "practicetype": "Pronunciation Sound Lab Report",
        "action": action
      });

      print("response start practice for pronunciation lab : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // subCategoryTitile = widget.title;
    // startTimerMainCategory("name");
    if (widget.length != null) {
      print("widgetLength : ${widget.length}");
      isPlaying = List.generate(widget.length!, (index) => false.obs);
      audioLoading = List.generate(widget.length!, (index) => false.obs);
    }
    // if (isPlaying[widget.index]) {
    //   _isPlaying = true;
    // } else {
    //   _isPlaying = false;
    // }
    _playerStateSubscription =
        audioPlayerManager.onPlayerStateChanged.listen((event) async {
      Future.delayed(const Duration(seconds: 2), () {
        log("This was Triggered");
        return isPlaying[widget.index].value = false;
      });
      // setState(() {});
      // log("is ${isPlaying[widget.index]}");
    });
    initConnectivity();

    networkSubscription =
        Connectivity().onConnectivityChanged.listen((connectionResult) {
      print('^^^^^^^^^^^^^^CHECKING CONNECTION');
      checkConnection(connectionResult);
    });
  }

  @override
  void didUpdateWidget(DropDownWordItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isPlaying[widget.index].value) {
      isPlaying[widget.index].value = true;
    } else {
      isPlaying[widget.index].value = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (widget.url != null) {
      _playerStateSubscription.cancel();
    }
    // audioPlayerManager.dispose();
    super.dispose();
  }

  final Connectivity connectivity = Connectivity();

  Future<void> initConnectivity() async {
    print('^^^^^^^^^^^ INIT CONNECTIVITY ^^^^^^^^^^^^^');
    List<ConnectivityResult> result;
    try {
      result = await connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        setState(() {
          print("sdndn");
          _isConnected = false;
        });
      } else {
        setState(() {
          _isConnected = true;
          print("isconnected:${_isConnected}");
        });
      }
    } catch (e) {
      print('Connection Init Error : $e');
    }
  }

  Future<void> checkConnection(
      List<ConnectivityResult> connectivityResult) async {
    print("checkConnection function callledddd");
    connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      print('sdkndn');
      setState(() {
        _isConnected = false;
      });
    } else {
      print("checkinggg");
      setState(() {
        print("didjivi");
        _isConnected = true;
      });
    }
    print('<<<<<<<< Is Connected : $_isConnected >>>>>>>>>>>>');
  }

  Future<void> _play(int index) async {
    print("check1");

    final audioController = Provider.of<AuthState>(context, listen: false);

    // 🔹 Update UI loading states
    setState(() {
      for (int i = 0; i < audioLoading.length; i++) {
        audioLoading[i].value = (i == widget.index);
      }
      _isAudioPlayed = true;
    });

    widget.onTapForThreePlayerStop;
    log("play button clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>fedgrg");

    isAllPlaying3 = false;
    isAllPlaying = false;
    setState(() {});

    String? eLocalPath;
    await audioPlayerManager.stop();

    setState(() {
      audioLoading[widget.index].value = true;
    });

    print("Above the loading value");

    // 🔹 WEB / MOBILE Split
    if (kIsWeb) {
      // 🌐 WEB MODE — Stream directly, no local file access
      print("WEB MODE: Streaming audio directly from URL");
      await audioPlayerManager.play(
        url!,
        context: context,
        decodedPath: null, // skip decoded path on web
      );
    } else {
      // 📱 MOBILE MODE — Uses local caching
      print("MOBILE MODE: Using local path if available");
      await audioPlayerManager.play(
        url!,
        context: context,
        localPath: widget.localPath,
        decodedPath: (val) {
          eLocalPath = val;
        },
      );
    }

    print("urllll: $url");
    print("context: $context");
    print("local pathhhh: ${widget.localPath}");
    print("Below the loading value");

    // 🔹 Update UI after play
    setState(() {
      audioLoading[widget.index].value = false;
      _isAudioPlayed = audioController.isAudioDone ?? false;
    });

    int previousIndex = isPlaying.indexWhere((element) => element.value);
    if (previousIndex != -1) {
      isPlaying[previousIndex].value = false;
    }
    isPlaying[widget.index].value = true;

    // 🔹 Save report to Firebase
    FirebaseHelper db = FirebaseHelper();
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    String company = await SharedPref.getSavedString("companyId");
    String batch = await SharedPref.getSavedString("batch");

    await db.saveWordListReport(
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
      title: widget.maintitle,
      time: 1,
      date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
    );

    // 🔹 Delete temp file (mobile only)
    if (!kIsWeb && eLocalPath != null && eLocalPath!.isNotEmpty) {
      try {
        await File(eLocalPath!).delete();
        print("🗑️ Temporary file deleted: $eLocalPath");
      } catch (e) {
        print("⚠️ Error deleting temp file: $e");
      }
    }

    print("✅ Audio playback completed successfully.");
  }

  Future<void> _handleFavoriteToggle() async {
    setState(() {
      _isDownloading = true;
      loading = true;
    });
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String? localPath;
      String? eLocalPath;

      if (widget.isFav == null || widget.isFav == 0) {
        localPath = await Utils.downloadFile(userDatas, url!,
            '${widget.title}.mp3', '$appDocPath/${widget.load}');
        print("locallpathhh:${localPath}");
        eLocalPath = EncryptData.encryptFile(localPath, userDatas);

        try {
          await File(localPath).delete();
        } catch (e) {
          // Log or handle error
        }
      }

      if (widget.isWord) {
        await _toggleWordFavorite(eLocalPath);
      } else {
        await _toggleSentenceFavorite(eLocalPath);
      }
      log("isFav>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      log('${widget.isFav}');
      // if (isFaved) {
      //   Toast.show(
      //     widget.isFav == 1 ? "Removed from your priority list" : "Added to your priority list",
      //     duration: Toast.lengthShort,
      //     gravity: Toast.bottom,
      //     backgroundColor: AppColors.white,
      //     textStyle: TextStyle(color: AppColors.black),
      //     backgroundRadius: 10,
      //   );
      // }

      widget.isRefresh(true);
    } finally {
      setState(() {
        _isDownloading = false;
        loading = false;
      });
    }
  }

  Future _toggleWordFavorite(String? eLocalPath) async {
    print("toggle word favourite function calledd");
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    bool favIs;
    bool isFaved;
    if (widget.isFav == null || widget.isFav == 0) {
      print("sdkjfd");
      isFaved = await dbRef.setFav(widget.wordId, 1, eLocalPath!);
      favIs = true;
    } else {
      isFaved = await dbRef.setFav(widget.wordId, 0, widget.localPath!);
      favIs = false;
    }
    if (isFaved) {
      Toast.show(
        !favIs
            ? "Removed from your priority list"
            : "Added to your priority list",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundColor: AppColors.white,
        textStyle: TextStyle(color: AppColors.black),
        backgroundRadius: 10,
      );
    }
  }

  Future _toggleSentenceFavorite(String? eLocalPath) async {
    SentDatabaseProvider dbb = SentDatabaseProvider.get;
    SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
    bool isFaved;
    bool favIs;
    if (widget.isFav == null || widget.isFav == 0) {
      isFaved = await dbRef.setFav(widget.wordId, 1, eLocalPath!);
      favIs = true;
    } else {
      isFaved = await dbRef.setFav(widget.wordId, 0, widget.localPath!);
      favIs = false;
    }
    if (isFaved) {
      Toast.show(
        !favIs
            ? "Removed from your priority list"
            : "Added to your priority list",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundColor: AppColors.white,
        textStyle: TextStyle(color: AppColors.black),
        backgroundRadius: 10,
      );
      print("sjigjijgij");
      widget.isRefresh(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      dividerColor: Colors.white,
      scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      canvasColor: Theme.of(context).canvasColor,
    );
    final downloadController = Provider.of<AuthState>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Container(
      color: Color(0xff293750),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getWidgetWidth(width: kIsWeb ? 10 : 0),
        ),
        child: AppExpansionTile(
          key: expansionTile,
          onExpansionChanged: widget.onExpansionChanged,
          // titleText: widget.title,
          // onClick: widget.onClick,
          initiallyExpanded: widget.initiallyExpanded,
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 3.8,
            title: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF34425D),
                ),
                // height: 54,
                child: Obx(
                  () => Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // SPW(10),
                      SizedBox(
                        // color: Colors.amber,
                        width: 13,
                        height: getWidgetHeight(height: 40),
                      ),
                      if (!isPlaying[widget.index].value && widget.isWord)
                        InkWell(
                            onTap: () async {
                              print('play iconnnnn tappeddd');
                              pronunciationLabReport(
                                  actionType: "listening", word: widget.title);
                              startPractice(actionType: 'listening');
                              print("widgetIndex:${widget.index}");
                              print("check:${widget.title}");
                              _play(widget.index);

                              /*  String? fileUrl = widget.url;
                              wordsFileUrl.add(fileUrl!);
                              FirebaseFirestore firestore = FirebaseFirestore.instance;
                              String userId = await SharedPref.getSavedString('userId');
                              DocumentReference wordFileUrlDocument =
                                  firestore.collection('proFluentEnglishReport').doc(userId);
        
                              await wordFileUrlDocument.update({
                                'WordsTapped': FieldValue.arrayUnion([widget.url]),
                              }).then((_) {
                                print('Link added to Firestore: ${widget.url}');
                              }).catchError((e) {
                                print('Error updating Firestore: $e');
                              });
                              print("fileUrl:${widget.url}");
                              print("sdhhvgfrhngkihri");*/
                            },
                            child: audioLoading[widget.index]
                                    .value //_isAudioLoading
                                // && _currentPLayingIndex == widget.index
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    ))
                                : !_isAudioPlayed
                                    ? Icon(
                                        Icons.info_outline,
                                        color: Colors.red,
                                        size: 25,
                                      )
                                    : ImageIcon(
                                        AssetImage(AllAssets.roundPlay),
                                        color: widget.isFav == 0
                                            ? Colors.white
                                            : Color(0xFF6C63FE),
                                      )
                            // Icon(
                            //     Icons.play_circle_outline,
                            //     color: AppColors.white,
                            //     size: 25,
                            //   ),
                            ),
                      if (isPlaying[widget.index].value && widget.isWord)
                        // if (isPlaying[widget.index].value && widget.isWord && _currentPLayingIndex == widget.index)
                        InkWell(
                            onTap: () {
                              isAllPlaying3 = false;
                              isAllPlaying = false;
                              isPlaying[widget.index].value = false;
                              setState(() {});
                              audioPlayerManager.stop();
                            },
                            child: !_isAudioPlayed
                                ? Icon(
                                    Icons.info_outline,
                                    color: Colors.red,
                                    size: 25,
                                  )
                                : Icon(
                                    Icons.pause_circle_outline,
                                    color: Color(0xFF6C63FE),
                                    size: 25,
                                  )),

                      SPW(10),
                      SizedBox(
                        width: widget.isWord
                            ? displayWidth(context) * 0.48
                            : widget.underContruction
                                ? displayWidth(context) * 0.55
                                : !widget.isButtonsVisible
                                    ? displayWidth(context) * 0.75
                                    : displayWidth(context) * 0.56,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: Keys.fontFamily,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (widget.isButtonsVisible || widget.underContruction)
                        Spacer(),
                      if (widget.isDownloaded != null &&
                          !widget.isDownloaded! &&
                          !widget.isCheckBoxDownloading &&
                          !_isDownloading &&
                          widget.isButtonsVisible &&
                          !kIsWeb)
                        InkWell(
                            onTap: () async {
                              if (_isConnected) {
                                setState(() {
                                  log("downloading startttt");
                                  print(
                                      "widget.isDownloaded:${widget.isDownloaded}");
                                  // _isDownloading = true;
                                  widget.isCheckBoxDownloading = true;
                                });
                                var dbRef;
                                if (widget.isWord) {
                                  print("widger.isWord:${widget.isWord}");
                                  print("snjdndfnfkndk");
                                  DatabaseProvider dbb = DatabaseProvider.get;
                                  dbRef = WordsDatabaseRepository(dbb);
                                } else {
                                  print("sndkndnvkndkvncknvkcn");
                                  SentDatabaseProvider dbb =
                                      SentDatabaseProvider.get;
                                  dbRef = SentencesDatabaseRepository(dbb);
                                }
                                Directory appDocDir =
                                    await getApplicationDocumentsDirectory();
                                String appDocPath = appDocDir.path;
                                final downloadController =
                                    Provider.of<AuthState>(context,
                                        listen: false);
                                String localPath = await Utils.downloadFile(
                                    downloadController,
                                    url!,
                                    '${widget.title}.mp3',
                                    '$appDocPath/${widget.load}');
                                AuthState userDatas = Provider.of<AuthState>(
                                    context,
                                    listen: false);

                                String eLocalPath = EncryptData.encryptFile(
                                    localPath, userDatas);
                                try {
                                  await File(localPath).delete();
                                } catch (e) {
                                  print("The Expection is :$e");
                                }

                                if (localPath == "Error code: 403" ||
                                    !downloadController.isDownloaded!) {
                                  Toast.show("Failed to Download",
                                      duration: Toast.lengthShort,
                                      gravity: Toast.bottom,
                                      backgroundColor: AppColors.white,
                                      textStyle:
                                          TextStyle(color: AppColors.black),
                                      backgroundRadius: 10);
                                  widget.isRefresh(true);
                                } else {
                                  print("dnnfdknfkdnf");
                                  bool isFaved = await dbRef.setDownloadPath(
                                      widget.wordId, eLocalPath!);
                                  setState(() {
                                    _isDownloading = false;
                                  });
                                  if (isFaved)
                                    Toast.show("File downloaded",
                                        duration: Toast.lengthShort,
                                        gravity: Toast.bottom,
                                        backgroundColor: AppColors.white,
                                        textStyle:
                                            TextStyle(color: AppColors.black),
                                        backgroundRadius: 10);
                                  widget.isRefresh(true);
                                }
                              } else {
                                Toast.show("No network connection",
                                    duration: Toast.lengthShort,
                                    gravity: Toast.bottom,
                                    backgroundColor: AppColors.white,
                                    textStyle:
                                        TextStyle(color: AppColors.black),
                                    backgroundRadius: 10);
                              }
                            },
                            child: SizedBox(
                              // width: displayWidth(context) / 18.75,
                              // height: displayHeight(context) / 40.6,
                              height: 19,
                              width: 19,
                              child: ImageIcon(
                                AssetImage(AllAssets.download),
                                color: Colors.white,
                                // size: size.height * 0.03,
                              ),
                            )
                            //  Icon(
                            //   Icons.file_download,
                            //   color: AppColors.white,
                            // ),
                            ),
                      if (widget.isCheckBoxDownloading)
                        Row(
                          children: [
                            SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      if (widget.isDownloaded != null &&
                          widget.isDownloaded! &&
                          widget.isButtonsVisible &&
                          !kIsWeb)
                        InkWell(
                          child: SizedBox(
                            // width: displayWidth(context) / 18.75,
                            // height: displayHeight(context) / 40.6,
                            height: 19,
                            width: 19,
                            child: Icon(
                              Icons.file_download_done,
                              color: Color(0xFF6C63FE),
                            ),
                          ),
                        ),
                      if (!_isDownloading && widget.isButtonsVisible && !kIsWeb)
                        IconButton(
                            icon: SizedBox(
                              // width: displayWidth(context) / 18.75,
                              // height: displayHeight(context) / 40.6,
                              height: 19,
                              width: 19,
                              child: Image.asset(
                                widget.isFav == 0
                                    ? AllAssets.save
                                    : AllAssets.saved,
                                width: 18,
                                color: widget.isFav == 0
                                    ? Colors.white
                                    : Color(0xFF6C63FE),
                              ),
                            ),
                            onPressed: () async {
                              log("priorityListHandling>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                              await _handleFavoriteToggle();
                              // if (widget.isWord == true) {
                              //   loading = true;
                              //   setState(() {
                              //     _isDownloading = true;
                              //   });
                              //   DatabaseProvider dbb = DatabaseProvider.get;
                              //   WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
                              //   if (widget.isFav == null || widget.isFav == 0) {
                              //     Directory appDocDir = await getApplicationDocumentsDirectory();
                              //     String appDocPath = appDocDir.path;
                              //     String localPath = await Utils.downloadFile(url!, '${widget.title}.mp3', '$appDocPath/${widget.load}');

                              //     String eLocalPath = EncryptData.encryptFile(localPath, context);
                              //     try {
                              //       await File(localPath).delete();
                              //     } catch (e) {}

                              //     bool isFaved = await dbRef.setFav(widget.wordId, 1, eLocalPath);
                              //     setState(() {
                              //       _isDownloading = false;
                              //     });
                              //     if (isFaved)
                              //       Toast.show("Added to your priority list",
                              //           duration: Toast.lengthShort,
                              //           gravity: Toast.bottom,
                              //           backgroundColor: AppColors.white,
                              //           textStyle: TextStyle(color: AppColors.black),
                              //           backgroundRadius: 10);
                              //   } else {
                              //     setState(() {
                              //       _isDownloading = true;
                              //     });
                              //     bool isFaved = await dbRef.setFav(widget.wordId, 0, widget.localPath!);
                              //     widget.isFav = isFaved ? 1 : 0;
                              //     setState(() {
                              //       _isDownloading = false;
                              //     });
                              //     if (isFaved) {
                              //       Toast.show("Removed from your priority list",
                              //           duration: Toast.lengthShort,
                              //           gravity: Toast.bottom,
                              //           backgroundColor: AppColors.white,
                              //           textStyle: TextStyle(color: AppColors.black),
                              //           backgroundRadius: 10);
                              //       // try {
                              //       //   File(widget.localPath!).delete();
                              //       // } catch (e) {}
                              //     }
                              //   }
                              // } else {
                              //   SentDatabaseProvider dbb = SentDatabaseProvider.get;
                              //   SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
                              //   if (widget.isFav == null || widget.isFav == 0) {
                              //     Directory appDocDir = await getApplicationDocumentsDirectory();
                              //     String appDocPath = appDocDir.path;
                              //     String localPath = await Utils.downloadFile(url!, '${widget.title}.mp3', '$appDocPath/${widget.load}');

                              //     String eLocalPath = EncryptData.encryptFile(localPath, context);
                              //     try {
                              //       await File(localPath).delete();
                              //     } catch (e) {}

                              //     bool isFaved = await dbRef.setFav(widget.wordId, 1, eLocalPath);
                              //     if (isFaved)
                              //       Toast.show("Added to your priority list",
                              //           duration: Toast.lengthShort,
                              //           gravity: Toast.bottom,
                              //           backgroundColor: AppColors.white,
                              //           textStyle: TextStyle(color: AppColors.black),
                              //           backgroundRadius: 10);
                              //   } else {
                              //     bool isFaved = await dbRef.setFav(widget.wordId, 0, widget.localPath!);
                              //     if (isFaved) {
                              //       Toast.show("Removed from your priority list",
                              //           duration: Toast.lengthShort,
                              //           gravity: Toast.bottom,
                              //           backgroundColor: AppColors.white,
                              //           textStyle: TextStyle(color: AppColors.black),
                              //           backgroundRadius: 10);
                              //       try {
                              //         // File(widget.localPath!).delete();
                              //       } catch (e) {}
                              //     }
                              //   }
                              // }
                              // widget.isRefresh(true);
                              // loading = false;
                              // setState(() {});
                            }),
                      if (_isDownloading && widget.isButtonsVisible || loading)
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      if (widget.underContruction)
                        InkWell(
                          child: Image.asset(
                            AllAssets.workInProgress,
                            // color: AppColors.white,
                            width: 45,
                            height: 45,
                          ),
                        ),
                      if (_isDownloading || widget.underContruction) SPW(15),
                    ],
                  ),
                ),
              ),
            ),
          ),
          children: widget.children,
        ),
      ),
    );
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTile extends StatefulWidget {
  const AppExpansionTile({
    Key? key,
    this.leading,
    required this.title,
    this.backgroundColor,
    //this.onClick,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    // this.titleText,
    this.initiallyExpanded = false,
  }) : super(key: key);

  final Widget? leading;
  final Widget title;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool initiallyExpanded;

  // final String titleText;
  // final Function(String) onClick;

  @override
  AppExpansionTileState createState() => new AppExpansionTileState();
}

class AppExpansionTileState extends State<AppExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _easeOutAnimation;
  late CurvedAnimation _easeInAnimation;
  late ColorTween _borderColor;
  late ColorTween _headerColor;
  late ColorTween _iconColor;
  late ColorTween _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation =
        new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _borderColor = new ColorTween();
    _headerColor = new ColorTween();
    _iconColor = new ColorTween();

    _backgroundColor = new ColorTween();

    _isExpanded =
        PageStorage.of(context)!.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void expand() {
    _setExpanded(true);
  }

  void collapse() {
    _setExpanded(false);
  }

  void toggle() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool isExpanded) {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        if (_isExpanded)
          _controller.forward();
        else
          _controller.reverse().then((value) {
            setState(() {});
          });
        PageStorage.of(context)!.writeState(context, _isExpanded);
      });
      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    }
    print("Expansion Happening");
  }

  Widget _buildChildren(BuildContext? context, Widget? child) {
    final Color? titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      // margin: EdgeInsets.zero,
      decoration: new BoxDecoration(
        color:
            _backgroundColor.evaluate(_easeOutAnimation) ?? Colors.transparent,
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Color(0xFF293750),
            // margin: EdgeInsets.symmetric(vertical: 1),
            child: IconTheme.merge(
              data: new IconThemeData(
                  color: _iconColor.evaluate(_easeInAnimation)),
              child: GestureDetector(
                onTap: toggle,
                child: DefaultTextStyle(
                  style: Theme.of(context!)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: titleColor),
                  child: widget.title,
                ),
              ),
            ),
          ),
          new ClipRect(
            child: new Align(
              heightFactor: _easeInAnimation.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _borderColor.end = theme.dividerColor;
    _headerColor
      ..begin = theme.textTheme.headlineMedium?.color
      ..end = theme.primaryColor;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.primaryColor;
    _backgroundColor.end = widget.backgroundColor;
    if (!widget.initiallyExpanded) {
      _controller.reverse().then((value) {});
    }

    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : new Column(children: widget.children),
    );
  }
}
