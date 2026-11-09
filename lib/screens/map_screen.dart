import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/gardens.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../widgets/sprites.dart';

/// Карта садов: тропинка, по которой открываются сады один за другим.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _kinds = [ItemKind.tree, ItemKind.palm, ItemKind.dome];
  static const _soonIcons = ['🌸', '⛲', '🕌'];
  static const _soonRu = ['Сад цветов', 'Сад фонтанов', 'Дворец Фирдаус'];
  static const _soonKz = ['Гүлдер бағы', 'Субұрқақтар бағы', 'Фирдаус сарайы'];

  @override
  Widget build(BuildContext context) {
    final l = game.lang;
    final total = gardens.length + _soonRu.length;
    const step = 170.0;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF8A7BFF), Color(0xFF7FD8FF), Color(0xFF8EE36B)])),
        child: SafeArea(
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30)),
              Text(tr('map', l), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
            ]),
            Expanded(
              child: LayoutBuilder(builder: (context, box) {
                final w = box.maxWidth;
                Offset at(int i) => Offset(w / 2 + sin(i * 1.3) * w * .25, 100 + (total - 1 - i) * step);
                return SingleChildScrollView(
                  reverse: true,
                  child: SizedBox(
                    height: 200 + (total - 1) * step,
                    child: Stack(children: [
                      Positioned.fill(child: CustomPaint(painter: _PathPainter([for (var i = 0; i < total; i++) at(i)]))),
                      for (var i = 0; i < total; i++) _node(context, i, at(i), l),
                    ]),
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _node(BuildContext context, int i, Offset p, Lang l) {
    final real = i < gardens.length;
    final unlocked = real && game.isGardenUnlocked(i);
    final current = real && game.currentGarden == i;
    final done = real && game.isGardenDone(i);
    final name = real ? (l == Lang.kz ? gardens[i].kz : gardens[i].ru) : (l == Lang.kz ? _soonKz : _soonRu)[i - gardens.length];
    Widget circle = Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: unlocked ? (done ? [const Color(0xFFFFE07A), const Color(0xFFFFA92E)] : [const Color(0xFF7BE36B), const Color(0xFF2FA84A)]) : [Colors.grey.shade300, Colors.grey.shade500]),
        border: Border.all(color: Colors.white, width: current ? 6 : 4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .25), offset: const Offset(0, 6))],
      ),
      child: !unlocked
          ? const Text('🔒', style: TextStyle(fontSize: 40))
          : real
              ? Padding(padding: const EdgeInsets.only(top: 6), child: Sprite(kind: _kinds[i % _kinds.length], width: 64))
              : Text(_soonIcons[(i - gardens.length) % _soonIcons.length], style: const TextStyle(fontSize: 40)),
    );
    if (current) {
      circle = circle.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.08, duration: 900.ms);
    }
    return Positioned(
      left: p.dx - 70,
      top: p.dy - 48,
      width: 140,
      child: GestureDetector(
        onTap: () {
          if (unlocked) {
            game.openGarden(i);
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('locked_garden', l))));
          }
        },
        child: Column(children: [
          circle,
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(14)),
            child: Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2E4A47))),
          ),
          if (real && unlocked && !done)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(width: 90, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: game.gardenProgress(i), minHeight: 8, color: const Color(0xFF2CCB6F), backgroundColor: Colors.white54))),
            ),
        ]),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.pts);
  final List<Offset> pts;
  @override
  void paint(Canvas c, Size s) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1], b = pts[i];
      path.cubicTo(a.dx, (a.dy + b.dy) / 2, b.dx, (a.dy + b.dy) / 2, b.dx, b.dy);
    }
    c.drawPath(path, Paint()..color = const Color(0xFFE8C48A)..style = PaintingStyle.stroke..strokeWidth = 26..strokeCap = StrokeCap.round);
    c.drawPath(path, Paint()..color = const Color(0xFFFFE3B0)..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
