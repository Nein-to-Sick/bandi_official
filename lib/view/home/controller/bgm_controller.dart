import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BgmController with WidgetsBindingObserver, ChangeNotifier {
  final AssetsAudioPlayer _player = AssetsAudioPlayer.withId('bgm');

  bool speakerOn = true;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    speakerOn = prefs.getBool('speakerOn') ?? true;

    try {
      await _player.stop();
    } catch (_) {}

    await _player.open(
      Audio("assets/bgm/bgm.mp3"),
      loopMode: LoopMode.single,
      autoStart: speakerOn,
      showNotification: false,
    );

    notifyListeners();
  }

  Future<void> setSpeakerOn(bool on) async {
    speakerOn = on;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('speakerOn', on);

    if (speakerOn) {
      await _player.play();
    } else {
      await _player.pause();
    }

    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    if (state == AppLifecycleState.resumed) {
      if (speakerOn) {
        _player.play();
      }
    } else {
      _player.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.stop();
    _player.dispose();
    super.dispose();
  }
}
