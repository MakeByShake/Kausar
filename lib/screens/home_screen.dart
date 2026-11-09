import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../widgets/garden_view.dart';
import '../widgets/juicy.dart';
import 'dhikr_list_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _popId;

  void _grow() {
    final it = game.nextItem;
    if (it == null) return;
    final done = game.grow(it);
    setState(() => _popId = it.id);
    if (done) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _celebrate();
      });
    }
  }

  void _celebrate() {
    final l = game.lang;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF3C4), Color(0xFFFFD36E)]), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white, width: 4)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌴✨', style: TextStyle(fontSize: 56)).animate().scale(curve: Curves.elasticOut, duration: 900.ms),
            const SizedBox(height: 8),
            Text(tr('garden_done', l), textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF8A4B00))),
            const SizedBox(height: 4),
            Text(tr('next_garden', l), style: const TextStyle(fontSize: 16, color: Color(0xFF8A4B00))),
            const SizedBox(height: 16),
            JuicyButton(
              colors: const [Color(0xFF5BE38B), Color(0xFF1FB35B)],
              shadow: const Color(0xFF128A43),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()));
              },
              child: Text(tr('map', l)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final l = game.lang;
        final g = game.garden;
        final next = game.nextItem;
        return Scaffold(
          body: Stack(children: [
            // Низ экрана закрыт карточками, поэтому сцена сада занимает
            // верхнюю часть, а снизу просто продолжается трава.
            Positioned.fill(child: ColoredBox(color: g.theme.hillFront)),
            Positioned(top: 0, left: 0, right: 0, bottom: 210, child: GardenView(garden: g, owned: game.owned, popId: _popId)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(children: [
                    Pill(icon: '💧', text: '${game.drops}'),
                    const SizedBox(width: 8),
                    Pill(icon: '🔥', text: '${game.streak}', color: const Color(0xFFFF7043)),
                    const Spacer(),
                    _round(l == Lang.kz ? 'KZ' : 'RU', game.toggleLang),
                    const SizedBox(width: 8),
                    _round('🗺', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))),
                  ]),
                  const SizedBox(height: 10),
                  _title(l == Lang.kz ? g.kz : g.ru, game.gardenProgress(game.currentGarden)),
                  const Spacer(),
                  if (next != null) _growCard(next.cost, l == Lang.kz ? next.kz : next.ru, l),
                  const SizedBox(height: 12),
                  JuicyButton(
                    colors: const [Color(0xFF4FE0D0), Color(0xFF14A99A)],
                    shadow: const Color(0xFF0C7D72),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DhikrListScreen())),
                    child: Text('📿  ${tr('dhikrs', l)}', style: const TextStyle(fontSize: 24)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1, end: 1.04, duration: 1200.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onLongPress: game.demoBonus,
                    child: Text(tr('reminder', l), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, shadows: [Shadow(blurRadius: 4, color: Colors.black54)])),
                  ),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _round(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFFFB13B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Color(0xFFD9740A), offset: Offset(0, 4))]),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
        ),
      );

  Widget _title(String name, double progress) => Container(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .85), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white, width: 3)),
        child: Column(children: [
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0C7D72))),
          const SizedBox(height: 6),
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: const Color(0xFFDDEFEA), color: const Color(0xFF2CCB6F)),
            ),
          ),
        ]),
      );

  Widget _growCard(int cost, String name, Lang l) {
    final can = game.drops >= cost;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))]),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2E4A47))),
            Text(can ? '💧 $cost' : '💧 $cost · ${tr('need', l)}', style: TextStyle(color: can ? const Color(0xFF14A99A) : Colors.redAccent, fontWeight: FontWeight.w700)),
          ]),
        ),
        JuicyButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          colors: const [Color(0xFF7BE36B), Color(0xFF34B44A)],
          shadow: const Color(0xFF23853A),
          onTap: can ? _grow : null,
          child: Text('🌱 ${tr('grow', l)}', style: const TextStyle(fontSize: 17)),
        ),
      ]),
    );
  }
}
