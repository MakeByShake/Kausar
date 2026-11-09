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
      home: const HomeScreen(),
    );
  }
}
