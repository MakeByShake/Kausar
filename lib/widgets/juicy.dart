import 'package:flutter/material.dart';

/// «Сочная» кнопка в стиле казуальных игр: градиент, толстая нижняя тень,
/// нажимается вниз.
class JuicyButton extends StatefulWidget {
  const JuicyButton({super.key, required this.child, required this.onTap, this.colors = const [Color(0xFFFFC94D), Color(0xFFFF9F1C)], this.shadow = const Color(0xFFD9740A), this.radius = 26, this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16)});
  final Widget child;
  final VoidCallback? onTap;
  final List<Color> colors;
  final Color shadow;
  final double radius;
  final EdgeInsets padding;

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final colors = disabled ? [Colors.grey.shade300, Colors.grey.shade400] : widget.colors;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _down ? 5 : 0, bottom: _down ? 0 : 5),
        padding: widget.padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: disabled ? Colors.grey.shade500 : widget.shadow, offset: Offset(0, _down ? 1 : 6)), const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 8))],
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, shadows: [Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 2)]),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Плашка-счётчик сверху (капли, стрик).
class Pill extends StatelessWidget {
  const Pill({super.key, required this.icon, required this.text, this.color = const Color(0xFF29B6F6)});
  final String icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .28), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white70, width: 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Text(icon, style: const TextStyle(fontSize: 15))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
      ]),
    );
  }
}
