/// Простые строки на двух языках. Позже можно перейти на flutter_localizations.
enum Lang { kz, ru }

const _s = <String, Map<Lang, String>>{
  'app': {Lang.kz: 'Кәусар', Lang.ru: 'Каусар'},
  'drops': {Lang.kz: 'тамшы', Lang.ru: 'капель'},
  'dhikrs': {Lang.kz: 'Зікірлер', Lang.ru: 'Зикры'},
  'garden': {Lang.kz: 'Бақ', Lang.ru: 'Сад'},
  'map': {Lang.kz: 'Бақтар картасы', Lang.ru: 'Карта садов'},
  'grow': {Lang.kz: 'Өсіру', Lang.ru: 'Вырастить'},
  'need': {Lang.kz: 'Тамшы жетпейді', Lang.ru: 'Не хватает капель'},
  'tap_hint': {Lang.kz: 'Әр зікірде басыңыз', Lang.ru: 'Нажимайте на каждый зикр'},
  'too_fast': {Lang.kz: 'Асықпаңыз 🙂', Lang.ru: 'Не спешите 🙂'},
  'locked_title': {Lang.kz: 'Сіз осындасыз ба?', Lang.ru: 'Вы здесь?'},
  'locked_body': {
    Lang.kz: 'Басу тым бірқалыпты, автобасқышқа ұқсайды. Жалғастыру үшін растаңыз.',
    Lang.ru: 'Нажатия слишком ровные, похоже на автотапер. Подтвердите, чтобы продолжить.'
  },
  'i_am_here': {Lang.kz: 'Иә, мен осындамын', Lang.ru: 'Да, я здесь'},
  'done': {Lang.kz: 'Мақсат орындалды! МашаАллаһ', Lang.ru: 'Цель выполнена! МашаАллах'},
  'garden_done': {Lang.kz: 'Бақ толық өсті!', Lang.ru: 'Сад полностью вырос!'},
  'next_garden': {Lang.kz: 'Келесі бақ ашылды', Lang.ru: 'Открыт следующий сад'},
  'streak': {Lang.kz: 'күн қатарынан', Lang.ru: 'дней подряд'},
  'today': {Lang.kz: 'Бүгін', Lang.ru: 'Сегодня'},
  'locked_garden': {Lang.kz: 'Алдыңғы бақты аяқтаңыз', Lang.ru: 'Сначала закончите прошлый сад'},
  'reminder': {
    Lang.kz: 'Бұл — ынталандыруға арналған бейне. Нағыз сауап тек Алланың қолында.',
    Lang.ru: 'Это образ для мотивации. Настоящая награда только у Аллаха.'
  },
};

String tr(String key, Lang l) => _s[key]?[l] ?? key;
