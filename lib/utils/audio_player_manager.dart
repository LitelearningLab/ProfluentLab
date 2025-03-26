import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:provider/provider.dart';

import 'encrypt_data.dart';

class AudioPlayerManager {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;
  late StreamSubscription _playerCompleteSubscription;

  // late StreamSubscription _playerStateSubscription;

  Duration? _duration;
  Duration? _position;

  AudioPlayerManager() {
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = (state == PlayerState.playing);
      // Notify listeners or perform any other actions based on the state change.
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
    });

    _positionSubscription = _audioPlayer.onDurationChanged.listen((p) => _position = p);

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      print("completeddddddddd");
      // _playerState = PlayerState.stopped;
      _position = _duration;
    });

    // _playerStateSubscription =
    //     _audioPlayer.onPlayerStateChanged.listen((state) {
    //   // _playerState = state;
    // });
  }

  Future<void> play(
    String url, {
    String? localPath,
    required BuildContext context,
    Function(String)? decodedPath,
  }) async {
    final audioController = Provider.of<AuthState>(context, listen: false);
    var newPth;
    try {
      if (localPath != null && localPath != "ERROR") {
        newPth = EncryptData.decryptFile(localPath, context);
        if (decodedPath != null) {
          decodedPath(newPth);
        }
      }
      print('***********//////AUDIO Done');
      ;
      audioController.isAudioDone = true;
      print("local Path>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(localPath);
      // await _audioPlayer.setPlaybackRate(5);
      return await _audioPlayer
          .play(localPath != null && localPath != "ERROR" ? DeviceFileSource(newPth) : UrlSource(url));
    } catch (e) {
      print('***********//////AUDIO FAILED');
      audioController.isAudioDone = false;
    }
  }

  Future<void> play3(
    String url, {
    String? localPath,
    required BuildContext context,
    Function(String)? decodedPath,
  }) async {
    final audioController = Provider.of<AuthState>(context, listen: false);
    var newPth;
    try {
      if (localPath != null && localPath != "ERROR") {
        newPth = EncryptData.decryptFile(localPath, context);
        if (decodedPath != null) {
          decodedPath(newPth);
        }
      }
      print('***********//////AUDIO Done');
      ;
      audioController.isAudioDone = true;
      print("local Path>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(localPath);
      await _audioPlayer.setPlaybackRate(0.8);
      return await _audioPlayer
          .play(localPath != null && localPath != "ERROR" ? DeviceFileSource(newPth) : UrlSource(url));
    } catch (e) {
      print('***********//////AUDIO FAILED');
      audioController.isAudioDone = false;
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<Duration?> getDuration() async {
    return await _audioPlayer.getDuration();
  }

  Future<Duration?> getCurrentPosition() async {
    return await _audioPlayer.getCurrentPosition();
  }

  bool isPlaying() {
    return _isPlaying;
  }

  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _playerCompleteSubscription.cancel();
    // _playerStateSubscription.cancel();
  }
}
