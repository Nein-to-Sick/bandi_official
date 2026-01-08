import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BgmController with WidgetsBindingObserver, ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  bool speakerOn = true;
  bool _initialized = false;

  bool _syncing = false; // 동기화 루프 중인지

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    final prefs = await SharedPreferences.getInstance();
    speakerOn = prefs.getBool('speakerOn') ?? true;

    try { await _player.stop(); } catch (_) {}

    await _player.setAsset('assets/bgm/bgm.mp3');
    await _player.setLoopMode(LoopMode.one);

    // 초기 상태 반영
    _requestSync();

    notifyListeners();
  }

  Future<void> setSpeakerOn(bool on) async {
    // 1) UI 즉시 반영
    speakerOn = on;
    notifyListeners();

    // 2) prefs 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('speakerOn', on);

    // 3) 오디오 동기화 요청
    _requestSync();
  }

  void _requestSync() {
    if (_syncing) return;
    _syncing = true;
    unawaited(_syncLoop());
  }

  Future<void> _syncLoop() async {
    try {
      // speakerOn이 바뀌는 동안 계속 마지막 상태로 맞춤
      while (true) {
        final desired = speakerOn;

        // 이미 원하는 상태면 종료
        if (desired == _player.playing) break;

        if (desired) {
          // ✅ play()는 await하지 않음 (여기가 핵심)
          _player.play();
        } else {
          // pause는 빨리 끝나므로 await OK
          await _player.pause();
        }

        // 방금 처리 중에 또 토글됐으면 루프 한 번 더
        if (desired == speakerOn) break;
      }
    } catch (_) {
      // 오디오 에러가 나도 UI는 유지
    } finally {
      _syncing = false;

      // sync 끝난 직후에 값이 또 바뀌었으면 다시 한 번
      if (speakerOn != _player.playing) {
        _requestSync();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    if (state == AppLifecycleState.resumed) {
      if (speakerOn) _player.play();
    } else {
      _player.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}
