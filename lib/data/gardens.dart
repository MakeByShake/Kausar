import 'package:flutter/material.dart';

/// Что можно вырастить в саду. Рисуется в widgets/garden_painter.dart.
enum ItemKind { grass, flower, bush, tree, palm, stream, fountain, pavilion, lantern, bridge, dome }

class GardenItem {
  final String id;
  final ItemKind kind;
  final String ru;
  final String kz;
  final int cost; // капли Каусара
  final Offset pos; // 0..1 внутри сцены
  final double scale;
  final Color color;
  const GardenItem(this.id, this.kind, this.ru, this.kz, this.cost, this.pos,
      {this.scale = 1, this.color = const Color(0xFFFF6FB1)});
}

class GardenTheme {
  final List<Color> sky;
  final Color hillBack;
  final Color hillFront;
  const GardenTheme(this.sky, this.hillBack, this.hillFront);
}

class Garden {
  final String id;
  final String ru;
  final String kz;
  final GardenTheme theme;
  final List<GardenItem> items;
  const Garden(this.id, this.ru, this.kz, this.theme, this.items);
  int get totalCost => items.fold(0, (s, i) => s + i.cost);
}

const _pink = Color(0xFFFF6FB1);
const _yellow = Color(0xFFFFD23F);
const _violet = Color(0xFFB57BFF);
const _orange = Color(0xFFFF9F43);
const _white = Color(0xFFFFF4E0);

final gardens = <Garden>[
  Garden(
    'g1', 'Сад начала', 'Бастау бағы',
    const GardenTheme([Color(0xFF7FD8FF), Color(0xFFC9F1FF)], Color(0xFF8EE36B), Color(0xFF4CC85A)),
    [
      const GardenItem('g1_grass', ItemKind.grass, 'Трава', 'Шөп', 20, Offset(.5, .8), scale: 1),
      const GardenItem('g1_f1', ItemKind.flower, 'Цветок', 'Гүл', 30, Offset(.18, .82), color: _pink),
      const GardenItem('g1_f2', ItemKind.flower, 'Цветок', 'Гүл', 30, Offset(.3, .88), color: _yellow),
      const GardenItem('g1_f3', ItemKind.flower, 'Цветок', 'Гүл', 30, Offset(.72, .86), color: _violet),
      const GardenItem('g1_bush1', ItemKind.bush, 'Куст', 'Бұта', 50, Offset(.1, .72)),
      const GardenItem('g1_tree1', ItemKind.tree, 'Дерево', 'Ағаш', 100, Offset(.22, .62), scale: 1),
      const GardenItem('g1_stream', ItemKind.stream, 'Ручей', 'Бұлақ', 150, Offset(.5, .75)),
      const GardenItem('g1_f4', ItemKind.flower, 'Цветок', 'Гүл', 30, Offset(.84, .8), color: _orange),
      const GardenItem('g1_tree2', ItemKind.tree, 'Дерево', 'Ағаш', 100, Offset(.8, .6), scale: .9),
      const GardenItem('g1_bush2', ItemKind.bush, 'Куст', 'Бұта', 50, Offset(.9, .7)),
      const GardenItem('g1_palm', ItemKind.palm, 'Пальма', 'Құрма ағашы', 200, Offset(.62, .58), scale: 1.1),
      const GardenItem('g1_lantern', ItemKind.lantern, 'Фонарь', 'Шам', 80, Offset(.38, .7)),
      const GardenItem('g1_pavilion', ItemKind.pavilion, 'Беседка', 'Шатыр', 300, Offset(.42, .52), scale: 1),
    ],
  ),
  Garden(
    'g2', 'Финиковый оазис', 'Құрма оазисі',
    const GardenTheme([Color(0xFFFFB86B), Color(0xFFFFE7B8)], Color(0xFFF2C46D), Color(0xFF7FCB5C)),
    [
      const GardenItem('g2_grass', ItemKind.grass, 'Трава', 'Шөп', 30, Offset(.5, .8)),
      const GardenItem('g2_palm1', ItemKind.palm, 'Пальма', 'Құрма ағашы', 200, Offset(.15, .6)),
      const GardenItem('g2_palm2', ItemKind.palm, 'Пальма', 'Құрма ағашы', 200, Offset(.85, .6)),
      const GardenItem('g2_stream', ItemKind.stream, 'Родник', 'Бұлақ', 200, Offset(.5, .76)),
      const GardenItem('g2_f1', ItemKind.flower, 'Цветок', 'Гүл', 40, Offset(.3, .86), color: _white),
      const GardenItem('g2_f2', ItemKind.flower, 'Цветок', 'Гүл', 40, Offset(.7, .87), color: _pink),
      const GardenItem('g2_bridge', ItemKind.bridge, 'Мостик', 'Көпір', 250, Offset(.5, .74)),
      const GardenItem('g2_fountain', ItemKind.fountain, 'Фонтан', 'Субұрқақ', 300, Offset(.3, .66)),
      const GardenItem('g2_palm3', ItemKind.palm, 'Пальма', 'Құрма ағашы', 200, Offset(.68, .56), scale: .9),
      const GardenItem('g2_lantern', ItemKind.lantern, 'Фонарь', 'Шам', 100, Offset(.8, .74)),
      const GardenItem('g2_pavilion', ItemKind.pavilion, 'Шатёр', 'Шатыр', 400, Offset(.45, .5)),
    ],
  ),
  Garden(
    'g3', 'Река Каусар', 'Кәусар өзені',
    const GardenTheme([Color(0xFF8A7BFF), Color(0xFFFFC6E6)], Color(0xFF7AD9B8), Color(0xFF39B98A)),
    [
      const GardenItem('g3_grass', ItemKind.grass, 'Трава', 'Шөп', 40, Offset(.5, .8)),
      const GardenItem('g3_stream', ItemKind.stream, 'Река', 'Өзен', 300, Offset(.5, .76)),
      const GardenItem('g3_tree1', ItemKind.tree, 'Дерево', 'Ағаш', 150, Offset(.12, .6)),
      const GardenItem('g3_tree2', ItemKind.tree, 'Дерево', 'Ағаш', 150, Offset(.88, .6)),
      const GardenItem('g3_f1', ItemKind.flower, 'Цветок', 'Гүл', 50, Offset(.25, .87), color: _violet),
      const GardenItem('g3_f2', ItemKind.flower, 'Цветок', 'Гүл', 50, Offset(.75, .88), color: _yellow),
      const GardenItem('g3_fountain1', ItemKind.fountain, 'Фонтан', 'Субұрқақ', 300, Offset(.28, .66)),
      const GardenItem('g3_fountain2', ItemKind.fountain, 'Фонтан', 'Субұрқақ', 300, Offset(.72, .66)),
      const GardenItem('g3_bridge', ItemKind.bridge, 'Мост', 'Көпір', 300, Offset(.5, .74)),
      const GardenItem('g3_dome', ItemKind.dome, 'Дворец', 'Сарай', 600, Offset(.5, .48), scale: 1.2),
    ],
  ),
];
