import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/dhikrs.dart';
import '../l10n/strings.dart';
import '../logic/tap_guard.dart';
import '../main.dart';
import '../widgets/juicy.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key, required this.dhikr});
  final Dhikr dhikr;
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _Drop {
  _Drop(this.pos, this.key);
  final Offset pos;
  final int key;
}

class _TasbihScreenState extends State<TasbihScreen> {
  final _guard = TapGuard();
  int _count = 0;
  int _bump = 0;
  bool _tooFast = false;
  final _drops = <_Drop>[];
  int _dropKey = 0;

  Dhikr get d => widget.dhikr;

  void _onTap(TapDownDetails e) {
    final r = _guard.tap(nowMs: DateTime.now().millisecondsSinceEpoch, pos: Point(e.localPosition.dx, e.localPosition.dy), minIntervalMs: d.minIntervalMs);
    switch (r) {
      case TapResult.tooFast:
        setState(() => _tooFast = true);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _tooFast = false);
        });
      case TapResult.suspicious:
        _askHuman();
      case TapResult.counted:
        HapticFeedback.lightImpact();
        game.addDhikr(d.id, d.drops);
        final k = ++_dropKey;
        setState(() {
          _count++;
          _bump++;
          _drops.add(_Drop(e.localPosition, k));
        });
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) setState(() => _drops.removeWhere((x) => x.key == k));
        });
        if (_count == d.target) HapticFeedback.heavyImpact();
    }
  }

  void _askHuman() {
    final l = game.lang;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(tr('locked_title', l)),
        content: Text(tr('locked_body', l)),
        actions: [
          TextButton(
            onPressed: () {
              _guard.unlock();
              Navigator.pop(context);
            },
            child: Text(tr('i_am_here', l)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = game.lang;
    final progress = min(_count / d.target, 1.0);
    final done = _count >= d.target;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.2), radius: 1.2, colors: [Color(0xFF5FF0DC), Color(0xFF0E8F84)])),
        child: SafeArea(
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30)),
              const Spacer(),
              ListenableBuilder(listenable: game, builder: (_, _) => Pill(icon: '💧', text: '${game.drops}')),
              const SizedBox(width: 12),
            ]),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _onTap,
                child: Stack(children: [
                  Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(d.arabic, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 34, color: Colors.white, height: 1.7, shadows: [Shadow(color: Colors.black26, blurRadius: 6)])),
                      ),
                      Text(d.translit, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                        child: Text(l == Lang.kz ? d.kz : d.ru, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: Stack(alignment: Alignment.center, children: [
                          SizedBox.expand(child: CircularProgressIndicator(value: progress, strokeWidth: 14, strokeCap: StrokeCap.round, backgroundColor: Colors.white24, color: done ? const Color(0xFFFFD23F) : Colors.white)),
                          Container(
                            width: 168,
                            height: 168,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE07A), Color(0xFFFFA92E)]), border: Border.all(color: Colors.white, width: 5), boxShadow: const [BoxShadow(color: Color(0xFFD9740A), offset: Offset(0, 8)), BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 12))]),
                            child: Text('$_count', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white, shadows: [Shadow(color: Color(0xFFB85C00), offset: Offset(0, 3))])),
                          ).animate(key: ValueKey(_bump)).scaleXY(begin: .9, end: 1, duration: 260.ms, curve: Curves.elasticOut),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Text(done ? tr('done', l) : '${tr('tap_hint', l)} · ×${d.target}', style: TextStyle(color: done ? const Color(0xFFFFF3B0) : Colors.white, fontWeight: FontWeight.w800, fontSize: done ? 20 : 15)),
                      const SizedBox(height: 8),
                      AnimatedOpacity(opacity: _tooFast ? 1 : 0, duration: 150.ms, child: Text(tr('too_fast', l), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(l == Lang.kz ? d.virtueKz : d.virtueRu, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13)),
                      ),
                    ]),
                  ),
                  for (final dr in _drops)
                    Positioned(
                      key: ValueKey(dr.key),
                      left: dr.pos.dx - 24,
                      top: dr.pos.dy - 24,
                      child: Text('💧+${d.drops}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)).animate().moveY(begin: 0, end: -90, duration: 850.ms, curve: Curves.easeOut).fadeOut(delay: 400.ms, duration: 450.ms).scaleXY(begin: .6, end: 1.2, duration: 300.ms, curve: Curves.easeOutBack),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
