import 'dart:developer' as dev;

import 'package:audioplayers/audioplayers.dart';

class AlarmService {
  // Created on the first alarm, so the audio plugin is not touched until a
  // timer rings (and tests that never ring one need no audio plugin).
  AudioPlayer? _audioPlayer;
  AudioPlayer get _player => _audioPlayer ??= AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> play() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/alarm.mp3'));
      _isPlaying = true;
    } catch (e, st) {
      dev.log('AlarmService: failed to play alarm', error: e, stackTrace: st);
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer?.stop().timeout(const Duration(milliseconds: 200));
      _isPlaying = false;
    } catch (e, st) {
      dev.log('AlarmService: failed to stop alarm', error: e, stackTrace: st);
      _isPlaying = false;
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
  }
}
