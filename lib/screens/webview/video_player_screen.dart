import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:litelearninglab/screens/webview/widgets/videoplayer_controller.dart'; // Commented out unused import
// import 'package:litelearninglab/utils/commonfunctions/common_functions.dart'; // Assuming this is defined elsewhere
// import 'package:litelearninglab/utils/sizes_helpers.dart'; // Assuming this is defined elsewhere
import 'package:video_player/video_player.dart';

// Assuming CustomFastTrackController, BackgroundWidget, startTimerMainCategory,
// stopTimerMainCategory, displayWidth, and displayHeight are defined in your project.

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  _VideoPlayerScreenState createState() {
    return _VideoPlayerScreenState();
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with AfterLayoutMixin<VideoPlayerScreen>, WidgetsBindingObserver {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
// ✅ CORRECT late field declaration inside _VideoPlayerScreenState
  late Future<void> _initializeVideoPlayerFuture;
  bool _isBackShow = false;
  // bool _isPlaying = false; // Not needed, rely on _controller.value.isPlaying
  // bool _showingButtons = false; // Not needed, replaced by _isControllerVisible
  bool _isControllerVisible = true; // Start visible for modern look
  Timer? _hideControllerTimer;

  // double _currentSliderValue = 0.0; // Not strictly needed as we use ValueListenableBuilder

  bool videoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Assuming startTimerMainCategory is a globally accessible function
    // startTimerMainCategory("name");
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayerFuture = initVideoPlayer(url: widget.url);

    _showController(); // Start timer to hide controls after initial show
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideControllerTimer?.cancel();
    _controller.dispose();
    _chewieController.dispose();
    _resetOrientation();
    super.dispose();
  }

  // NOTE: showingButton() is removed as the logic is handled by _showController and toggleControllerVisibility.

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
            const Icon(
              Icons.error_outline_outlined,
              color: Colors.white,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Playback error!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        )),
        // Assuming CustomFastTrackController is defined elsewhere
        // customControls: CustomFastTrackController(),
        videoPlayerController: _controller,
        autoInitialize: true,
        showControlsOnInitialize: false,
        autoPlay: true,
        showOptions: true,
        showControls:
            false, // Set this to false to use your custom controls completely
        allowFullScreen: false,
        fullScreenByDefault: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
            playedColor: Colors.white,
            bufferedColor: const Color(0XFFD6D6D6),
            backgroundColor: Colors.grey,
            handleColor: Colors.grey),
        cupertinoProgressColors: ChewieProgressColors(
            playedColor: Colors.white,
            bufferedColor: const Color(0XFFD6D6D6),
            backgroundColor: Colors.grey,
            handleColor: Colors.grey),
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

  // NOTE: _onSliderValueChanged is removed as the slider handling is in the build method now

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _controller.play();
  }

  // Utility function to format Duration as MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void toggleControllerVisibility() {
    if (_isControllerVisible) {
      _hideControllerTimer?.cancel();
      setState(() {
        _isControllerVisible = false;
      });
    } else {
      _showController();
    }
  }

  void _showController() {
    _hideControllerTimer?.cancel();
    setState(() {
      _isControllerVisible = true;
    });

    _hideControllerTimer = Timer(const Duration(seconds: kIsWeb ? 1 : 4), () {
      if (mounted) {
        setState(() {
          _isControllerVisible = false;
        });
      }
    });
  }

  // This function is still useful for resetting the timer after a control action
  void togglePlayPauseControllerVisibility() {
    _showController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didpop) {
        // stopTimerMainCategory(); // Assuming defined elsewhere
        _resetOrientation();
      },
      // Assuming BackgroundWidget is defined elsewhere
      child: Scaffold(
        backgroundColor: Colors.black, // Dark background for video player
        body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !videoInitialized) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Loading video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done &&
                videoInitialized) {
              return MouseRegion(
                onHover: (_) =>
                    _showController(), // mouse move → show UI + reset timer
                onEnter: (_) => _showController(),
                onExit: (_) {
                  setState(() {
                    _isControllerVisible = false;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video Player Area
                    GestureDetector(
                      onTap: toggleControllerVisibility,
                      child: VideoPlayer(_controller),
                    ),

                    // Modern Controls Overlay (Fade in/out)
                    AnimatedOpacity(
                      opacity: _isControllerVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        children: [
                          // --- 1. Central Play/Pause Icon (Large Tap Target) ---
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                                togglePlayPauseControllerVisibility(); // Reset hide timer
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: ValueListenableBuilder<VideoPlayerValue>(
                                  valueListenable: _controller,
                                  builder: (context, value, child) {
                                    return Icon(
                                      value.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 72,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // --- 2. Bottom Control Bar (Timeline and Duration) ---
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              // Use a Gradient for a smoother, modern look
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Current Position Time
                                  ValueListenableBuilder<VideoPlayerValue>(
                                    valueListenable: _controller,
                                    builder: (context, value, child) {
                                      return Text(
                                        _formatDuration(value.position),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      );
                                    },
                                  ),

                                  const SizedBox(width: 8),

                                  // Timeline Slider
                                  Expanded(
                                    child: ValueListenableBuilder<
                                        VideoPlayerValue>(
                                      valueListenable: _controller,
                                      builder: (context, value, child) {
                                        return SliderTheme(
                                          data:
                                              SliderTheme.of(context).copyWith(
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6.0),
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                    overlayRadius: 12.0),
                                            trackHeight: 3.0,
                                            activeTrackColor: Colors.white,
                                            inactiveTrackColor: Colors.white54,
                                            thumbColor: Colors
                                                .redAccent, // Highlight color
                                            overlayColor: Colors.redAccent
                                                .withOpacity(0.3),
                                          ),
                                          child: Slider(
                                            value: value.position.inMilliseconds
                                                .toDouble()
                                                .clamp(
                                                    0.0,
                                                    value
                                                        .duration.inMilliseconds
                                                        .toDouble()),
                                            min: 0,
                                            max: value.duration.inMilliseconds
                                                .toDouble(),
                                            onChanged: (newValue) {
                                              _controller.seekTo(
                                                Duration(
                                                    milliseconds:
                                                        newValue.toInt()),
                                              );
                                              // Keep controls visible while seeking
                                              _showController();
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Total Duration Time
                                  ValueListenableBuilder<VideoPlayerValue>(
                                    valueListenable: _controller,
                                    builder: (context, value, child) {
                                      return Text(
                                        _formatDuration(value.duration),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      );
                                    },
                                  ),

                                  // Fullscreen Button (optional, can be adapted)
                                  // IconButton(
                                  //   icon: const Icon(Icons.fullscreen, color: Colors.white),
                                  //   onPressed: () { /* Handle fullscreen toggle if needed */ },
                                  // ),
                                ],
                              ),
                            ),
                          ),

                          // --- 3. Top Back Button ---
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.3)),
                              child: IconButton(
                                onPressed: () {
                                  // stopTimerMainCategory(); // Assuming defined elsewhere
                                  _resetOrientation();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
          },
        ),
      ),
    );
  }
}

// NOTE: The _formatDuration function in the original code was calculating remaining time.
// I have updated it to calculate current position and total duration, which is standard for video controls.

// The original _formatDuration:
// String _formatDuration(Duration duration) {
//   var remaining = duration - _controller.value.position;
//   String minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
//   String seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
//   return '$minutes:$seconds';
// }

// The new _formatDuration (assuming it is defined in your class scope):
/*
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}
*/
