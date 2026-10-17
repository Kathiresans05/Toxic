import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  bool _isPlaying = false;
  Timer? _vibrateTimer;

  bool get isPlaying => _isPlaying;

  void startRingtone() {
    if (_isPlaying) return;
    _isPlaying = true;

    // Play native ringtone looping
    FlutterRingtonePlayer().playRingtone(looping: true);

    // Vibrate every 2 seconds
    _vibrateTimer?.cancel();
    _vibrateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isPlaying) {
        HapticFeedback.vibrate();
      } else {
        timer.cancel();
      }
    });
  }

  void stopRingtone() {
    _isPlaying = false;
    FlutterRingtonePlayer().stop();
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
  }
}
