import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BgmController with WidgetsBindingObserver, ChangeNotifier {
  final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();
  bool speakerOn = true;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    speakerOn = prefs.getBool('speakerOn') ?? true;

    _player.open(
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
      _player.play();
    } else {
      _player.pause();
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    if (state == AppLifecycleState.paused) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed && speakerOn) {
      _player.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}
