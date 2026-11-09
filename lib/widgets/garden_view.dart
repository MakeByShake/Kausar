import 'package:flutter/material.dart';
import '../data/gardens.dart';
import 'garden_painter.dart';

/// Живой сад: всё время слегка качается, новый предмет «выпрыгивает».
class GardenView extends StatefulWidget {
  const GardenView({super.key, required this.garden, required this.owned, this.popId});
  final Garden garden;
  final Set<String> owned;
  final String? popId;

  @override
  State<GardenView> createState() => _GardenViewState();
}

class _GardenViewState extends State<GardenView> with TickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
  late final AnimationController _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1);

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _pop]),
      builder: (_, _) => CustomPaint(
        painter: GardenPainter(garden: widget.garden, owned: widget.owned, t: _loop.value, popId: widget.popId, pop: _pop.value),
        size: Size.infinite,
      ),
    );
  }
}
