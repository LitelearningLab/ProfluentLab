import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/database/WordsDatabaseRepository.dart';
import 'package:litelearninglab/database/databaseProvider.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/audio_player_manager.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:litelearninglab/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

AudioPlayerManager audioPlayerManager = AudioPlayerManager();
List<RxBool> isPlaying1 = List.generate(100, (_) => false.obs);

enum PlayingRouteState { speakers, earpiece }

class DropDownWordItemProluentEnglish extends StatefulWidget {
  DropDownWordItemProluentEnglish({
    Key? key,
    this.onTapForThreePlayerStop,
    required this.children,
    this.icon,
    required this.title,
    required this.maintitle,
    required this.url,
    required this.isWord,
    this.wordId,
    this.localPath,
    required this.initiallyExpanded,
    required this.index,
    this.length,
    this.load,
    required this.isRefresh,
    this.onExpansionChanged,
    this.isFav = 0,
    this.onClick,
    this.isDownloaded,
    this.isCheckBoxDownloading = false,
    this.isButtonsVisible = true,
    this.underContruction = false,
    this.mode = PlayerMode.mediaPlayer,
    required this.onFavoriteToggle,
  }) : super(key: key);

  final List<Widget> children;
  final String title;
  final String? icon;
  final String maintitle;
  final String url;
  final String? localPath;
  String? load;
  final bool isWord;
  int isFav;
  final int index;
  int? length;
  bool? isDownloaded;
  bool isCheckBoxDownloading;
  final bool underContruction;
  int? wordId;
  final PlayerMode mode;
  final Function(bool) isRefresh;
  final bool initiallyExpanded;
  final bool isButtonsVisible;
  final Function(String)? onClick;
  final ValueChanged<bool>? onExpansionChanged;
  Function()? onTapForThreePlayerStop;
  final Function(int, int) onFavoriteToggle;

  @override
  State<DropDownWordItemProluentEnglish> createState() {
    return _DropDownWordItemProluentEnglishState(url, mode);
  }
}

class _DropDownWordItemProluentEnglishState
    extends State<DropDownWordItemProluentEnglish> {
  String? url;
  PlayerMode? mode;
  bool loading = false;
  bool _isDownloading = false;
  bool _isPlaying = false;
  bool _isAudioLoading = false;
  bool _isAudioPlayed = true;
  late StreamSubscription _playerStateSubscription;
  bool _isConnected = true;
  StreamSubscription? networkSubscription;

  late bool isDownloaded;
  late int isFav;
  late bool isButtonsVisible;
  late bool isCheckBoxDownloading;

  final GlobalKey<AppExpansionTileProfluentWordScreenState> expansionTile =
      new GlobalKey();

  final Connectivity connectivity = Connectivity();

  _DropDownWordItemProluentEnglishState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _playerStateSubscription =
        audioPlayerManager.onPlayerStateChanged.listen((event) async {
      Future.delayed(const Duration(seconds: 2), () {
        log("This was Triggered");
        return isPlaying1[widget.index].value = false;
      });
    });

    initConnectivity();

    networkSubscription =
        Connectivity().onConnectivityChanged.listen((connectionResult) {
      checkConnection(connectionResult as ConnectivityResult);
    });
    isDownloaded = widget.isDownloaded!;
    isFav = widget.isFav;
    isButtonsVisible = widget.isButtonsVisible;
    isCheckBoxDownloading = widget.isCheckBoxDownloading;
  }

  @override
  void didUpdateWidget(DropDownWordItemProluentEnglish oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isPlaying1[widget.index].value) {
      isPlaying1[widget.index].value = true;
    } else {
      isPlaying1[widget.index].value = false;
    }
  }

  @override
  void dispose() {
    if (url != null) {
      _playerStateSubscription.cancel();
    }
    super.dispose();
  }

  Future<void> initConnectivity() async {
    try {
      var result = await connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        setState(() {
          _isConnected = false;
        });
      } else {
        setState(() {
          _isConnected = true;
        });
      }
    } catch (e) {
      print('Connection Init Error : $e');
    }
  }

  Future<void> checkConnection(ConnectivityResult connectivityResult) async {
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
    }
  }

  Future _toggleWordFavorite(String? eLocalPath) async {
    bool favIs;
    bool isFaved;
    if (isFav == 0) {
      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
      isFaved = await dbRef.setFav(widget.wordId!, 1, eLocalPath!);
      favIs = true;
      isFav = 1;
      widget.onFavoriteToggle(widget.index, isFav);
      // setState(() {});
      print('toggle inside is fav==0');
    } else {
      DatabaseProvider dbb = DatabaseProvider.get;
      WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
      print('toggle inside is fav==1');
      isFaved = await dbRef.setFav(widget.wordId!, 0, widget.localPath ?? "");
      print("isFaved>>>>>>");
      log("${isFaved}");
      isFav = 0;
      widget.onFavoriteToggle(widget.index, isFav);
      // setState(() {});
      print('isfaved:$isFaved');
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

  Future<void> _handleFavoriteToggle() async {
    setState(() {
      _isDownloading = true;
      // loading = true;
    });
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);

    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String? localPath;
      String? eLocalPath;

      if (isFav == null || isFav == 0) {
        localPath = await Utils.downloadFile(userDatas, url!,
            '${widget.title}.mp3', '$appDocPath/${widget.load}');
        eLocalPath = EncryptData.encryptFile(localPath, userDatas);

        try {
          await File(localPath).delete();
        } catch (e) {
          // Log or handle error
        }

        if (userDatas.isDownloaded!) {
          DatabaseProvider dbb = DatabaseProvider.get;
          WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
          bool isFaved =
              await dbRef.setDownloadPath(widget.wordId!, eLocalPath);
          setState(() {
            _isDownloading = false;
          });
          if (isFaved) {
            isDownloaded = true;
            setState(() {});
            isCheckBoxDownloading = false;
            setState(() {});

            widget.isRefresh(true);
          }
        }
      }

      if (widget.isWord) {
        log("entering the word thing>>");
        await _toggleWordFavorite(eLocalPath);
      } else {}
      log("isFav>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      log('${isFav}');
      // if (isFaved) {
      //   Toast.show(
      //     isFav == 1 ? "Removed from your priority list" : "Added to your priority list",
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

  Future<void> _play(int index) async {
    final audioController = Provider.of<AuthState>(context, listen: false);

    setState(() {
      _isAudioLoading = true;
      _isAudioPlayed = true;
    });

    log("play button clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>22222");
    isAllPlaying3 = false;
    isAllPlaying = false;
    setState(() {});
    String? eLocalPath;
    await audioPlayerManager.stop();

    setState(() {
      _isAudioLoading = true;
    });

    await audioPlayerManager.play(url!,
        context: context, localPath: widget.localPath, decodedPath: (val) {
      eLocalPath = val;
    });

    setState(() {
      _isAudioLoading = false;
      _isAudioPlayed = audioController.isAudioDone!;
    });

    int previousIndex = isPlaying1.indexWhere((element) => element.value);
    if (previousIndex != -1) {
      isPlaying1[previousIndex].value = false;
    }
    isPlaying1[widget.index].value = true;

    FirebaseHelper db = FirebaseHelper();
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    String company = await SharedPref.getSavedString("companyId");
    String batch = await SharedPref.getSavedString("batch");
    db.saveWordListReport(
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

    if (eLocalPath != null && eLocalPath!.isNotEmpty) {
      try {
        await File(eLocalPath!).delete();
      } catch (e) {}
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

      print(
          "response start practice for pronunciation labbb : ${response.body}");
    } catch (e) {
      print("error login : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.white);
    final downloadController = Provider.of<AuthState>(context, listen: false);
    return Theme(
      data: theme,
      child: AppExpansionTileProfluentWordScreen(
        key: expansionTile,
        onExpansionChanged: widget.onExpansionChanged,
        initiallyExpanded: widget.initiallyExpanded,
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 3.8,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF34425D),
              ),
              height: 54,
              child: Obx(
                () => Row(
                  children: [
                    SizedBox(width: 13),
                    if (!isPlaying1[widget.index].value && widget.isWord)
                      InkWell(
                        onTap: () {
                          print("playyyyy buttonnn tapppppeddddd>>>>>>>>>>>");
                          startPractice(actionType: 'listening');
                          _play(widget.index);
                        },
                        child: _isAudioLoading
                            ? SizedBox(
                                height: 25,
                                width: 25,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                ),
                              )
                            : !_isAudioPlayed
                                ? Icon(
                                    Icons.info_outline,
                                    color: Colors.red,
                                    size: 25,
                                  )
                                : ImageIcon(
                                    AssetImage(AllAssets.roundPlay),
                                    color: isFav == 0
                                        ? Colors.white
                                        : Color(0xFF6C63FE),
                                  ),
                      ),
                    if (isPlaying1[widget.index].value)
                      InkWell(
                        onTap: () {
                          audioPlayerManager.stop();
                          setState(() {
                            isPlaying1[widget.index].value = false;
                          });
                        },
                        child: Icon(
                          Icons.pause_circle_outline,
                          color: Color(0xFF6C63FE),
                          size: 26,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (isButtonsVisible || widget.underContruction) Spacer(),
                    if (isDownloaded != null &&
                        !isDownloaded &&
                        !isCheckBoxDownloading &&
                        !_isDownloading &&
                        isButtonsVisible &&
                        !kIsWeb)
                      InkWell(
                          onTap: () async {
                            if (_isConnected) {
                              setState(() {
                                log("downloading start");
                                // _isDownloading = true;
                                isCheckBoxDownloading = true;
                              });
                              DatabaseProvider dbb = DatabaseProvider.get;
                              WordsDatabaseRepository dbRef =
                                  WordsDatabaseRepository(dbb);
                              Directory appDocDir =
                                  await getApplicationDocumentsDirectory();
                              String appDocPath = appDocDir.path;
                              AuthState userDatas = Provider.of<AuthState>(
                                  context,
                                  listen: false);

                              String localPath = await Utils.downloadFile(
                                  userDatas,
                                  url!,
                                  '${widget.title}.mp3',
                                  '$appDocPath/${widget.load}');

                              String eLocalPath =
                                  EncryptData.encryptFile(localPath, userDatas);
                              try {
                                await File(localPath).delete();
                              } catch (e) {
                                print(e);
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
                                bool isFaved = await dbRef.setDownloadPath(
                                    widget.wordId!, eLocalPath);
                                setState(() {
                                  _isDownloading = false;
                                });
                                if (isFaved) {
                                  isDownloaded = true;
                                  isCheckBoxDownloading = false;
                                  setState(() {});
                                  Toast.show("File downloaded",
                                      duration: Toast.lengthShort,
                                      gravity: Toast.bottom,
                                      backgroundColor: AppColors.white,
                                      textStyle:
                                          TextStyle(color: AppColors.black),
                                      backgroundRadius: 10);
                                  widget.isRefresh(true);
                                }
                              }
                            } else {
                              Toast.show("No network connection",
                                  duration: Toast.lengthShort,
                                  gravity: Toast.bottom,
                                  backgroundColor: AppColors.white,
                                  textStyle: TextStyle(color: AppColors.black),
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
                    if (isCheckBoxDownloading)
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
                    if (isDownloaded != null &&
                        isDownloaded &&
                        isButtonsVisible &&
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
                    if (!_isDownloading && isButtonsVisible && !kIsWeb)
                      IconButton(
                          icon: SizedBox(
                            // width: displayWidth(context) / 18.75,
                            // height: displayHeight(context) / 40.6,
                            height: 19,
                            width: 19,
                            child: Image.asset(
                              isFav == 0 ? AllAssets.save : AllAssets.saved,
                              width: 18,
                              color:
                                  isFav == 0 ? Colors.white : Color(0xFF6C63FE),
                            ),
                          ),
                          onPressed: () async {
                            log("priorityListHandling>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                            await _handleFavoriteToggle();
                            // if (widget.isWord == true) {
                            //   loading = true;
                            //   setState(() {
                            //     _isDownloading = true;
                            //   });
                            //   DatabaseProvider dbb = DatabaseProvider.get;
                            //   WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
                            //   if (isFav == null || isFav == 0) {
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
                            //     isFav = isFaved ? 1 : 0;
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
                            //   if (isFav == null || isFav == 0) {
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
                    if (_isDownloading && isButtonsVisible || loading)
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
                    // Spacer(),
                    // Row(
                    //   children: [
                    //     // GestureDetector(
                    //     //   onTap: () async {
                    //     //     try {
                    //     //       // DatabaseHelper helper = DatabaseHelper.instance;
                    //     //       // await helper.removeWordFromFav(widget.wordId!);
                    //     //       setState(() {
                    //     //         isFav = 0;
                    //     //       });
                    //     //       widget.isRefresh(true);
                    //     //       Toast.show("Word Removed from Favourite", duration: Toast.lengthLong, gravity: Toast.bottom);
                    //     //     } catch (e) {}
                    //     //   },
                    //     //   child: Icon(
                    //     //     isFav == 1 ? Icons.star : Icons.star_border_outlined,
                    //     //     color: Color(0xFFFFC107),
                    //     //   ),
                    //     // ),

                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
        children: widget.children,
      ),
    );
  }
}

const Duration _kExpand = const Duration(milliseconds: 200);

class AppExpansionTileProfluentWordScreen extends StatefulWidget {
  const AppExpansionTileProfluentWordScreen({
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

  @override
  State<AppExpansionTileProfluentWordScreen> createState() =>
      AppExpansionTileProfluentWordScreenState();
}

class AppExpansionTileProfluentWordScreenState
    extends State<AppExpansionTileProfluentWordScreen>
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
        PageStorage.of(context).readState(context) ?? widget.initiallyExpanded;
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
    print("Expansion Happening app expansion title profluent english");
  }

  Widget _buildChildren(BuildContext? context, Widget? child) {
    final Color? titleColor = _headerColor.evaluate(_easeInAnimation);

    return new Container(
      margin: EdgeInsets.zero,
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
