# Графика через Recraft — порядок работы и промпты

Цель: заменить наши SVG-заглушки в `assets/garden/` на сочные картинки в одном стиле.
Код менять не нужно: кладём `<имя>.png` рядом с `<имя>.svg`, приложение само берёт PNG.

## Настройки в Recraft (одинаковые для всех картинок)
1. Тип: **Image** (растр), размер **1:1** для предметов, **4:1** для `grass_*`, `stream_*`, `hills_*`.
2. Стиль: **3D → Clay** (или «3D Render», если Clay нет в бесплатном плане).
3. Фон: **transparent** (в бесплатном плане нет — тогда генерить на ровном белом фоне и убрать его
   в Recraft → «Remove background» или на remove.bg).
4. Чтобы все предметы были одним набором: сгенерить первую картинку (дерево), нажать на ней
   **«Create style»** / «Стили → Создать из изображения», и дальше выбирать этот стиль для всех.
   Без этого каждый предмет будет «из другой игры».
5. Экспорт: PNG **1024×1024** (или выше). Имя файла — точно как у SVG (см. таблицу).

## Общий хвост промпта (добавлять к каждому)
```
cute casual mobile game asset, 3D clay style, soft studio lighting, smooth rounded shapes,
bright saturated colors, centered, isolated on plain white background, no text, no people, no animals
```

## Предметы (3 состояния: `_2` половина, `_3` готово; `sprout`/`foundation` общие)

| Файл | Промпт (к нему общий хвост) |
|---|---|
| `sprout` | small green sprout with two leaves growing from a round mound of brown soil |
| `foundation` | small sandstone building foundation slab with two wooden pegs and a rope |
| `tree_2` | young fruit tree, thin trunk, small round green crown |
| `tree_3` | lush round fruit tree with three-ball green crown and red apples |
| `palm_2` | short young date palm with three leaves |
| `palm_3` | tall curved date palm with six leaves and clusters of brown dates |
| `bush_2` | small round green bush, two spheres |
| `bush_3` | round green bush of three spheres with red berries |
| `flower_2` | pink flower bud on a green stem with two leaves |
| `flower_3` | blooming pink flower with six round petals and yellow center, green stem, two leaves |
| `lantern_2` | wooden garden lantern post, unlit |
| `lantern_3` | wooden garden lantern post with warm glowing yellow lamp |
| `fountain_2` | round cream stone fountain basin with calm blue water |
| `fountain_3` | two-tier cream stone fountain with splashing blue water jets |
| `bridge_2` | row of flat wooden planks, arched slightly, small garden bridge under construction |
| `bridge_3` | small arched wooden garden bridge with railings |
| `pavilion_2` | round cream stone platform with four white columns, no roof |
| `pavilion_3` | round garden pavilion with white columns and teal dome roof with golden finial |
| `dome_2` | cream palace walls with three blue arched windows, no roof |
| `dome_3` | cream palace with big golden dome, two slim towers with small golden domes, blue arched windows |
| `grass_2` | sparse row of light green grass tufts, wide horizontal strip (4:1) |
| `grass_3` | dense row of light green grass tufts with tiny white daisies, wide horizontal strip (4:1) |
| `stream_2` | thin winding blue stream, wide horizontal strip (4:1), top-down slight angle |
| `stream_3` | wide winding blue stream with white ripples and small stones, wide horizontal strip (4:1) |
| `cloud` | soft puffy white cloud |
| `sun` | glowing warm yellow sun disc with soft halo |
| `moon` | glowing crescent moon with soft halo |
| `hills_back`, `hills_front` | лучше оставить наши SVG: они перекрашиваются под каждый сад |

Про цветы: в SVG цвет лепестков подменяется кодом, а PNG один для всех. Если делать PNG-цветы,
нужны 5 вариантов (розовый, жёлтый, сиреневый, оранжевый, белый) — это отдельная доработка,
скажи, и я добавлю `flower_3_pink.png` и т.д. Пока цветы можно оставить SVG.

## Что генерить первым (60 кредитов)
1. `tree_3` → из него создать стиль.
2. `palm_3`, `pavilion_3`, `dome_3`, `bush_3`, `fountain_3`, `lantern_3`, `bridge_3` — главные предметы.
3. Состояния `_2` и `sprout`, `foundation` — потом, когда понравится стиль.

Готовые PNG скинуть в `assets/garden/` (или мне в чат), я проверю пропорции и подгоню размеры в коде.

## Иконка приложения (отдельно, стиль тот же)
```
app icon, a shining blue water drop with a tiny green palm sprout inside, teal to turquoise
gradient background, rounded square, 3D clay style, soft lighting, no text
```
