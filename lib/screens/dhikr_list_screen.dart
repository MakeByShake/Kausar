import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/dhikrs.dart';
import '../l10n/strings.dart';
import '../main.dart';
import 'tasbih_screen.dart';

class DhikrListScreen extends StatelessWidget {
  const DhikrListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = game.lang;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1FB5A6), Color(0xFF7FE0C9)])),
        child: SafeArea(
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30)),
              Text(tr('dhikrs', l), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const Spacer(),
              ListenableBuilder(listenable: game, builder: (_, _) => Padding(padding: const EdgeInsets.only(right: 16), child: Text('${tr('today', l)}: ${game.todayCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))),
            ]),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: dhikrs.length,
                itemBuilder: (context, i) {
                  final d = dhikrs[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TasbihScreen(dhikr: d))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 5), blurRadius: 0)]),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d.arabic, textDirection: TextDirection.rtl, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, color: Color(0xFF0C7D72), height: 1.6)),
                            Text(d.translit, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            Text(l == Lang.kz ? d.kz : d.ru, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700)),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Column(children: [
                          Text('×${d.target}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF9F1C), fontSize: 18)),
                          Text('💧${d.drops}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF29B6F6))),
                        ]),
                      ]),
                    ),
                  ).animate().fadeIn(delay: (40 * i).ms).slideX(begin: .15, curve: Curves.easeOutBack);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
