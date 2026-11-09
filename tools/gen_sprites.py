#!/usr/bin/env python3
"""Генерирует SVG-спрайты сада Kausar в стиле clay casual.
Запуск: python3 -I tools/gen_sprites.py assets/garden
"""
import sys, os, math

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

def svg(w, h, body, defs=""):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">\n'
            f'<defs>\n{defs}</defs>\n{body}\n</svg>\n')

def rg(id_, c1, c2, c3=None, cx=.38, cy=.32, r=.8):
    mid = f'<stop offset=".55" stop-color="{c2}"/>' if c3 else ''
    last = c3 or c2
    return (f'<radialGradient id="{id_}" cx="{cx}" cy="{cy}" r="{r}">'
            f'<stop offset="0" stop-color="{c1}"/>{mid}<stop offset="1" stop-color="{last}"/></radialGradient>\n')

def lg(id_, c1, c2, vertical=True):
    xy = 'x1="0" y1="0" x2="0" y2="1"' if vertical else 'x1="0" y1="0" x2="1" y2="0"'
    return f'<linearGradient id="{id_}" {xy}><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>\n'

def shadow(cx, cy, rx, ry=None, op=.16):
    ry = ry or rx * .3
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#000" opacity="{op}"/>\n'

def ball(cx, cy, r, grad):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{grad})"/>\n'

def shine(cx, cy, rx, ry, rot=-30, op=.45):
    return (f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#fff" opacity="{op}" '
            f'transform="rotate({rot} {cx} {cy})"/>\n')

# Палитра
LEAF = ('#9BF27F', '#43C457', '#1F8F3A')
LEAF2 = ('#B6F7A0', '#5BD36E', '#2E9E44')
TRUNK = ('#C98E55', '#9B5B2E', '#5E3417')
BERRY = ('#FFB3C1', '#FF4D6D', '#B8203F')
FRUIT = ('#FFC7A0', '#FF7A45', '#C9451A')
STONE = ('#FFFBF0', '#EBD9B8', '#C4A77B')
GOLD = ('#FFF3B0', '#FFC23F', '#D08A00')
TEAL = ('#8AF0E4', '#3FD1C1', '#17877A')
WATER = ('#C9F6FF', '#5ED0FF', '#1E9BE0')
SOIL = ('#C98E55', '#8E5A2E', '#5E3417')
PETAL = ('#FFA8D1', '#FF6FB1', '#C9407F')   # заменяется кодом на цвет предмета

files = {}

# ---------- Общий росток (состояние 1 для растений) ----------
files['sprout'] = svg(100, 100,
    shadow(50, 93, 30) +
    f'<ellipse cx="50" cy="86" rx="22" ry="9" fill="url(#soil)"/>\n'
    f'<path d="M50 84 Q50 70 50 58" stroke="#2E9E44" stroke-width="5" stroke-linecap="round" fill="none"/>\n'
    f'<path d="M50 66 C38 68 26 60 24 46 C38 44 50 52 50 66 Z" fill="url(#leaf)"/>\n'
    f'<path d="M50 60 C62 62 74 54 76 40 C62 38 50 46 50 60 Z" fill="url(#leaf)"/>\n'
    f'<path d="M30 52 Q40 54 48 62" stroke="#fff" stroke-opacity=".5" stroke-width="2" fill="none" stroke-linecap="round"/>\n'
    f'<path d="M70 46 Q60 48 52 56" stroke="#fff" stroke-opacity=".5" stroke-width="2" fill="none" stroke-linecap="round"/>\n',
    rg('soil', *SOIL) + lg('leaf', LEAF[0], LEAF[2]))

# ---------- Общий фундамент (состояние 1 для построек) ----------
files['foundation'] = svg(140, 70,
    shadow(70, 62, 60, 8) +
    '<path d="M14 56 L28 38 H112 L126 56 Z" fill="url(#slab)"/>\n'
    '<rect x="26" y="32" width="88" height="12" rx="5" fill="#FFFBF0"/>\n'
    '<rect x="26" y="32" width="88" height="5" rx="2.5" fill="#fff" opacity=".6"/>\n'
    '<rect x="34" y="16" width="7" height="20" rx="3.5" fill="#9B5B2E"/>\n'
    '<rect x="99" y="16" width="7" height="20" rx="3.5" fill="#9B5B2E"/>\n'
    '<path d="M38 21 H102" stroke="#E8B070" stroke-width="2.5" stroke-dasharray="5 3" stroke-linecap="round"/>\n'
    '<ellipse cx="22" cy="58" rx="7" ry="4" fill="#C4A77B"/><ellipse cx="118" cy="59" rx="6" ry="3.5" fill="#C4A77B"/>\n'
    '<ellipse cx="21" cy="56.5" rx="4" ry="2" fill="#fff" opacity=".5"/>\n',
    lg('slab', STONE[1], STONE[2]))

# ---------- Трава ----------
def tuft(x, h, dark=False):
    g = 'g2' if dark else 'g1'
    return (f'<path d="M{x} 40 C{x-2} 30 {x-9} 24 {x-13} {40-h*.75:.0f} C{x-6} 24 {x-3} 32 {x} 40 Z" fill="url(#{g})"/>'
            f'<path d="M{x} 40 C{x-1} 28 {x} 18 {x+1} {40-h:.0f} C{x+2} 20 {x+1} 30 {x} 40 Z" fill="url(#{g})"/>'
            f'<path d="M{x} 40 C{x+2} 30 {x+9} 24 {x+13} {40-h*.7:.0f} C{x+6} 25 {x+3} 32 {x} 40 Z" fill="url(#{g})"/>\n')

def daisy(x, y, s=1.0):
    pts = ''.join(f'<circle cx="{x+math.cos(a)*3.2*s:.1f}" cy="{y+math.sin(a)*3.2*s:.1f}" r="{2.1*s}" fill="#fff"/>' for a in [i*math.pi/2.5 for i in range(5)])
    return pts + f'<circle cx="{x}" cy="{y}" r="{1.6*s}" fill="#FFD23F"/>\n'

gdefs = lg('g1', '#8CEB72', '#2FA84A') + lg('g2', '#5CD36E', '#1F8F3A')
body2 = ''.join(tuft(x, 14 + (x * 7 % 9), dark=(i % 3 == 0)) for i, x in enumerate(range(16, 400, 32)))
files['grass_2'] = svg(400, 40, body2, gdefs)
body3 = ''.join(tuft(x, 16 + (x * 7 % 11), dark=(i % 2 == 0)) for i, x in enumerate(range(10, 400, 17)))
body3 += ''.join(daisy(x, 29 + (x % 5), .9) for x in range(28, 400, 61))
files['grass_3'] = svg(400, 40, body3, gdefs)

# ---------- Цветок ----------
stem = ('<path d="M50 94 Q48 72 50 50" stroke="#2E9E44" stroke-width="4.5" stroke-linecap="round" fill="none"/>\n'
        '<path d="M50 80 C40 82 30 76 28 66 C40 64 50 70 50 80 Z" fill="url(#leaf)"/>\n'
        '<path d="M50 72 C60 74 70 68 72 58 C60 56 50 62 50 72 Z" fill="url(#leaf)"/>\n')
fdefs = lg('leaf', LEAF[0], LEAF[2]) + rg('petal', *PETAL) + rg('core', '#FFF3B0', '#FFD23F', '#E09A00')
files['flower_2'] = svg(100, 100,
    shadow(50, 95, 20) + stem +
    '<path d="M50 52 C36 50 34 30 50 20 C66 30 64 50 50 52 Z" fill="url(#petal)"/>\n'
    '<path d="M50 52 C44 44 44 30 50 22 C56 30 56 44 50 52 Z" fill="#fff" opacity=".25"/>\n'
    '<path d="M50 54 C42 56 36 50 40 44 Q50 48 50 54 Z" fill="url(#leaf)"/>\n'
    '<path d="M50 54 C58 56 64 50 60 44 Q50 48 50 54 Z" fill="url(#leaf)"/>\n',
    fdefs)
petals = ''.join(ball(f'{50+math.cos(a)*15:.1f}', f'{40+math.sin(a)*15:.1f}', 12, 'petal') for a in [i*math.pi/3 - math.pi/2 for i in range(6)])
petals += ''.join(shine(f'{50+math.cos(a)*17:.1f}', f'{40+math.sin(a)*17 - 3:.1f}', 4.5, 2.5, -20, .4) for a in [i*math.pi/3 - math.pi/2 for i in range(6)])
files['flower_3'] = svg(100, 100,
    shadow(50, 95, 22) + stem + petals + ball(50, 40, 9, 'core') + shine(47, 36, 3.5, 2, -30, .6),
    fdefs)

# ---------- Куст ----------
bdefs = rg('lf', *LEAF) + rg('lf2', *LEAF2) + rg('br', *BERRY)
files['bush_2'] = svg(120, 100,
    shadow(60, 94, 36) +
    ball(44, 72, 22, 'lf') + ball(76, 74, 20, 'lf') + ball(60, 60, 22, 'lf2') +
    shine(52, 48, 8, 4.5) + shine(38, 62, 5, 3),
    bdefs)
files['bush_3'] = svg(120, 100,
    shadow(60, 94, 46) +
    ball(34, 72, 26, 'lf') + ball(86, 72, 26, 'lf') + ball(60, 54, 30, 'lf2') + ball(60, 76, 24, 'lf') +
    shine(50, 36, 10, 5.5) + shine(26, 58, 6, 3.5) + shine(80, 58, 6, 3.5) +
    ball(46, 60, 6, 'br') + ball(72, 50, 6, 'br') + ball(30, 80, 5.5, 'br') + ball(92, 84, 5.5, 'br') + ball(60, 86, 5, 'br') +
    ''.join(f'<circle cx="{x-1.8}" cy="{y-2}" r="1.8" fill="#fff" opacity=".8"/>' for x, y in [(46,60),(72,50),(30,80),(92,84),(60,86)]),
    bdefs)

# ---------- Дерево ----------
tdefs = rg('lf', *LEAF) + rg('lf2', *LEAF2) + lg('tr', TRUNK[1], TRUNK[2], vertical=False) + rg('fr', *FRUIT)
files['tree_2'] = svg(140, 180,
    shadow(70, 172, 38) +
    '<path d="M64 172 L66 118 Q70 110 74 118 L76 172 Z" fill="url(#tr)"/>\n'
    '<path d="M67 150 L68 122" stroke="#C98E55" stroke-width="2" opacity=".6" stroke-linecap="round"/>\n' +
    ball(70, 104, 30, 'lf2') + ball(48, 118, 20, 'lf') + ball(92, 118, 20, 'lf') +
    shine(60, 86, 10, 5.5) + shine(42, 108, 5, 3),
    tdefs)
files['tree_3'] = svg(140, 180,
    shadow(70, 172, 52) +
    '<path d="M60 172 L64 92 Q70 84 76 92 L80 172 Z" fill="url(#tr)"/>\n'
    '<path d="M64 110 L44 92" stroke="#9B5B2E" stroke-width="7" stroke-linecap="round"/>\n'
    '<path d="M76 104 L98 86" stroke="#9B5B2E" stroke-width="7" stroke-linecap="round"/>\n'
    '<path d="M66 150 L67 100" stroke="#C98E55" stroke-width="2.5" opacity=".55" stroke-linecap="round"/>\n' +
    ball(38, 92, 30, 'lf') + ball(102, 92, 30, 'lf') + ball(70, 56, 38, 'lf2') + ball(70, 96, 32, 'lf') +
    shine(56, 34, 13, 7) + shine(28, 76, 7, 4) + shine(92, 76, 7, 4) +
    ball(52, 70, 7, 'fr') + ball(92, 64, 7, 'fr') + ball(70, 110, 7, 'fr') + ball(36, 104, 6, 'fr') + ball(108, 108, 6, 'fr') +
    ''.join(f'<circle cx="{x-2.2}" cy="{y-2.4}" r="2.2" fill="#fff" opacity=".8"/>' for x, y in [(52,70),(92,64),(70,110),(36,104),(108,108)]),
    tdefs)

# ---------- Пальма ----------
def palm_leaf(cx, cy, ang, length, grad, curl=.35):
    a = math.radians(ang)
    ex, ey = cx + math.cos(a) * length, cy + math.sin(a) * length + length * .25
    c1x, c1y = cx + math.cos(a - curl) * length * .6, cy + math.sin(a - curl) * length * .6 - length * .2
    c2x, c2y = cx + math.cos(a + curl) * length * .55, cy + math.sin(a + curl) * length * .55
    return (f'<path d="M{cx} {cy} Q{c1x:.1f} {c1y:.1f} {ex:.1f} {ey:.1f} Q{c2x:.1f} {c2y:.1f} {cx} {cy} Z" fill="url(#{grad})"/>'
            f'<path d="M{cx} {cy} Q{(c1x+c2x)/2:.1f} {(c1y+c2y)/2:.1f} {ex:.1f} {ey:.1f}" stroke="#fff" stroke-opacity=".3" stroke-width="2" fill="none"/>\n')

pdefs = lg('lf', LEAF[0], LEAF[2]) + lg('lf2', LEAF2[0], LEAF2[2]) + lg('tr', TRUNK[0], TRUNK[2], vertical=False) + rg('dt', '#E07A48', '#8B3A1E', '#5E2410')
trunk2 = '<path d="M72 172 Q78 130 86 104 L98 104 Q92 130 92 172 Z" fill="url(#tr)"/>\n'
rings2 = ''.join(f'<path d="M{74+i*2.6:.0f} {164-i*14} q{8} -3 {16} 0" stroke="#5E3417" stroke-width="2.5" opacity=".45" fill="none" stroke-linecap="round"/>' for i in range(4))
files['palm_2'] = svg(160, 180,
    shadow(80, 172, 40) + trunk2 + rings2 +
    ''.join(palm_leaf(92, 104, ang, 58, 'lf' if i % 2 else 'lf2') for i, ang in enumerate([-160, -120, -75, -30, 5])) +
    ball(92, 104, 7, 'dt'),
    pdefs)
trunk3 = '<path d="M88 232 Q92 160 108 96 L124 96 Q114 160 112 232 Z" fill="url(#tr)"/>\n'
rings3 = ''.join(f'<path d="M{90+i*2.9:.0f} {220-i*17} q{10} -4 {20} 0" stroke="#5E3417" stroke-width="3" opacity=".45" fill="none" stroke-linecap="round"/>' for i in range(7))
files['palm_3'] = svg(200, 240,
    shadow(100, 232, 52) + trunk3 + rings3 +
    ''.join(palm_leaf(116, 96, ang, 86, 'lf' if i % 2 else 'lf2') for i, ang in enumerate([-170, -140, -110, -80, -50, -20, 10])) +
    ''.join(ball(116 + (i - 2) * 6, 108 + abs(i - 2) * 2, 5.5, 'dt') for i in range(5)) +
    ''.join(ball(116 + (i - 1.5) * 6, 116 + abs(i - 1.5) * 2, 5, 'dt') for i in range(4)) +
    ball(116, 96, 8, 'dt'),
    pdefs)

# ---------- Ручей (растягивается на всю ширину, fit: fill) ----------
wdefs = lg('wt', WATER[1], WATER[2]) + lg('wt2', WATER[0], WATER[1])
files['stream_2'] = svg(400, 44,
    '<path d="M0 22 C60 12 110 32 200 22 C290 12 340 32 400 22 L400 30 C340 40 290 20 200 30 C110 40 60 20 0 30 Z" fill="url(#wt)"/>\n'
    '<path d="M0 24 C60 14 110 34 200 24 C290 14 340 34 400 24 L400 26 C340 36 290 16 200 26 C110 36 60 16 0 26 Z" fill="#fff" opacity=".35"/>\n',
    wdefs)
stones = ''.join(f'<ellipse cx="{x}" cy="{y}" rx="{r}" ry="{r*.6}" fill="#C4A77B"/><ellipse cx="{x-r*.25}" cy="{y-r*.3}" rx="{r*.5}" ry="{r*.25}" fill="#fff" opacity=".45"/>'
                 for x, y, r in [(30, 10, 7), (150, 36, 6), (255, 8, 6), (370, 35, 7)])
files['stream_3'] = svg(400, 44,
    '<path d="M0 14 C60 2 110 28 200 14 C290 0 340 26 400 12 L400 36 C340 44 290 22 200 36 C110 44 60 22 0 36 Z" fill="url(#wt)"/>\n'
    '<path d="M0 16 C60 4 110 28 200 16 C290 2 340 26 400 14 L400 20 C340 30 290 10 200 22 C110 32 60 12 0 22 Z" fill="url(#wt2)" opacity=".8"/>\n'
    '<path d="M20 20 q10 -3 20 0 M120 28 q10 -3 20 0 M210 18 q10 -3 20 0 M310 26 q10 -3 20 0 M360 18 q8 -3 16 0" stroke="#fff" stroke-opacity=".75" stroke-width="2.5" fill="none" stroke-linecap="round"/>\n'
    + stones,
    wdefs)

# ---------- Мостик ----------
brdefs = lg('wd', '#E8B070', '#B8743A') + lg('wd2', '#F2C98E', '#C98A4B')
planks2 = ''.join(f'<rect x="{18+i*18}" y="{44 - (6 - abs(i-3.5))*2.2:.1f}" width="15" height="12" rx="3" fill="url(#wd)"/>' for i in range(8))
files['bridge_2'] = svg(160, 70, shadow(80, 64, 70, 6) + planks2, brdefs)
arch = '<path d="M8 62 Q80 10 152 62 L152 66 Q80 22 8 66 Z" fill="url(#wd)"/>\n'
planks3 = ''.join(f'<path d="M{14+i*16} {62 - (7 - abs(i-4))*5.4:.1f} l14 {-(0 if i==4 else (1 if i<4 else -1))*5.4*.9:.1f} l0 12 l-14 {(0 if i==4 else (1 if i<4 else -1))*5.4*.9:.1f} Z" fill="url(#wd2)" stroke="#9B5B2E" stroke-width="1"/>' for i in range(9))
rails = ''.join(f'<rect x="{x-2.5}" y="{y}" width="5" height="18" rx="2.5" fill="#9B5B2E"/>' for x, y in [(14, 46), (50, 26), (80, 18), (110, 26), (146, 46)])
rail = '<path d="M14 48 Q80 2 146 48" stroke="#E8B070" stroke-width="4" fill="none" stroke-linecap="round"/>\n'
files['bridge_3'] = svg(160, 70, shadow(80, 64, 72, 6) + arch + planks3 + rails + rail, brdefs)

# ---------- Фонтан ----------
fdefs2 = lg('st', STONE[0], STONE[2]) + lg('st2', STONE[1], STONE[2]) + rg('pool', WATER[0], WATER[1], WATER[2], cx=.5, cy=.5)
basin = ('<ellipse cx="70" cy="128" rx="60" ry="18" fill="url(#st2)"/>\n'
         '<rect x="10" y="114" width="120" height="14" fill="url(#st2)"/>\n'
         '<ellipse cx="70" cy="114" rx="60" ry="18" fill="url(#st)"/>\n'
         '<ellipse cx="70" cy="114" rx="50" ry="13" fill="url(#pool)"/>\n'
         '<ellipse cx="56" cy="110" rx="14" ry="4" fill="#fff" opacity=".45"/>\n')
files['fountain_2'] = svg(140, 150, shadow(70, 142, 64, 8) + basin, fdefs2)
column = ('<rect x="62" y="56" width="16" height="60" rx="5" fill="url(#st)"/>\n'
          '<ellipse cx="70" cy="60" rx="30" ry="9" fill="url(#st2)"/>\n<rect x="40" y="52" width="60" height="8" fill="url(#st2)"/>\n'
          '<ellipse cx="70" cy="52" rx="30" ry="9" fill="url(#st)"/>\n<ellipse cx="70" cy="52" rx="23" ry="6" fill="url(#pool)"/>\n'
          '<rect x="66" y="22" width="8" height="32" rx="4" fill="url(#st)"/>\n')
jets = ''.join(f'<path d="M70 22 Q{70+dx*.6} {6} {70+dx} {48}" stroke="#9BE7FF" stroke-width="3.5" fill="none" stroke-linecap="round" opacity=".9"/>' for dx in (-18, -8, 8, 18))
jets += '<circle cx="70" cy="14" r="4" fill="#C9F6FF"/>\n'
falls = ''.join(f'<path d="M{70+dx} 58 Q{70+dx*1.15} 86 {70+dx*1.3} 108" stroke="#9BE7FF" stroke-width="3" fill="none" stroke-linecap="round" opacity=".8"/>' for dx in (-26, 26))
files['fountain_3'] = svg(140, 150, shadow(70, 142, 64, 8) + basin + column + jets + falls, fdefs2)

# ---------- Фонарь ----------
ldefs = lg('post', '#7A4B2A', '#4A2A14', vertical=False) + rg('glow', '#FFF3B0', '#FFE082', '#FFE082', cx=.5, cy=.5, r=.5) + lg('gl', '#FFF7C2', '#FFC107')
post = '<rect x="26" y="40" width="8" height="76" rx="4" fill="url(#post)"/>\n<ellipse cx="30" cy="116" rx="12" ry="4" fill="#4A2A14"/>\n'
files['lantern_2'] = svg(60, 120,
    shadow(30, 118, 16, 4) + post +
    '<path d="M18 40 L30 28 L42 40 Z" fill="#5E3417"/>\n<rect x="20" y="40" width="20" height="24" rx="4" fill="#4A2A14"/>\n'
    '<rect x="24" y="44" width="12" height="16" rx="2" fill="#8FA3B5" opacity=".7"/>\n',
    ldefs)
files['lantern_3'] = svg(60, 120,
    shadow(30, 118, 16, 4) +
    '<circle cx="30" cy="48" r="28" fill="url(#glow)" opacity=".55"/>\n' + post +
    '<path d="M16 40 L30 26 L44 40 Z" fill="#5E3417"/>\n<rect x="19" y="40" width="22" height="26" rx="5" fill="#5E3417"/>\n'
    '<rect x="23" y="43" width="14" height="20" rx="3" fill="url(#gl)"/>\n<rect x="25" y="45" width="4" height="10" rx="2" fill="#fff" opacity=".6"/>\n'
    '<circle cx="30" cy="24" r="3" fill="#FFC23F"/>\n',
    ldefs)

# ---------- Беседка ----------
pvdefs = lg('st', STONE[0], STONE[2]) + lg('fl', STONE[1], STONE[2]) + rg('roof', *TEAL, cx=.4, cy=.2) + rg('gold', *GOLD)
floor = ('<ellipse cx="120" cy="188" rx="104" ry="12" fill="url(#fl)"/>\n<rect x="16" y="176" width="208" height="12" fill="url(#fl)"/>\n'
         '<ellipse cx="120" cy="176" rx="104" ry="12" fill="#FFFBF0"/>\n')
cols = ''.join(f'<rect x="{x-7}" y="{y}" width="14" height="{176-y}" rx="5" fill="url(#st)"/><rect x="{x-5}" y="{y+4}" width="4" height="{170-y}" rx="2" fill="#fff" opacity=".5"/>' for x, y in [(40, 96), (200, 96), (80, 88), (160, 88)])
files['pavilion_2'] = svg(240, 200, shadow(120, 194, 110, 10) + floor + cols +
    '<rect x="30" y="86" width="180" height="10" rx="5" fill="url(#st)"/>\n', pvdefs)
roof = ('<path d="M12 96 Q120 -30 228 96 Z" fill="url(#roof)"/>\n'
        '<path d="M40 70 Q120 -10 200 70" stroke="#fff" stroke-opacity=".3" stroke-width="6" fill="none" stroke-linecap="round"/>\n'
        '<path d="M12 96 Q120 72 228 96 L228 104 Q120 84 12 104 Z" fill="#17877A"/>\n'
        '<path d="M12 96 Q120 72 228 96 L228 100 Q120 78 12 100 Z" fill="url(#gold)"/>\n'
        '<rect x="116" y="20" width="8" height="18" rx="3" fill="url(#gold)"/>\n' + ball(120, 16, 9, 'gold') + shine(117, 13, 3, 2, -30, .7))
files['pavilion_3'] = svg(240, 200, shadow(120, 194, 112, 10) + floor + cols + roof, pvdefs)

# ---------- Дворец с куполом ----------
ddefs = lg('wall', '#FFFBF0', '#E6D3AE') + lg('wall2', '#F3E6C8', '#C4A77B') + rg('dome', *GOLD, cx=.35, cy=.25) + lg('win', '#7C8CE6', '#3F4FA8') + rg('gold', *GOLD)
walls = ('<rect x="40" y="130" width="240" height="100" rx="6" fill="url(#wall)"/>\n'
         '<rect x="40" y="130" width="240" height="10" rx="4" fill="#fff" opacity=".6"/>\n'
         '<rect x="28" y="222" width="264" height="12" rx="5" fill="url(#wall2)"/>\n')
arches = ''.join(f'<path d="M{x-18} 222 V178 A18 18 0 0 1 {x+18} 178 V222 Z" fill="url(#win)"/><path d="M{x-14} 222 V180 A14 14 0 0 1 {x+14} 180 V222 Z" fill="#1E2A78" opacity=".35"/>' for x in (100, 160, 220))
files['dome_2'] = svg(320, 240, shadow(160, 232, 150, 12) + walls + arches +
    ''.join(f'<rect x="{x-4}" y="106" width="8" height="24" rx="3" fill="url(#wall2)"/>' for x in range(52, 280, 24)), ddefs)
minarets = ''.join(f'<rect x="{x-12}" y="40" width="24" height="190" rx="8" fill="url(#wall)"/><rect x="{x-9}" y="46" width="5" height="170" rx="2.5" fill="#fff" opacity=".5"/>'
                   f'<ellipse cx="{x}" cy="40" rx="16" ry="6" fill="url(#wall2)"/>' + ball(x, 30, 14, 'dome') + f'<rect x="{x-2}" y="8" width="4" height="12" rx="2" fill="url(#gold)"/>' + ball(x, 6, 4, 'gold')
                   for x in (24, 296))
dome = ('<rect x="70" y="118" width="180" height="16" rx="4" fill="url(#wall2)"/>\n'
        '<path d="M80 122 A80 80 0 0 1 240 122 Z" fill="url(#dome)"/>\n'
        '<path d="M100 100 A60 60 0 0 1 160 44" stroke="#fff" stroke-opacity=".45" stroke-width="7" fill="none" stroke-linecap="round"/>\n'
        '<rect x="156" y="22" width="8" height="24" rx="3" fill="url(#gold)"/>\n' + ball(160, 18, 10, 'gold') + shine(157, 15, 3.5, 2, -30, .7))
files['dome_3'] = svg(320, 240, shadow(160, 232, 156, 12) + minarets + walls + dome + arches +
    ''.join(f'<rect x="{x-4}" y="112" width="8" height="18" rx="3" fill="url(#wall2)"/>' for x in range(52, 280, 24)) +
    '<path d="M142 222 V190 A18 18 0 0 1 178 190 V222 Z" fill="url(#gold)"/>\n', ddefs)

# ---------- Фон: холмы (цвет #4CC85A заменяется кодом) ----------
files['hills_back'] = svg(400, 100,
    '<path d="M0 40 C60 10 120 60 200 30 C280 0 340 50 400 24 L400 100 L0 100 Z" fill="#4CC85A"/>\n'
    '<path d="M0 40 C60 10 120 60 200 30 C280 0 340 50 400 24 L400 36 C340 62 280 14 200 42 C120 72 60 24 0 52 Z" fill="#fff" opacity=".22"/>\n')
files['hills_front'] = svg(400, 100,
    '<path d="M0 50 C80 20 140 70 220 40 C300 10 350 60 400 36 L400 100 L0 100 Z" fill="#4CC85A"/>\n'
    '<path d="M0 50 C80 20 140 70 220 40 C300 10 350 60 400 36 L400 48 C350 72 300 24 220 52 C140 82 80 34 0 62 Z" fill="#fff" opacity=".22"/>\n')

# ---------- Фон: облако, солнце, луна ----------
files['cloud'] = svg(120, 60,
    '<ellipse cx="60" cy="48" rx="50" ry="10" fill="#fff" opacity=".95"/>\n'
    '<circle cx="40" cy="36" r="18" fill="url(#cl)"/><circle cx="66" cy="28" r="24" fill="url(#cl)"/><circle cx="92" cy="38" r="16" fill="url(#cl)"/>\n'
    '<rect x="22" y="36" width="80" height="18" rx="9" fill="url(#cl)"/>\n'
    '<ellipse cx="60" cy="20" rx="12" ry="5" fill="#fff" opacity=".9"/>\n',
    lg('cl', '#FFFFFF', '#E3F3FF'))
files['sun'] = svg(100, 100,
    '<circle cx="50" cy="50" r="50" fill="url(#halo)"/>\n<circle cx="50" cy="50" r="27" fill="url(#sun)"/>\n' + shine(42, 40, 8, 5, -30, .6),
    rg('halo', '#FFF8D0', '#FFF8D0', '#FFF8D0', cx=.5, cy=.5, r=.5).replace('<stop offset="0" stop-color="#FFF8D0"/>', '<stop offset="0" stop-color="#FFF8D0" stop-opacity=".9"/>').replace('<stop offset=".55" stop-color="#FFF8D0"/>', '<stop offset=".55" stop-color="#FFF8D0" stop-opacity=".35"/>').replace('<stop offset="1" stop-color="#FFF8D0"/>', '<stop offset="1" stop-color="#FFF8D0" stop-opacity="0"/>')
    + rg('sun', '#FFFBE6', '#FFE86B', '#FFC23F', cx=.4, cy=.35))
files['moon'] = svg(100, 100,
    '<circle cx="50" cy="50" r="50" fill="url(#halo)"/>\n'
    '<path d="M58 22 A30 30 0 1 0 78 72 A24 24 0 0 1 58 22 Z" fill="url(#mn)"/>\n' + shine(44, 36, 6, 3.5, -40, .7),
    rg('halo', '#FFF4C2', '#FFF4C2', '#FFF4C2', cx=.5, cy=.5, r=.5).replace('<stop offset="0" stop-color="#FFF4C2"/>', '<stop offset="0" stop-color="#FFF4C2" stop-opacity=".7"/>').replace('<stop offset=".55" stop-color="#FFF4C2"/>', '<stop offset=".55" stop-color="#FFF4C2" stop-opacity=".25"/>').replace('<stop offset="1" stop-color="#FFF4C2"/>', '<stop offset="1" stop-color="#FFF4C2" stop-opacity="0"/>')
    + lg('mn', '#FFFBE6', '#FFE07A'))

for name, content in files.items():
    with open(os.path.join(OUT, name + '.svg'), 'w') as f:
        f.write(content)
print(f'{len(files)} sprites → {OUT}')
