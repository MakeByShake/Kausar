import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/gardens.dart';

/// Спрайты сада лежат в `assets/garden/`.
///
/// Каждый предмет в трёх состояниях роста: 1 — росток (растения) или
/// фундамент (постройки), 2 — половина, 3 — готово. Файлы называются
/// `<kind>_2`, `<kind>_3`, общие `sprout` и `foundation`, фон — `hills_back`,
/// `hills_front`, `cloud`, `sun`, `moon`.
///
/// Формат: если рядом с `<имя>.svg` лежит `<имя>.png`, берётся PNG (рисунок
/// художника или генерация из Recraft). Иначе — наш SVG. PNG не перекрашивается:
/// цветок и холмы в PNG рисуются сразу в нужном цвете.
class Sprites {
  Sprites._();

  static const dir = 'assets/garden';

  /// Цвета лепестков в flower_*.svg: светлый, основной, тёмный.
  /// Подменяются на цвет конкретного цветка (GardenItem.color).
  static const petalPlaceholders = ['#FFA8D1', '#FF6FB1', '#C9407F'];

  /// Цвет холмов в hills_*.svg, подменяется на цвет темы сада.
  static const hillPlaceholder = '#4CC85A';

  static const plants = {ItemKind.grass, ItemKind.flower, ItemKind.bush, ItemKind.tree, ItemKind.palm};

  /// Ширина спрайта в единицах `u` (u = 13% ширины сцены × scale предмета).
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
  static final Set<String> _png = {};

  static bool get loaded => _box.length == files.length;

  /// Имя файла (без расширения) для предмета в данном состоянии роста (1..3).
  static String fileFor(ItemKind kind, int state) {
    if (state <= 1) return plants.contains(kind) ? 'sprout' : 'foundation';
    return '${kind.name}_${state.clamp(2, 3)}';
  }

  static bool isPng(String file) => _png.contains(file);

  /// Загружает все спрайты и разбирает их заранее, чтобы первый кадр сада не был пустым.
  static Future<void> preload() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    for (final f in files) {
      if (assets.contains('$dir/$f.png')) {
        _png.add(f);
        final bytes = await rootBundle.load('$dir/$f.png');
        final img = await decodeImageFromList(bytes.buffer.asUint8List());
        _box[f] = Size(img.width.toDouble(), img.height.toDouble());
        img.dispose();
      } else {
        final s = await rootBundle.loadString('$dir/$f.svg');
        _svg[f] = s;
        _box[f] = _viewBox(s);
      }
    }
    final strings = <String>{..._svg.values};
    for (final g in gardens) {
      for (final it in g.items) {
        for (var st = 1; st <= 3; st++) {
          final f = fileFor(it.kind, st);
          if (!isPng(f)) strings.add(svgFor(it.kind, st, it.color));
        }
      }
      if (!isPng('hills_back')) strings.add(hills(back: true, color: g.theme.hillBack));
      if (!isPng('hills_front')) strings.add(hills(back: false, color: g.theme.hillFront));
    }
    await Future.wait(strings.map((s) => vg.loadPicture(SvgStringLoader(s), null)));
  }

  static String raw(String file) => _svg[file] ?? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"/>';

  /// Размер картинки (viewBox SVG или пиксели PNG).
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

  /// Виджет картинки по имени файла. [color] — цвет лепестков для flower_* и
  /// цвет холмов для hills_* (только для SVG).
  static Widget widget(String file, {required double width, required double height, BoxFit fit = BoxFit.contain, Color? color}) {
    if (isPng(file)) {
      return Image.asset('$dir/$file.png', width: width, height: height, fit: fit, filterQuality: FilterQuality.medium);
    }
    var s = raw(file);
    if (color != null) {
      if (file.startsWith('flower_')) s = tintPetals(s, color);
      if (file.startsWith('hills_')) s = s.replaceAll(hillPlaceholder, hex(color));
    }
    return SvgPicture.string(s, width: width, height: height, fit: fit);
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
    return Sprites.widget(file, width: width, height: Sprites.heightFor(file, width), color: color);
  }
}
