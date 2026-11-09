import 'dart:math';
import 'package:flutter/material.dart';
import '../data/gardens.dart';

/// Рисует сад кодом (без картинок), чтобы демо работало сразу.
/// Потом каждый тип предмета можно заменить на нарисованный спрайт/Rive.
class GardenPainter extends CustomPainter {
  GardenPainter({required this.garden, required this.owned, required this.t, required this.popId, required this.pop});

  final Garden garden;
  final Set<String> owned;
  final double t; // 0..1, крутится по кругу: качание, блики
  final String? popId; // только что выращенный предмет
  final double pop; // 0..1 анимация появления

  @override
  void paint(Canvas c, Size s) {
    final th = garden.theme;
    // Небо
    c.drawRect(Offset.zero & s,
        Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: th.sky).createShader(Offset.zero & s));
    // Солнце со свечением
    final sun = Offset(s.width * .8, s.height * .16);
    c.drawCircle(sun, s.width * .16, Paint()..color = Colors.white.withValues(alpha: .25));
    c.drawCircle(sun, s.width * .09, Paint()..color = const Color(0xFFFFF3B0));
    // Облака
    for (var i = 0; i < 3; i++) {
      final x = ((t + i / 3) % 1) * (s.width + 160) - 80;
      _cloud(c, Offset(x, s.height * (.1 + i * .08)), s.width * .1);
    }
    // Холмы
    _hill(c, s, s.height * .55, th.hillBack, .9);
    _hill(c, s, s.height * .64, th.hillFront, 1.3);

    final items = garden.items.where((i) => owned.contains(i.id)).toList()
      ..sort((a, b) => _layer(a).compareTo(_layer(b)));
    for (final it in items) {
      final k = it.id == popId ? Curves.elasticOut.transform(pop.clamp(0, 1)) : 1.0;
      if (k <= 0) continue;
      final p = Offset(it.pos.dx * s.width, it.pos.dy * s.height);
      final u = s.width * .1 * it.scale; // базовый размер
      c.save();
      c.translate(p.dx, p.dy);
      c.scale(k, k);
      _item(c, it, u, s);
      c.restore();
    }
    // Искорки
    final rnd = Random(7);
    for (var i = 0; i < 14; i++) {
      final ph = (t * 2 + rnd.nextDouble()) % 1;
      final a = sin(ph * pi);
      c.drawCircle(Offset(rnd.nextDouble() * s.width, s.height * (.2 + rnd.nextDouble() * .5) - ph * 30), 2.2,
          Paint()..color = Colors.white.withValues(alpha: a * .8));
    }
  }

  // Плоские предметы (трава, вода) рисуем первыми, остальное по глубине.
  double _layer(GardenItem i) => switch (i.kind) {
        ItemKind.grass => -2,
        ItemKind.stream => -1,
        ItemKind.bridge => -.5,
        _ => i.pos.dy,
      };

  void _cloud(Canvas c, Offset o, double r) {
    final p = Paint()..color = Colors.white.withValues(alpha: .9);
    c.drawCircle(o, r, p);
    c.drawCircle(o + Offset(r * .9, r * .2), r * .8, p);
    c.drawCircle(o + Offset(-r * .9, r * .25), r * .7, p);
  }

  void _hill(Canvas c, Size s, double y, Color col, double f) {
    final path = Path()..moveTo(0, y);
    for (double x = 0; x <= s.width; x += 8) {
      path.lineTo(x, y + sin(x / s.width * pi * f + 1) * 18);
    }
    path
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_light(col), col]).createShader(Rect.fromLTWH(0, y - 20, s.width, s.height - y)));
  }

  Color _light(Color c) => Color.lerp(c, Colors.white, .25)!;
  Color _dark(Color c) => Color.lerp(c, Colors.black, .2)!;

  void _shadow(Canvas c, double w) =>
      c.drawOval(Rect.fromCenter(center: const Offset(0, 2), width: w, height: w * .28), Paint()..color = Colors.black.withValues(alpha: .15));

  void _ball(Canvas c, Offset o, double r, Color col) {
    c.drawCircle(o, r,
        Paint()..shader = RadialGradient(center: const Alignment(-.4, -.5), colors: [_light(_light(col)), col, _dark(col)], stops: const [0, .6, 1]).createShader(Rect.fromCircle(center: o, radius: r)));
  }

  void _item(Canvas c, GardenItem it, double u, Size s) {
    final sway = sin(t * 2 * pi + it.pos.dx * 10) * .04;
    switch (it.kind) {
      case ItemKind.grass:
        final p = Paint()..color = const Color(0xFF3DBA4E);
        for (var i = -12; i <= 12; i++) {
          final x = i * s.width / 26;
          final h = 10 + (i * 37 % 9).abs().toDouble();
          c.drawPath(Path()..moveTo(x - 4, 0)..quadraticBezierTo(x + sin(t * 2 * pi + i) * 3, -h, x + 4, 0), p);
        }
      case ItemKind.flower:
        _shadow(c, u * .5);
        c.drawLine(Offset.zero, Offset(sway * 40, -u * .6), Paint()..color = const Color(0xFF2E9E44)..strokeWidth = 3);
        final head = Offset(sway * 40, -u * .62);
        for (var i = 0; i < 6; i++) {
          final a = i * pi / 3 + t * .5;
          _ball(c, head + Offset(cos(a), sin(a)) * u * .16, u * .13, it.color);
        }
        _ball(c, head, u * .1, const Color(0xFFFFD23F));
      case ItemKind.bush:
        _shadow(c, u * 1.2);
        _ball(c, Offset(-u * .3, -u * .3), u * .35, const Color(0xFF35B04A));
        _ball(c, Offset(u * .3, -u * .3), u * .35, const Color(0xFF35B04A));
        _ball(c, Offset(0, -u * .55), u * .4, const Color(0xFF43C457));
        _ball(c, Offset(-u * .15, -u * .55), u * .07, const Color(0xFFFF4D6D));
        _ball(c, Offset(u * .25, -u * .35), u * .07, const Color(0xFFFF4D6D));
      case ItemKind.tree:
        _shadow(c, u * 1.4);
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-u * .1, -u * 1.1, u * .2, u * 1.1), const Radius.circular(6)), Paint()..color = const Color(0xFF9B5B2E));
        c.save();
        c.rotate(sway);
        _ball(c, Offset(0, -u * 1.5), u * .6, const Color(0xFF2FBF5A));
        _ball(c, Offset(-u * .45, -u * 1.15), u * .42, const Color(0xFF27AE50));
        _ball(c, Offset(u * .45, -u * 1.15), u * .42, const Color(0xFF27AE50));
        for (final o in [Offset(-u * .3, -u * 1.6), Offset(u * .25, -u * 1.3), Offset(u * .05, -u * 1.85)]) {
          _ball(c, o, u * .09, const Color(0xFFFF5A5F));
        }
        c.restore();
      case ItemKind.palm:
        _shadow(c, u * 1.2);
        final trunk = Path()..moveTo(-u * .1, 0)..quadraticBezierTo(u * .1, -u, u * .15, -u * 2)..lineTo(u * .3, -u * 2)..quadraticBezierTo(u * .25, -u, u * .1, 0)..close();
        c.drawPath(trunk, Paint()..color = const Color(0xFFB07A45));
        final top = Offset(u * .22, -u * 2);
        c.save();
        c.translate(top.dx, top.dy);
        c.rotate(sway);
        for (var i = 0; i < 6; i++) {
          final a = -pi + i * pi / 5;
          final leaf = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(cos(a - .3) * u * .6, sin(a - .3) * u * .6 - u * .2, cos(a) * u * .95, sin(a) * u * .6 + u * .15)
            ..quadraticBezierTo(cos(a + .3) * u * .5, sin(a + .3) * u * .5, 0, 0);
          c.drawPath(leaf, Paint()..color = i.isEven ? const Color(0xFF2DB55D) : const Color(0xFF45CC6E));
        }
        for (var i = 0; i < 4; i++) {
          _ball(c, Offset((i - 1.5) * u * .1, u * .1), u * .07, const Color(0xFF8B3A1E));
        }
        c.restore();
      case ItemKind.stream:
        final w = s.width;
        final path = Path()
          ..moveTo(-w * .55, u * .4)
          ..cubicTo(-w * .2, -u * .2, w * .1, u * .8, w * .55, u * .1)
          ..lineTo(w * .55, u * .5)
          ..cubicTo(w * .1, u * 1.2, -w * .2, u * .2, -w * .55, u * .8)
          ..close();
        c.drawPath(path, Paint()..shader = const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF81E8FF), Color(0xFF29B6F6)]).createShader(Rect.fromLTWH(-w / 2, -u, w, u * 2)));
        for (var i = 0; i < 6; i++) {
          final x = ((t + i / 6) % 1) * w - w / 2;
          c.drawLine(Offset(x, u * .45), Offset(x + 16, u * .45), Paint()..color = Colors.white.withValues(alpha: .7)..strokeWidth = 2.5..strokeCap = StrokeCap.round);
        }
      case ItemKind.bridge:
        final p = Paint()..color = const Color(0xFFC98A4B)..style = PaintingStyle.stroke..strokeWidth = u * .22..strokeCap = StrokeCap.round;
        c.drawArc(Rect.fromCenter(center: Offset(0, u * .5), width: u * 2.2, height: u * 1.2), pi, pi, false, p);
        c.drawArc(Rect.fromCenter(center: Offset(0, u * .3), width: u * 2.2, height: u * 1.2), pi, pi, false, Paint()..color = const Color(0xFFE8B070)..style = PaintingStyle.stroke..strokeWidth = 4);
      case ItemKind.fountain:
        _shadow(c, u * 1.4);
        c.drawOval(Rect.fromCenter(center: const Offset(0, -6), width: u * 1.4, height: u * .4), Paint()..color = const Color(0xFFE9E2F5));
        c.drawOval(Rect.fromCenter(center: const Offset(0, -8), width: u * 1.1, height: u * .26), Paint()..color = const Color(0xFF6FD3FF));
        c.drawRect(Rect.fromLTWH(-u * .08, -u * .8, u * .16, u * .75), Paint()..color = const Color(0xFFE9E2F5));
        for (var i = 0; i < 8; i++) {
          final ph = (t * 3 + i / 8) % 1;
          final x = (i - 3.5) * u * .1 * ph * 2;
          final y = -u * .8 - sin(ph * pi) * u * .5;
          c.drawCircle(Offset(x, y), 3, Paint()..color = const Color(0xFF9BE7FF));
        }
      case ItemKind.lantern:
        c.drawLine(Offset.zero, Offset(0, -u * .9), Paint()..color = const Color(0xFF5D4037)..strokeWidth = 3);
        final glow = .5 + sin(t * 2 * pi * 2) * .2;
        c.drawCircle(Offset(0, -u * .95), u * .35, Paint()..color = const Color(0xFFFFE082).withValues(alpha: glow * .5));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -u * .95), width: u * .26, height: u * .34), const Radius.circular(6)), Paint()..color = const Color(0xFFFFC107));
      case ItemKind.pavilion:
        _shadow(c, u * 2.2);
        for (final x in [-u * .8, u * .8]) {
          c.drawRect(Rect.fromLTWH(x - u * .07, -u * 1.2, u * .14, u * 1.2), Paint()..color = const Color(0xFFFFF4E0));
        }
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-u, -u * .1, u * 2, u * .14), const Radius.circular(4)), Paint()..color = const Color(0xFFEBD9B8));
        final roof = Path()..moveTo(-u * 1.1, -u * 1.2)..quadraticBezierTo(0, -u * 2.4, u * 1.1, -u * 1.2)..close();
        c.drawPath(roof, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3FD1C1), Color(0xFF1E9E8F)]).createShader(Rect.fromLTWH(-u, -u * 2.4, u * 2, u * 1.2)));
        _ball(c, Offset(0, -u * 1.85), u * .1, const Color(0xFFFFD23F));
      case ItemKind.dome:
        _shadow(c, u * 3);
        c.drawRect(Rect.fromLTWH(-u * 1.2, -u * 1.2, u * 2.4, u * 1.2), Paint()..color = const Color(0xFFFFF4E0));
        for (var i = -1; i <= 1; i++) {
          c.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(i * u * .7 - u * .2, -u * .9, u * .4, u * .9), topLeft: Radius.circular(u * .2), topRight: Radius.circular(u * .2)), Paint()..color = const Color(0xFF5C6BC0));
        }
        c.drawArc(Rect.fromCenter(center: Offset(0, -u * 1.2), width: u * 1.8, height: u * 1.8), pi, pi, true,
            Paint()..shader = const RadialGradient(center: Alignment(-.4, -.6), colors: [Color(0xFFFFF1A8), Color(0xFFFFC23F), Color(0xFFE09A00)]).createShader(Rect.fromCircle(center: Offset(0, -u * 1.2), radius: u)));
        for (final x in [-u * 1.4, u * 1.4]) {
          c.drawRect(Rect.fromLTWH(x - u * .12, -u * 2, u * .24, u * 2), Paint()..color = const Color(0xFFFFF4E0));
          _ball(c, Offset(x, -u * 2.05), u * .18, const Color(0xFFFFC23F));
        }
    }
  }

  @override
  bool shouldRepaint(covariant GardenPainter o) => true;
}
