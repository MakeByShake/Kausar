/// Список зикров. ВАЖНО: тексты и переводы нужно проверить у устаза
/// перед публикацией (см. docs/content-review.md).
class Dhikr {
  final String id;
  final String arabic;
  final String translit;
  final String ru;
  final String kz;
  final String virtueRu;
  final String virtueKz;
  final int target; // цель за один подход
  final int minIntervalMs; // минимум между тапами (длинный зикр = дольше)
  final int drops; // сколько капель «Каусар» даёт один зикр

  const Dhikr({
    required this.id,
    required this.arabic,
    required this.translit,
    required this.ru,
    required this.kz,
    required this.virtueRu,
    required this.virtueKz,
    required this.target,
    this.minIntervalMs = 1000,
    this.drops = 1,
  });
}

const dhikrs = <Dhikr>[
  Dhikr(
    id: 'subhanallah',
    arabic: 'سُبْحَانَ ٱللَّٰهِ',
    translit: 'Subhanallah',
    ru: 'Пречист Аллах',
    kz: 'Алла пәк',
    virtueRu: 'Тасбих после намаза 33 раза',
    virtueKz: 'Намаздан кейін 33 рет',
    target: 33,
  ),
  Dhikr(
    id: 'alhamdulillah',
    arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
    translit: 'Alhamdulillah',
    ru: 'Хвала Аллаху',
    kz: 'Аллаға мадақ',
    virtueRu: '«Альхамдулиллях» наполняет весы (Муслим)',
    virtueKz: '«Әлхамдулиллаһ» таразыны толтырады (Муслим)',
    target: 33,
  ),
  Dhikr(
    id: 'allahuakbar',
    arabic: 'ٱللَّٰهُ أَكْبَرُ',
    translit: 'Allahu akbar',
    ru: 'Аллах велик',
    kz: 'Алла ұлы',
    virtueRu: 'Такбир после намаза 34 раза',
    virtueKz: 'Намаздан кейін 34 рет',
    target: 34,
  ),
  Dhikr(
    id: 'tahlil',
    arabic: 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
    translit: 'La ilaha illallah',
    ru: 'Нет божества, кроме Аллаха',
    kz: 'Алладан басқа тәңір жоқ',
    virtueRu: 'Лучший зикр (ат-Тирмизи)',
    virtueKz: 'Ең абзал зікір (Тирмизи)',
    target: 100,
    drops: 2,
  ),
  Dhikr(
    id: 'astaghfirullah',
    arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ',
    translit: 'Astaghfirullah',
    ru: 'Прошу прощения у Аллаха',
    kz: 'Алладан кешірім сұраймын',
    virtueRu: 'Пророк ﷺ просил прощения более 70 раз в день (аль-Бухари)',
    virtueKz: 'Пайғамбар ﷺ күніне 70 реттен көп истиғфар айтқан (Бұхари)',
    target: 100,
  ),
  Dhikr(
    id: 'subhanallahil_azim',
    arabic: 'سُبْحَانَ ٱللَّٰهِ ٱلْعَظِيمِ وَبِحَمْدِهِ',
    translit: 'Subhanallahil-azim wa bihamdihi',
    ru: 'Пречист Аллах Великий, и хвала Ему',
    kz: 'Ұлы Алла пәк, Оған мадақ',
    virtueRu: 'Сказавшему это сажают пальму в раю (ат-Тирмизи)',
    virtueKz: 'Айтқан адамға жәннатта құрма ағашы егіледі (Тирмизи)',
    target: 100,
    minIntervalMs: 1500,
    drops: 3,
  ),
  Dhikr(
    id: 'hawqala',
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ',
    translit: 'La hawla wa la quwwata illa billah',
    ru: 'Нет силы и мощи, кроме как у Аллаха',
    kz: 'Күш пен қуат тек Аллада',
    virtueRu: 'Одно из сокровищ рая (аль-Бухари)',
    virtueKz: 'Жәннат қазыналарының бірі (Бұхари)',
    target: 100,
    minIntervalMs: 1500,
    drops: 3,
  ),
  Dhikr(
    id: 'two_light_words',
    arabic: 'سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ سُبْحَانَ ٱللَّٰهِ ٱلْعَظِيمِ',
    translit: 'Subhanallahi wa bihamdihi, subhanallahil-azim',
    ru: 'Пречист Аллах и хвала Ему, пречист Аллах Великий',
    kz: 'Алла пәк, Оған мадақ, Ұлы Алла пәк',
    virtueRu: 'Два слова, лёгкие на языке и тяжёлые на весах (аль-Бухари)',
    virtueKz: 'Тілге жеңіл, таразыда ауыр екі сөз (Бұхари)',
    target: 100,
    minIntervalMs: 2000,
    drops: 4,
  ),
  Dhikr(
    id: 'salawat',
    arabic: 'ٱللَّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
    translit: 'Allahumma salli ala Muhammad',
    ru: 'О Аллах, благослови Мухаммада',
    kz: 'Уа, Алла, Мұхаммедке салауат жолда',
    virtueRu: 'За один салават Аллах благословляет 10 раз (Муслим)',
    virtueKz: 'Бір салауат үшін Алла он рет рақым етеді (Муслим)',
    target: 100,
    minIntervalMs: 1500,
    drops: 3,
  ),
  Dhikr(
    id: 'tawhid_full',
    arabic:
        'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ وَلَهُ ٱلْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    translit:
        'La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa huwa ala kulli shay\'in qadir',
    ru:
        'Нет божества, кроме одного Аллаха, у Него нет сотоварища. Ему власть и хвала, и Он над всем властен',
    kz:
        'Жалғыз Алладан басқа тәңір жоқ, Оның серігі жоқ. Билік те, мадақ та Оған тән, Ол бәріне құдіретті',
    virtueRu: '100 раз в день = как освободить 10 рабов (аль-Бухари)',
    virtueKz: 'Күніне 100 рет = 10 құл азат еткендей (Бұхари)',
    target: 100,
    minIntervalMs: 4000,
    drops: 8,
  ),
];
