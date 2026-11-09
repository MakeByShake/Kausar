import 'dart:math';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'state/game_state.dart';
import 'widgets/sprites.dart';

final game = GameState();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([game.load(), Sprites.preload()]);
  runApp(const KausarApp());
}

class KausarApp extends StatelessWidget {
  const KausarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kausar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1FB5A6)),
        useMaterial3: true,
      ),
      // Приложение телефонное. В широком окне (веб-демо, планшет) показываем
      // его в рамке шириной с телефон по центру, чтобы сцена не растягивалась.
      builder: (context, child) => LayoutBuilder(builder: (context, box) {
        if (box.maxWidth <= 600) return child!;
        return ColoredBox(
          color: const Color(0xFF0E6B62),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(width: 430, height: min(box.maxHeight, 932), child: child),
            ),
          ),
        );
      }),
      home: const HomeScreen(),
    );
  }
}
