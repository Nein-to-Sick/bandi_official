import 'package:flutter/material.dart';

class TutorialTargetRegistry extends ChangeNotifier {
  final Map<String, GlobalKey> _keys = {};
  final Map<String, Rect> _rects = {};

  void register(String id, GlobalKey key) {
    _keys[id] = key;
  }

  void unregister(String id) {
    _keys.remove(id);
    _rects.remove(id);
  }

  Rect? rectOf(String id) => _rects[id];

  void refreshAll() {
    var changed = false;

    for (final entry in _keys.entries) {
      final id = entry.key;
      final key = entry.value;

      final ctx = key.currentContext;
      if (ctx == null) continue;

      final ro = ctx.findRenderObject();
      if (ro is! RenderBox || !ro.hasSize) continue;

      final pos = ro.localToGlobal(Offset.zero);
      final rect = pos & ro.size;

      final prev = _rects[id];
      if (prev == null || prev != rect) {
        _rects[id] = rect;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  void clear() {
    _keys.clear();
    _rects.clear();
    notifyListeners();
  }
}
