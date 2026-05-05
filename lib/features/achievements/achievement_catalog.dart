import '../../shared/models/scanned_object.dart';

/// アチーブの分類。並び順や表示色のグループ化に使う。
enum AchievementCategory {
  quantity, // 数量
  rarity, // レア度
  attribute, // 属性
  event, // 特殊イベント
  hidden, // 隠し
}

class Achievement {
  final String id;
  final String title; // 日本語タイトル (中二訳)
  final String englishTitle;
  final String description;
  final AchievementCategory category;

  /// true なら未解除中はリストでマスクされ「???」表示。
  final bool secret;

  /// 解除条件。スキャン履歴全体を見て判定する純関数。
  final bool Function(AchievementCheckContext ctx) check;

  const Achievement({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.description,
    required this.category,
    required this.check,
    this.secret = false,
  });
}

class AchievementCheckContext {
  final List<ScannedObject> allObjects;

  AchievementCheckContext(this.allObjects);

  int get total => allObjects.length;

  bool hasRarity(String r) =>
      allObjects.any((o) => _normalizeRarity(o.rarity) == r);

  bool hasAttribute(String a) => allObjects.any((o) => o.attribute == a);

  Set<String> get attributesCollected =>
      allObjects.map((o) => o.attribute).toSet();

  /// 同じ objectCategory を 3 回以上スキャンしたか
  bool hasTripleSameCategory() {
    final counts = <String, int>{};
    for (final o in allObjects) {
      counts[o.objectCategory] = (counts[o.objectCategory] ?? 0) + 1;
      if (counts[o.objectCategory]! >= 3) return true;
    }
    return false;
  }

  /// 同じ日に全レア度（コモン～ミシック）を一度でも揃えたか
  bool hasAllRaritiesInSingleDay() {
    final byDay = <String, Set<String>>{};
    for (final o in allObjects) {
      final key =
          '${o.scannedAt.year}-${o.scannedAt.month}-${o.scannedAt.day}';
      byDay.putIfAbsent(key, () => <String>{}).add(_normalizeRarity(o.rarity));
    }
    final all = {'コモン', 'レア', 'エピック', 'レジェンダリー', 'ミシック'};
    return byDay.values.any((s) => all.every(s.contains));
  }

  /// 任意の filter にマッチするスキャンが存在するか
  bool hasAny(bool Function(ScannedObject) test) =>
      allObjects.any(test);
}

String _normalizeRarity(String r) {
  const map = {
    'Common': 'コモン', 'common': 'コモン', 'COMMON': 'コモン',
    'Rare': 'レア', 'rare': 'レア', 'RARE': 'レア',
    'Epic': 'エピック', 'epic': 'エピック', 'EPIC': 'エピック',
    'Legendary': 'レジェンダリー', 'legendary': 'レジェンダリー',
    'LEGENDARY': 'レジェンダリー',
    'Mythic': 'ミシック', 'mythic': 'ミシック', 'MYTHIC': 'ミシック',
    'Mythical': 'ミシック', 'mythical': 'ミシック', 'MYTHICAL': 'ミシック',
  };
  return map[r] ?? r;
}

// ─── Catalog ──────────────────────────────────────────────────────

const _attrs = ['炎', '氷', '雷', '闇', '光', '風', '地', '水', '無'];

const _attrTitle = {
  '炎': '炎 を 視 し 者',
  '氷': '氷 を 視 し 者',
  '雷': '雷 を 視 し 者',
  '闇': '闇 を 視 し 者',
  '光': '光 を 視 し 者',
  '風': '風 を 視 し 者',
  '地': '地 を 視 し 者',
  '水': '水 を 視 し 者',
  '無': '無 を 視 し 者',
};

const _attrEn = {
  '炎': 'WITNESS OF FLAME',
  '氷': 'WITNESS OF FROST',
  '雷': 'WITNESS OF THUNDER',
  '闇': 'WITNESS OF SHADOW',
  '光': 'WITNESS OF LIGHT',
  '風': 'WITNESS OF GALE',
  '地': 'WITNESS OF EARTH',
  '水': 'WITNESS OF TIDE',
  '無': 'WITNESS OF VOID',
};

final List<Achievement> achievementCatalog = [
  // ─── 数量 (5) ──────────────────────────────────────────
  Achievement(
    id: 'qty_first',
    title: '最 初 の 観 測',
    englishTitle: 'FIRST SIGHT',
    description: '初めての神器を視た。',
    category: AchievementCategory.quantity,
    check: (c) => c.total >= 1,
  ),
  Achievement(
    id: 'qty_10',
    title: '十 の 蒐 集',
    englishTitle: 'TEN GATHERED',
    description: '十柱の神器を蒐めた。',
    category: AchievementCategory.quantity,
    check: (c) => c.total >= 10,
  ),
  Achievement(
    id: 'qty_50',
    title: '半 百 の 観 測 者',
    englishTitle: 'FIFTY OBSERVED',
    description: '五十柱の神器を蒐めた。',
    category: AchievementCategory.quantity,
    check: (c) => c.total >= 50,
  ),
  Achievement(
    id: 'qty_100',
    title: '百 器 の 主',
    englishTitle: 'LORD OF A HUNDRED',
    description: '百柱の神器を統べた。',
    category: AchievementCategory.quantity,
    check: (c) => c.total >= 100,
  ),
  Achievement(
    id: 'qty_200',
    title: '蔵 人',
    englishTitle: 'KEEPER OF THE VAULT',
    description: '二百柱を超え、蔵の主となった。',
    category: AchievementCategory.quantity,
    check: (c) => c.total >= 200,
  ),

  // ─── レア度 (5) ────────────────────────────────────────
  // 「初コモン」は qty_first と被るので省略。
  Achievement(
    id: 'rarity_rare',
    title: '初 め て の 稀 品',
    englishTitle: 'FIRST RARE',
    description: 'レア神器を視た。',
    category: AchievementCategory.rarity,
    check: (c) => c.hasRarity('レア'),
  ),
  Achievement(
    id: 'rarity_epic',
    title: '初 め て の 至 宝',
    englishTitle: 'FIRST EPIC',
    description: 'エピック神器を視た。',
    category: AchievementCategory.rarity,
    check: (c) => c.hasRarity('エピック'),
  ),
  Achievement(
    id: 'rarity_legendary',
    title: '初 め て の 伝 承',
    englishTitle: 'FIRST LEGEND',
    description: 'レジェンダリー神器を視た。',
    category: AchievementCategory.rarity,
    check: (c) => c.hasRarity('レジェンダリー'),
  ),
  Achievement(
    id: 'rarity_mythic',
    title: '初 め て の 神 話',
    englishTitle: 'FIRST MYTH',
    description: 'ミシック神器を視た。',
    category: AchievementCategory.rarity,
    check: (c) => c.hasRarity('ミシック'),
  ),

  // ─── 属性 (10) — 9属性 + コンプ ─────────────────────
  for (final a in _attrs)
    Achievement(
      id: 'attr_$a',
      title: _attrTitle[a]!,
      englishTitle: _attrEn[a]!,
      description: '$a 属性の神器を視た。',
      category: AchievementCategory.attribute,
      check: (c) => c.hasAttribute(a),
    ),
  Achievement(
    id: 'attr_all',
    title: '九 属 の 統 合',
    englishTitle: 'NINEFOLD UNION',
    description: '九つの属性すべてを視た。',
    category: AchievementCategory.attribute,
    check: (c) => _attrs.every(c.hasAttribute),
  ),

  // ─── 特殊イベント (4) ──────────────────────────────
  // ScannedObject.scannedAt の時刻ベースで判定。
  Achievement(
    id: 'event_cursed_hour',
    title: '呪 わ れ し 刻',
    englishTitle: 'CURSED HOUR',
    description: '4:44 / 13:13 / 23:23 のいずれかで神器を視た。',
    category: AchievementCategory.event,
    check: (c) => c.hasAny((o) {
      final h = o.scannedAt.hour;
      final m = o.scannedAt.minute;
      return (h == 4 && m == 44) ||
          (h == 13 && m == 13) ||
          (h == 23 && m == 23);
    }),
  ),
  Achievement(
    id: 'event_friday_13',
    title: '十 三 の 金 曜',
    englishTitle: "FRIDAY THE 13TH",
    description: '13日の金曜日に神器を視た。',
    category: AchievementCategory.event,
    check: (c) => c.hasAny((o) =>
        o.scannedAt.day == 13 && o.scannedAt.weekday == DateTime.friday),
  ),
  Achievement(
    id: 'event_halloween',
    title: '万 聖 節 の 視',
    englishTitle: 'ALL HALLOWS EVE',
    description: '10月31日に神器を視た。',
    category: AchievementCategory.event,
    check: (c) =>
        c.hasAny((o) => o.scannedAt.month == 10 && o.scannedAt.day == 31),
  ),
  Achievement(
    id: 'event_new_year',
    title: '元 旦 の 兆',
    englishTitle: 'NEW YEAR OMEN',
    description: '1月1日に神器を視た。',
    category: AchievementCategory.event,
    check: (c) =>
        c.hasAny((o) => o.scannedAt.month == 1 && o.scannedAt.day == 1),
  ),

  // ─── 隠し (2) ────────────────────────────────────────
  Achievement(
    id: 'hidden_triple',
    title: '輪 廻 す る 視',
    englishTitle: 'SAMSARA OF SIGHT',
    description: '同じ物体を 3 回以上スキャンした。',
    category: AchievementCategory.hidden,
    secret: true,
    check: (c) => c.hasTripleSameCategory(),
  ),
  Achievement(
    id: 'hidden_all_rarities_one_day',
    title: '一 日 五 階',
    englishTitle: 'FIVE TIERS IN A DAY',
    description: '一日のうちに五つのレア度すべてを視た。',
    category: AchievementCategory.hidden,
    secret: true,
    check: (c) => c.hasAllRaritiesInSingleDay(),
  ),
];
