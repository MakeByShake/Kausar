import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:kausar/logic/tap_guard.dart';

void main() {
  test('тапы быстрее лимита не засчитываются', () {
    final g = TapGuard();
    expect(g.tap(nowMs: 0, pos: const Point(10, 10), minIntervalMs: 1000), TapResult.counted);
    expect(g.tap(nowMs: 500, pos: const Point(10, 10), minIntervalMs: 1000), TapResult.tooFast);
    expect(g.tap(nowMs: 1000, pos: const Point(10, 10), minIntervalMs: 1000), TapResult.counted);
  });

  test('идеально ровные тапы в одну точку = автотапер', () {
    final g = TapGuard();
    TapResult r = TapResult.counted;
    for (var i = 0; i < 30 && r != TapResult.suspicious; i++) {
      r = g.tap(nowMs: i * 1000, pos: const Point(50, 50), minIntervalMs: 1000);
    }
    expect(r, TapResult.suspicious);
    expect(g.locked, isTrue);
    g.unlock();
    expect(g.tap(nowMs: 100000, pos: const Point(50, 50), minIntervalMs: 1000), TapResult.counted);
  });

  test('живой человек не блокируется', () {
    final g = TapGuard();
    final rnd = Random(1);
    var t = 0;
    for (var i = 0; i < 200; i++) {
      t += 1000 + rnd.nextInt(400);
      final r = g.tap(nowMs: t, pos: Point(100 + rnd.nextDouble() * 40, 300 + rnd.nextDouble() * 40), minIntervalMs: 1000);
      expect(r, TapResult.counted);
    }
  });
}
