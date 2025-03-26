import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litelearninglab/screens/webview/widgets/videoplayer_controller.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:video_player/video_player.dart';

import '../../common_widgets/background_widget.dart';
import 'dart:developer';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _VideoPlayerScreenState createState() {
    return _VideoPlayerScreenState();
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with AfterLayoutMixin<VideoPlayerScreen>, WidgetsBindingObserver {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isBackShow = false;
  bool _isPlaying = false;

  double _currentSliderValue = 0.0;

  bool videoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Add the observer for lifecycle events
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayerFuture = initVideoPlayer(url: widget.url);
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);

    _controller.dispose();
    _chewieController.dispose();
    _resetOrientation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Print statements based on the app's lifecycle state
    switch (state) {
      case AppLifecycleState.paused:
        log("User navigated to another app or attended a call.");
        break;
      case AppLifecycleState.resumed:
        log("User returned to the app.");
        break;
      case AppLifecycleState.inactive:
        log("App is inactive (e.g., during a phone call).");
        break;
      case AppLifecycleState.detached:
        log("App is closed or detached.");
        break;
    }
  }

  Future<void> initVideoPlayer({required String url}) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
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
        materialProgressColors:
            ChewieProgressColors(playedColor: Colors.white, bufferedColor: Color(0XFFD6D6D6), backgroundColor: Colors.grey, handleColor: Colors.grey),
        cupertinoProgressColors:
            ChewieProgressColors(playedColor: Colors.white, bufferedColor: Color(0XFFD6D6D6), backgroundColor: Colors.grey, handleColor: Colors.grey),
      );
      videoInitialized = true;
      setState(() {});
    });
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
        body: FutureBuilder(
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
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: IconButton(
                            onPressed: () {
                              _resetOrientation();
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back)),
                      )),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            }
          },
        ),
      ),
    );
  }
}
