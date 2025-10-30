import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/database/SentencesDatabaseRepository.dart';
import 'package:litelearninglab/database/WordsDatabaseRepository.dart';
import 'package:litelearninglab/database/databaseProvider.dart';
import 'package:litelearninglab/models/Word.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../utils/audio_player_manager.dart';
import '../../../utils/utils.dart';

AudioPlayerManager audioPlayerManager = AudioPlayerManager();
List<RxBool> isPlaying = [];

enum PlayingRouteState { speakers, earpiece }

class DropDownWordItem extends StatefulWidget {
  DropDownWordItem({
    Key? key,
    required this.onTapForThreePlayerStop,
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
  Function() onTapForThreePlayerStop;
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

  _DropDownWordItemState(this.url, this.mode);

  bool _isConnected = true;
  StreamSubscription? networkSubscription;

  // final _audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    // if (widget.length != null) {
    //   isPlay = List.generate(widget.length!, (index) => false);
    // }
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

  Future<void> checkConnection(
      List<ConnectivityResult> connectivityResult) async {
    connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
    }
    print('<<<<<<<< Is Connected : $_isConnected >>>>>>>>>>>>');
  }

  Future<void> _play(int index) async {
    final audioController = Provider.of<AuthState>(context, listen: false);

    setState(() {
      _isAudioLoading = true;
      _isAudioPlayed = true;
      // _currentPLayingIndex = index;
    });
    widget.onTapForThreePlayerStop;
    log("play button clicked>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    isAllPlaying3 = false;
    isAllPlaying = false;
    setState(() {});
    String? eLocalPath;
    await audioPlayerManager.stop();
    setState(() {
      _isAudioLoading = true;
      // _currentPLayingIndex = index;
    });
    // audioPlayerManager = AudioPlayerManager();
    print("Above the loading value");
    void result = await audioPlayerManager.play(url!,
        context: context, localPath: widget.localPath, decodedPath: (val) {
      eLocalPath = val;
    });
    print("Below the loading value");
    setState(() {
      _isAudioLoading = false;
      _isAudioPlayed = audioController.isAudioDone!;
    });
    int previousIndex = isPlaying.indexWhere((element) => element.value);
    print("previousIndex $previousIndex");
    if (previousIndex != -1) {
      isPlaying[previousIndex].value = false;
    }
    isPlaying[widget.index].value = true;
    FirebaseHelper db = new FirebaseHelper();
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
    return result;
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
        print("dkjfdjfdj");
        final downloadController =
            Provider.of<AuthState>(context, listen: false);
        localPath = await Utils.downloadFile(downloadController, url!,
            '${widget.title}.mp3', '$appDocPath/${widget.load}');
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
    DatabaseProvider dbb = DatabaseProvider.get;
    WordsDatabaseRepository dbRef = WordsDatabaseRepository(dbb);
    bool favIs;
    bool isFaved;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.white);
    final downloadController = Provider.of<AuthState>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Theme(
      data: theme,
      child: AppExpansionTile(
        key: expansionTile,
        onExpansionChanged: widget.onExpansionChanged,
        // titleText: widget.title,
        // onClick: widget.onClick,
        initiallyExpanded: widget.initiallyExpanded,
        title:
            //  Container(
            //   child: Row(
            //     children: [

            //     ],
            //   ),
            // ),
            ListTile(
          contentPadding: EdgeInsets.zero,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF34425D),
              ),
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Obx(
                  () => Row(
                    children: [
                      SPW(10),
                      if (!isPlaying[widget.index].value && widget.isWord)
                        InkWell(
                          onTap: () {
                            _play(widget.index);
                          },
                          child: _isAudioLoading
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
                                  : Icon(
                                      Icons.play_circle_outline,
                                      color: AppColors.white,
                                      size: 25,
                                    ),
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
                      // if (widget.isWord) SPW(10),
                      // Icon(
                      //   Icons.format_list_bulleted,
                      //   color: AppColors.white,
                      // ),
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
                          ),
                        ),
                      ),
                      if (widget.isButtonsVisible || widget.underContruction)
                        Spacer(),
                      if (widget.isDownloaded != null &&
                          !widget.isDownloaded! &&
                          !widget.isCheckBoxDownloading &&
                          !_isDownloading &&
                          widget.isButtonsVisible)
                        InkWell(
                            onTap: () async {
                              if (_isConnected) {
                                setState(() {
                                  log("downloading start");
                                  // _isDownloading = true;
                                  widget.isCheckBoxDownloading = true;
                                });
                                DatabaseProvider dbb = DatabaseProvider.get;
                                WordsDatabaseRepository dbRef =
                                    WordsDatabaseRepository(dbb);
                                Directory appDocDir =
                                    await getApplicationDocumentsDirectory();
                                String appDocPath = appDocDir.path;
                                final downloadController =
                                    Provider.of<AuthState>(context,
                                        listen: false);
                                String localPath = await Utils.downloadFile(
                                    downloadController,
                                    "",
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
                                      widget.wordId, eLocalPath);
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
                              width: displayWidth(context) / 18.75,
                              height: displayHeight(context) / 40.6,
                              child: ImageIcon(
                                AssetImage(AllAssets.download),
                                color: Colors.white,
                                size: size.height * 0.03,
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      if (widget.isDownloaded != null &&
                          widget.isDownloaded! &&
                          widget.isButtonsVisible)
                        InkWell(
                          child: SizedBox(
                            width: displayWidth(context) / 18.75,
                            height: displayHeight(context) / 40.6,
                            child: Icon(
                              Icons.file_download_done,
                              color: Color(0xFF6C63FE),
                            ),
                          ),
                        ),
                      if (!_isDownloading && widget.isButtonsVisible)
                        IconButton(
                            icon: SizedBox(
                              width: displayWidth(context) / 18.75,
                              height: displayHeight(context) / 40.6,
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
                              log("priorityListHandling>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                              await _handleFavoriteToggle();
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
        ),
        children: widget.children,
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
      margin: EdgeInsets.zero,
      decoration: new BoxDecoration(
        color:
            _backgroundColor.evaluate(_easeOutAnimation) ?? Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
