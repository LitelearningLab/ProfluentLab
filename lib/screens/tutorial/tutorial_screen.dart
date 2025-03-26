import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litelearninglab/screens/webview/widgets/videoplayer_controller.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../common_widgets/background_widget.dart';

class TutorialScreen extends StatefulWidget {
  TutorialScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _TutorialScreenState createState() {
    return _TutorialScreenState();
  }
}

class _TutorialScreenState extends State<TutorialScreen> with AfterLayoutMixin<TutorialScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isBackShow = false;
  bool _isPlaying = false;

  double _currentSliderValue = 0.0;

  bool videoInitialized = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeVideoPlayerFuture = initVideoPlayer(url: widget.url);
  }

  Future<void> initVideoPlayer({required String url}) async {
    print("urlCheck:${url}");
    //_controller = VideoPlayerController.networkUrl(Uri.parse(url));
    DataSourceType.asset;
    _controller = VideoPlayerController.asset(url);

    initializeChewieController();
  }

  void initializeChewieController() async {
    await _controller.initialize().whenComplete(() {
      _chewieController = ChewieController(
        errorBuilder: (context, errorMessage) => Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Playback error!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        )),
        customControls: CustomFastTrackController(),
        videoPlayerController: _controller,
        autoInitialize: true,
        showControlsOnInitialize: false,
        autoPlay: true,
        showOptions: true,
        showControls: true,
        allowFullScreen: false,
        fullScreenByDefault: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
            playedColor: Colors.white,
            bufferedColor: Color(0XFFD6D6D6),
            backgroundColor: Colors.grey,
            handleColor: Colors.grey),
        cupertinoProgressColors: ChewieProgressColors(
            playedColor: Colors.white,
            bufferedColor: Color(0XFFD6D6D6),
            backgroundColor: Colors.grey,
            handleColor: Colors.grey),
      );
      videoInitialized = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    _resetOrientation();
    super.dispose();
  }

  void _resetOrientation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _onSliderValueChanged(double value) {
    setState(() {
      _currentSliderValue = value;
      _controller.seekTo(Duration(seconds: value.toInt()));
    });
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _controller.play();
  }

  String formatDuration(Duration duration) {
    var remaining = duration - _controller.value.position;
    String minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didpop) async {
        _resetOrientation();
      },
      child: BackgroundWidget(
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _isBackShow = !_isBackShow;
                          setState(() {});
                        },
                        child: SizedBox(
                            width: displayWidth(context),
                            height: displayHeight(context),
                            child: videoInitialized == false
                                ? Center(
                                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Colors.white),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Loading...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ))
                                : Chewie(controller: _chewieController)),
                      ),
                      Positioned(
                          top: 20,
                          //left: 20,
                          right: 20,
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: IconButton(
                                onPressed: () async {
                                  _resetOrientation();
                                  AuthState authState = Provider.of<AuthState>(context, listen: false);
                                  await SharedPref.saveBool("tutorialchecking", true);
                                  authState.checkAuthChanging();
                                  authState.checkAuthStatus();
                                },
                                icon: Icon(Icons.arrow_forward_outlined)),
                          )),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
