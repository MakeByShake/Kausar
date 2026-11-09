import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/gardens.dart';
import '../l10n/strings.dart';

/// Весь прогресс игрока. Пока хранится только на телефоне.
/// Позже сюда подключим Firebase (вход + облако).
class GameState extends ChangeNotifier {
  static const _key = 'kausar_state_v1';

  Lang lang = Lang.kz;
  int drops = 0;
  int totalDhikr = 0;
  Map<String, int> perDhikr = {};
  Set<String> owned = {};
  int currentGarden = 0;
  int streak = 0;
  String? lastDay;
  int todayCount = 0;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      lang = Lang.values[(m['lang'] ?? 0) as int];
      drops = m['drops'] ?? 0;
      totalDhikr = m['total'] ?? 0;
      perDhikr = Map<String, int>.from(m['per'] ?? {});
      owned = Set<String>.from(m['owned'] ?? []);
      currentGarden = m['garden'] ?? 0;
      streak = m['streak'] ?? 0;
      lastDay = m['lastDay'];
      todayCount = m['today'] ?? 0;
    }
    _rollDay();
    notifyListeners();
  }

  void _save() {
    _prefs?.setString(
      _key,
      jsonEncode({
        'lang': lang.index,
        'drops': drops,
        'total': totalDhikr,
        'per': perDhikr,
        'owned': owned.toList(),
        'garden': currentGarden,
        'streak': streak,
        'lastDay': lastDay,
        'today': todayCount,
      }),
    );
  }

  static String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Новый день: сбрасываем счётчик «сегодня», стрик рвётся, если пропущен день.
  void _rollDay() {
    final today = _day(DateTime.now());
    if (lastDay == today) return;
    final yesterday = _day(DateTime.now().subtract(const Duration(days: 1)));
    if (lastDay != yesterday) streak = 0;
    todayCount = 0;
  }

  void addDhikr(String id, int dropValue) {
    final today = _day(DateTime.now());
    if (lastDay != today) {
      _rollDay();
      streak += 1;
      lastDay = today;
    }
    totalDhikr++;
    todayCount++;
    perDhikr[id] = (perDhikr[id] ?? 0) + 1;
    drops += dropValue;
    _save();
    notifyListeners();
  }

  Garden get garden => gardens[currentGarden];

  /// Следующий предмет, который можно вырастить (идём по порядку,
  /// как уровни: так сад всегда растёт красиво).
  GardenItem? get nextItem {
    for (final it in garden.items) {
      if (!owned.contains(it.id)) return it;
    }
    return null;
  }

  bool isGardenDone(int index) => gardens[index].items.every((i) => owned.contains(i.id));
  bool isGardenUnlocked(int index) => index == 0 || isGardenDone(index - 1);

  double gardenProgress(int index) {
    final g = gardens[index];
    final have = g.items.where((i) => owned.contains(i.id)).length;
    return have / g.items.length;
  }

  /// true, если сад после этого полностью вырос.
  bool grow(GardenItem item) {
    if (drops < item.cost || owned.contains(item.id)) return false;
    drops -= item.cost;
    owned.add(item.id);
    _save();
    notifyListeners();
    return isGardenDone(currentGarden);
  }

  void openGarden(int index) {
    if (!isGardenUnlocked(index)) return;
    currentGarden = index;
    _save();
    notifyListeners();
  }

  void toggleLang() {
    lang = lang == Lang.kz ? Lang.ru : Lang.kz;
    _save();
    notifyListeners();
  }

  /// Только для демо: дать капли, чтобы быстро посмотреть все сады.
  void demoBonus() {
    drops += 500;
    _save();
    notifyListeners();
  }
}
