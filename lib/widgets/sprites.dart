import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/gardens.dart';

/// Спрайты сада — SVG в `assets/garden/`, нарисованы сами в стиле clay casual.
///
/// Каждый предмет в трёх состояниях роста: 1 — росток (растения) или
/// фундамент (постройки), 2 — половина, 3 — готово. Файлы называются
/// `<kind>_2.svg`, `<kind>_3.svg`, общие `sprout.svg` и `foundation.svg`.
/// Чтобы заменить графику на рисунки художника, достаточно положить файлы
/// с теми же именами и пропорциями.
class Sprites {
  Sprites._();

  static const dir = 'assets/garden';

  /// Цвета лепестков в flower_*.svg: светлый, основной, тёмный.
  /// Подменяются на цвет конкретного цветка (GardenItem.color).
  static const petalPlaceholders = ['#FFA8D1', '#FF6FB1', '#C9407F'];

  /// Цвет холмов в hills_*.svg, подменяется на цвет темы сада.
  static const hillPlaceholder = '#4CC85A';

  static const plants = {ItemKind.grass, ItemKind.flower, ItemKind.bush, ItemKind.tree, ItemKind.palm};

  /// Ширина спрайта в единицах `u` (u = 10% ширины сцены × scale предмета).
  /// Трава и ручей тянутся на всю ширину сцены и здесь не нужны.
  static const widthU = <ItemKind, double>{
    ItemKind.flower: 1.0,
    ItemKind.bush: 1.5,
    ItemKind.tree: 1.7,
    ItemKind.palm: 2.1,
    ItemKind.bridge: 2.4,
    ItemKind.fountain: 1.5,
    ItemKind.lantern: .65,
    ItemKind.pavilion: 2.6,
    ItemKind.dome: 3.4,
  };

  static const files = [
    'sprout', 'foundation',
    'grass_2', 'grass_3', 'flower_2', 'flower_3', 'bush_2', 'bush_3', 'tree_2', 'tree_3', 'palm_2', 'palm_3',
    'stream_2', 'stream_3', 'bridge_2', 'bridge_3', 'fountain_2', 'fountain_3', 'lantern_2', 'lantern_3',
    'pavilion_2', 'pavilion_3', 'dome_2', 'dome_3',
    'hills_back', 'hills_front', 'cloud', 'sun', 'moon',
  ];

  static final Map<String, String> _svg = {};
  static final Map<String, Size> _box = {};

  static bool get loaded => _svg.length == files.length;

  /// Имя файла для предмета в данном состоянии роста (1..3).
  static String fileFor(ItemKind kind, int state) {
    if (state <= 1) return plants.contains(kind) ? 'sprout' : 'foundation';
    return '${kind.name}_${state.clamp(2, 3)}';
  }

  /// Загружает все SVG и разбирает их заранее, чтобы первый кадр сада не был пустым.
  static Future<void> preload() async {
    for (final f in files) {
      final s = await rootBundle.loadString('$dir/$f.svg');
      _svg[f] = s;
      _box[f] = _viewBox(s);
    }
    final strings = <String>{..._svg.values};
    for (final g in gardens) {
      for (final it in g.items) {
        for (var st = 1; st <= 3; st++) {
          strings.add(svgFor(it.kind, st, it.color));
        }
      }
      strings.add(hills(back: true, color: g.theme.hillBack));
      strings.add(hills(back: false, color: g.theme.hillFront));
    }
    await Future.wait(strings.map((s) => vg.loadPicture(SvgStringLoader(s), null)));
  }

  static String raw(String file) => _svg[file] ?? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"/>';

  /// Размер viewBox файла (ширина, высота).
  static Size box(String file) => _box[file] ?? const Size(1, 1);

  /// SVG предмета в состоянии роста с подставленным цветом (для цветов).
  static String svgFor(ItemKind kind, int state, Color color) {
    final file = fileFor(kind, state);
    final s = raw(file);
    if (kind == ItemKind.flower && state >= 2) return tintPetals(s, color);
    return s;
  }

  static String tintPetals(String svg, Color color) {
    final light = Color.lerp(color, Colors.white, .38)!;
    final dark = Color.lerp(color, Colors.black, .25)!;
    return svg
        .replaceAll(petalPlaceholders[0], hex(light))
        .replaceAll(petalPlaceholders[1], hex(color))
        .replaceAll(petalPlaceholders[2], hex(dark));
  }

  static String hills({required bool back, required Color color}) =>
      raw(back ? 'hills_back' : 'hills_front').replaceAll(hillPlaceholder, hex(color));

  /// Высота спрайта при заданной ширине с сохранением пропорций файла.
  static double heightFor(String file, double width) {
    final b = box(file);
    return width * b.height / b.width;
  }

  static String hex(Color c) {
    String ch(double v) => (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#${ch(c.r)}${ch(c.g)}${ch(c.b)}';
  }

  static Size _viewBox(String svg) {
    final m = RegExp(r'viewBox="\s*[-\d.]+\s+[-\d.]+\s+([\d.]+)\s+([\d.]+)\s*"').firstMatch(svg);
    if (m == null) return const Size(1, 1);
    return Size(double.parse(m.group(1)!), double.parse(m.group(2)!));
  }
}

/// Один спрайт предмета сада. Ширина задаётся, высота — по пропорциям файла.
class Sprite extends StatelessWidget {
  const Sprite({super.key, required this.kind, this.state = 3, required this.width, this.color = const Color(0xFFFF6FB1)});

  final ItemKind kind;
  final int state;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final file = Sprites.fileFor(kind, state);
    return SvgPicture.string(
      Sprites.svgFor(kind, state, color),
      width: width,
      height: Sprites.heightFor(file, width),
      fit: BoxFit.contain,
    );
  }
}
