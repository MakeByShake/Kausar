import 'dart:math';
import 'package:flutter/material.dart';
import '../data/gardens.dart';

/// Лёгкие эффекты поверх спрайтов: искорки/звёзды, блики на воде,
/// струи фонтана, свет фонарей, капли при появлении нового предмета.
class GardenEffectsPainter extends CustomPainter {
  GardenEffectsPainter({
    required this.garden,
    required this.owned,
    required this.t,
    required this.popItem,
    required this.pop,
    required this.unit,
    this.background = false,
  });

  final Garden garden;
  final Set<String> owned;
  final double t; // 0..1 по кругу
  final GardenItem? popItem;
  final double pop; // 0..1 анимация роста нового предмета
  final double Function(GardenItem) unit; // базовый размер предмета в пикселях
  final bool background; // true — только небо (звёзды/искорки), под предметами

  @override
  void paint(Canvas c, Size s) {
    if (background) {
      garden.theme.time == Daytime.night ? _stars(c, s) : _sparkles(c, s);
      return;
    }
    for (final it in garden.items.where((i) => owned.contains(i.id))) {
      final p = Offset(it.pos.dx * s.width, it.pos.dy * s.height);
      final u = unit(it);
      switch (it.kind) {
        case ItemKind.stream:
          _shimmer(c, s, p, u);
        case ItemKind.fountain:
          if (it.id != popItem?.id || pop > .7) _fountain(c, p, u);
        case ItemKind.lantern:
          if (garden.theme.time != Daytime.day && (it.id != popItem?.id || pop > .7)) _glow(c, p, u);
        default:
          break;
      }
    }
    if (popItem != null && pop < .45) {
      _rain(c, s, popItem!, unit(popItem!));
    }
  }

  void _sparkles(Canvas c, Size s) {
    final rnd = Random(7);
    for (var i = 0; i < 14; i++) {
      final ph = (t * 2 + rnd.nextDouble()) % 1;
      final a = sin(ph * pi);
      c.drawCircle(Offset(rnd.nextDouble() * s.width, s.height * (.2 + rnd.nextDouble() * .5) - ph * 30), 2.2,
          Paint()..color = Colors.white.withValues(alpha: a * .8));
    }
  }

  void _stars(Canvas c, Size s) {
    final rnd = Random(11);
    for (var i = 0; i < 46; i++) {
      final x = rnd.nextDouble() * s.width;
      final y = rnd.nextDouble() * s.height * .5;
      final tw = .55 + .45 * sin(t * 2 * pi * 3 + i * 1.7);
      final r = 1 + rnd.nextDouble() * 1.6;
      c.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: tw * .9));
      if (r > 2.2) {
        final p = Paint()
          ..color = Colors.white.withValues(alpha: tw * .6)
          ..strokeWidth = 1;
        c.drawLine(Offset(x - r * 2.5, y), Offset(x + r * 2.5, y), p);
        c.drawLine(Offset(x, y - r * 2.5), Offset(x, y + r * 2.5), p);
      }
    }
  }

  void _shimmer(Canvas c, Size s, Offset p, double u) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final x = ((t + i / 7) % 1) * s.width;
      final y = p.dy + sin(x / s.width * pi * 2 + i) * u * .25;
      c.drawLine(Offset(x, y), Offset(x + 14, y), paint);
    }
  }

  void _fountain(Canvas c, Offset p, double u) {
    for (var i = 0; i < 10; i++) {
      final ph = (t * 3 + i / 10) % 1;
      final side = i.isEven ? 1 : -1;
      final x = p.dx + side * u * .35 * ph;
      final y = p.dy - u * 1.1 - sin(ph * pi) * u * .55 + ph * u * .2;
      c.drawCircle(Offset(x, y), 2.6, Paint()..color = const Color(0xFFC9F6FF).withValues(alpha: 1 - ph * .6));
    }
  }

  void _glow(Canvas c, Offset p, double u) {
    final center = Offset(p.dx, p.dy - u * 1.1);
    final a = .22 + sin(t * 2 * pi * 2) * .08;
    final r = u * 1.3;
    c.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(colors: [const Color(0xFFFFE082).withValues(alpha: a), const Color(0xFFFFE082).withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: center, radius: r)));
  }

  /// Капли Каусара падают на место, где растёт новый предмет.
  void _rain(Canvas c, Size s, GardenItem it, double u) {
    final base = Offset(it.pos.dx * s.width, it.pos.dy * s.height);
    final k = (pop / .45).clamp(0.0, 1.0);
    final rnd = Random(it.id.hashCode);
    for (var i = 0; i < 7; i++) {
      final delay = i / 7 * .5;
      final f = ((k - delay) / .5).clamp(0.0, 1.0);
      if (f <= 0) continue;
      final x = base.dx + (rnd.nextDouble() - .5) * u * 1.2;
      final y = base.dy - u * 2.2 + Curves.easeIn.transform(f) * u * 2.2;
      final alpha = f < .85 ? 1.0 : (1 - f) / .15;
      final drop = Path()
        ..moveTo(x, y - 9)
        ..quadraticBezierTo(x + 6, y, x, y + 5)
        ..quadraticBezierTo(x - 6, y, x, y - 9)
        ..close();
      c.drawPath(drop, Paint()..color = const Color(0xFF5ED0FF).withValues(alpha: alpha));
      c.drawCircle(Offset(x - 1.5, y - 2), 1.5, Paint()..color = Colors.white.withValues(alpha: alpha * .8));
      if (f > .85) {
        c.drawCircle(Offset(x, base.dy), (f - .85) / .15 * 10, Paint()
          ..color = Colors.white.withValues(alpha: (1 - f) / .15 * .6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GardenEffectsPainter o) => true;
}
