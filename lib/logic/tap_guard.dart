import 'dart:math';

/// ВРЕМЕННО для демо: true — лимит скорости и детектор автотапера выключены,
/// любой тап засчитывается. Перед релизом обязательно вернуть false.
const bool debugDisableTapGuard = true;

/// Результат проверки одного тапа.
enum TapResult { counted, tooFast, suspicious }

/// Защита от спама и автотаперов.
/// 1) Тап засчитывается не чаще, чем раз в [minIntervalMs].
/// 2) Если последние тапы идут с почти одинаковым ритмом и в одну и ту же
///    точку экрана, это похоже на автотапер: счёт ставится на паузу,
///    пока человек не подтвердит, что он здесь.
class TapGuard {
  TapGuard({this.window = 25, this.rhythmJitterMs = 12, this.positionJitterPx = 2, this.enabled = !debugDisableTapGuard});

  /// false — защита отключена (см. [debugDisableTapGuard]). Тесты передают true явно.
  final bool enabled;
  final int window;
  final double rhythmJitterMs;
  final double positionJitterPx;

  final List<int> _times = [];
  final List<Point<double>> _points = [];
  int? _lastCounted;
  bool locked = false;

  TapResult tap({required int nowMs, required Point<double> pos, required int minIntervalMs}) {
    if (!enabled) return TapResult.counted;
    if (locked) return TapResult.suspicious;
    if (_lastCounted != null && nowMs - _lastCounted! < minIntervalMs) {
      return TapResult.tooFast;
    }
    _lastCounted = nowMs;
    _times.add(nowMs);
    _points.add(pos);
    if (_times.length > window) {
      _times.removeAt(0);
      _points.removeAt(0);
    }
    if (_looksAutomated()) {
      locked = true;
      return TapResult.suspicious;
    }
    return TapResult.counted;
  }

  bool _looksAutomated() {
    if (_times.length < window) return false;
    final gaps = <int>[];
    for (var i = 1; i < _times.length; i++) {
      gaps.add(_times[i] - _times[i - 1]);
    }
    final mean = gaps.reduce((a, b) => a + b) / gaps.length;
    final sd = sqrt(gaps.map((g) => pow(g - mean, 2)).reduce((a, b) => a + b) / gaps.length);
    final p0 = _points.first;
    final samePlace = _points.every((p) => (p.x - p0.x).abs() <= positionJitterPx && (p.y - p0.y).abs() <= positionJitterPx);
    // Человек не может тапать с разбросом меньше ~12 мс, да ещё в один пиксель.
    return sd < rhythmJitterMs && samePlace;
  }

  void unlock() {
    locked = false;
    _times.clear();
    _points.clear();
  }
}
