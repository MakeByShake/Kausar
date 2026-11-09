import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kausar/data/gardens.dart';
import 'package:kausar/widgets/sprites.dart';

void main() {
  test('для каждого предмета и состояния роста есть файл спрайта', () {
    for (final kind in ItemKind.values) {
      for (var state = 1; state <= 3; state++) {
        final f = File('${Sprites.dir}/${Sprites.fileFor(kind, state)}.svg');
        expect(f.existsSync(), isTrue, reason: '${f.path} не найден');
      }
    }
    for (final f in Sprites.files) {
      expect(File('${Sprites.dir}/$f.svg').existsSync(), isTrue, reason: '$f.svg не найден');
    }
  });

  test('состояние 1 — общий росток для растений и фундамент для построек', () {
    expect(Sprites.fileFor(ItemKind.tree, 1), 'sprout');
    expect(Sprites.fileFor(ItemKind.dome, 1), 'foundation');
    expect(Sprites.fileFor(ItemKind.palm, 3), 'palm_3');
    expect(Sprites.fileFor(ItemKind.palm, 2), 'palm_2');
  });

  test('цветок перекрашивается без остатков цвета-заглушки', () {
    final svg = File('${Sprites.dir}/flower_3.svg').readAsStringSync();
    for (final ph in Sprites.petalPlaceholders) {
      expect(svg.contains(ph), isTrue, reason: 'в flower_3.svg должен быть цвет-заглушка $ph');
    }
    final tinted = Sprites.tintPetals(svg, const Color(0xFFFFD23F));
    for (final ph in Sprites.petalPlaceholders) {
      expect(tinted.contains(ph), isFalse);
    }
    expect(tinted.contains('#FFD23F'), isTrue);
  });

  test('холмы содержат цвет-заглушку для подмены темой', () {
    for (final f in ['hills_back', 'hills_front']) {
      expect(File('${Sprites.dir}/$f.svg').readAsStringSync().contains(Sprites.hillPlaceholder), isTrue);
    }
  });

  test('hex даёт верхний регистр и 6 знаков', () {
    expect(Sprites.hex(const Color(0xFF1FB5A6)), '#1FB5A6');
    expect(Sprites.hex(Colors.white), '#FFFFFF');
  });
}
