import 'dart:math';
import 'package:flutter/material.dart';
import '../data/gardens.dart';
import 'garden_effects.dart';
import 'sprites.dart';

/// Живой сад из слоёв: небо → солнце/луна → облака → дальние холмы →
/// ближние холмы → предметы (спрайты) → эффекты. Слои слегка «дышат»
/// (параллакс), растения качаются, новый предмет прорастает в три стадии.
class GardenView extends StatefulWidget {
  const GardenView({super.key, required this.garden, required this.owned, this.popId});
  final Garden garden;
  final Set<String> owned;
  final String? popId;

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  late final AnimationController _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000), value: 1);

  @override
  void didUpdateWidget(covariant GardenView old) {
    super.didUpdateWidget(old);
    if (widget.popId != null && widget.popId != old.popId) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _loop.dispose();
    _pop.dispose();
    super.dispose();
  }

  GardenItem? get _popItem {
    for (final it in widget.garden.items) {
      if (it.id == widget.popId) return it;
    }
    return null;
  }

  /// Дальние предметы чуть меньше ближних.
  double _depth(GardenItem it) => .82 + ((it.pos.dy - .48) / .4).clamp(0.0, 1.0) * .22;

  double _unit(GardenItem it, double w) => w * .13 * it.scale * _depth(it);

  /// Плоские предметы (трава, вода) снизу, остальное по глубине.
  double _layer(GardenItem i) => switch (i.kind) {
        ItemKind.grass => -2,
        ItemKind.stream => -1,
        ItemKind.bridge => -.5,
        _ => i.pos.dy,
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth, h = box.maxHeight;
      return AnimatedBuilder(
        animation: Listenable.merge([_loop, _pop]),
        builder: (_, _) {
          final t = _loop.value;
          final th = widget.garden.theme;
          final drift = sin(t * 2 * pi);
          final items = widget.garden.items.where((i) => widget.owned.contains(i.id)).toList()
            ..sort((a, b) => _layer(a).compareTo(_layer(b)));
          return ClipRect(
            child: Stack(children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: th.sky)),
                ),
              ),
              _celestial(th, w, h),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _effects(t, w, background: true)))),
              for (var i = 0; i < 3; i++) _cloud(i, t, w, h, th.time == Daytime.night ? .45 : 1),
              _hills(back: true, color: th.hillBack, top: h * .50, dx: drift * 8, w: w, h: h),
              _hills(back: false, color: th.hillFront, top: h * .60, dx: -drift * 14, w: w, h: h),
              for (final it in items) _item(it, t, w, h),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _effects(t, w)))),
            ]),
          );
        },
      );
    });
  }

  GardenEffectsPainter _effects(double t, double w, {bool background = false}) => GardenEffectsPainter(
        garden: widget.garden,
        owned: widget.owned,
        t: t,
        popItem: _popItem,
        pop: _pop.value,
        unit: (it) => _unit(it, w),
        background: background,
      );

  Widget _celestial(GardenTheme th, double w, double h) {
    switch (th.time) {
      case Daytime.day:
        final s = w * .38;
        return Positioned(left: w * .8 - s / 2, top: h * .16 - s / 2, child: Sprites.widget('sun', width: s, height: s));
      case Daytime.sunset:
        final s = w * .56;
        return Positioned(left: w * .5 - s / 2, top: h * .42 - s / 2, child: Sprites.widget('sun', width: s, height: s));
      case Daytime.night:
        final s = w * .36;
        return Positioned(left: w * .78 - s / 2, top: h * .15 - s / 2, child: Sprites.widget('moon', width: s, height: s));
    }
  }

  Widget _cloud(int i, double t, double w, double h, double opacity) {
    final cw = w * (.26 + i * .04);
    final x = ((t * 1.4 + i / 3) % 1) * (w + cw) - cw;
    return Positioned(
      left: x,
      top: h * (.06 + i * .075),
      child: Opacity(opacity: opacity, child: Sprites.widget('cloud', width: cw, height: cw / 2)),
    );
  }

  Widget _hills({required bool back, required Color color, required double top, required double dx, required double w, required double h}) {
    final ww = w + 48;
    // Пропорции файла (400×100), но не выше 60% доступного места,
    // иначе на широком экране холм не влезает.
    final hh = min(Sprites.heightFor('hills_back', ww), (h - top) * .6);
    return Positioned(
      left: -24 + dx,
      top: top,
      width: ww,
      height: h - top + 4, // с запасом вниз, чтобы не было щели на стыке со сценой
      child: Column(children: [
        Sprites.widget(back ? 'hills_back' : 'hills_front', width: ww, height: hh, fit: BoxFit.fill, color: color),
        Expanded(child: ColoredBox(color: color, child: const SizedBox.expand())),
      ]),
    );
  }

  Widget _item(GardenItem it, double t, double w, double h) {
    final u = _unit(it, w);
    final p = Offset(it.pos.dx * w, it.pos.dy * h);

    // Рост нового предмета: росток → половина → готово, каждый этап «выпрыгивает».
    var state = 3;
    var scale = 1.0;
    if (it.id == widget.popId && _pop.value < 1) {
      final seg = (_pop.value * 3).floor().clamp(0, 2);
      final local = (_pop.value * 3 - seg).clamp(0.0, 1.0);
      state = seg + 1;
      scale = .55 + .45 * Curves.elasticOut.transform(local);
    }
    final file = Sprites.fileFor(it.kind, state);

    // Трава и ручей тянутся на всю ширину сцены.
    if (it.kind == ItemKind.grass && state == 3 || it.kind == ItemKind.stream && state == 3) {
      final sw = w * 1.1;
      final sh = u * (it.kind == ItemKind.grass ? .8 : 1.2);
      final top = it.kind == ItemKind.grass ? p.dy - sh + u * .2 : p.dy - sh * .55;
      return Positioned(
        left: p.dx - sw / 2,
        top: top,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: Sprites.widget(file, width: sw, height: sh, fit: BoxFit.fill, color: it.color),
        ),
      );
    }

    final baseWidthU = Sprites.widthU[it.kind] ?? 1.6;
    final widthU = switch (state) {
      1 => Sprites.plants.contains(it.kind) ? .9 : max(1.2, baseWidthU * .6),
      2 when it.kind == ItemKind.grass => 5.0,
      2 when it.kind == ItemKind.stream => 7.0,
      _ => baseWidthU,
    };
    final sw = u * widthU;
    final sh = Sprites.heightFor(file, sw);
    final anchorDown = it.kind == ItemKind.bridge ? u * .55 : 0.0;
    final sways = Sprites.plants.contains(it.kind) && it.kind != ItemKind.grass;
    final angle = sways ? sin(t * 2 * pi * 1.5 + it.pos.dx * 10) * .025 : 0.0;

    return Positioned(
      left: p.dx - sw / 2,
      top: p.dy + anchorDown - sh,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..scaleByDouble(scale, scale, 1, 1)
          ..rotateZ(angle),
        child: Sprites.widget(file, width: sw, height: sh, color: it.color),
      ),
    );
  }
}
