# Data Model

CHAOS VISION のローカル永続化スキーマと関連する正規化ルール。

## ScannedObject

`lib/shared/models/scanned_object.dart`、Hive `@HiveType(typeId: 0)`。

```dart
@HiveType(typeId: 0)
@JsonSerializable()
class ScannedObject {
  @HiveField(0) final String id;
  @HiveField(1) final String objectCategory;       // 元の物体名 (例: "冷蔵庫")
  @HiveField(2) final String alternateName;         // 中二異名 (例: "氷封の魔牢《フリージア・コア》")
  @HiveField(3) final String attribute;             // 属性 (例: "氷")
  @HiveField(4) final String description;           // 裏設定文
  @HiveField(5) final String rarity;                // レア度 (例: "コモン" or "Mythic")
  @HiveField(6) final DateTime scannedAt;
  @HiveField(7) final String? imageRelativePath;    // documents/scanned_images/scanned_<ts>.jpg からの相対
  @HiveField(8) final double confidence;            // 0.0〜1.0
}
```

**注意:** スキーマを変更したら必ず `flutter pub run build_runner build --delete-conflicting-outputs` を実行して `scanned_object.g.dart` を再生成すること。

`HiveField` 番号は**追加のみ**。既存番号の意味を変えると過去のデータが壊れる。

## 画像の保存戦略

写真本体は Hive に入れず、独立してファイルシステムに置く。

**保存場所:** `<getApplicationDocumentsDirectory()>/scanned_images/scanned_<millisecondsSinceEpoch>.jpg`

**Hive に保持するもの:** `imageRelativePath` (例: `scanned_images/scanned_1746345600000.jpg`)

**読み出し時:** `ScannedObject.getFullImagePath()` が `getApplicationDocumentsDirectory()` と結合して絶対パスを生成。

**理由:**
- iOS でアプリ更新するとアプリの documents パスが変わる場合がある (UUID 部分)。
  絶対パスを保存していると参照が壊れるが、相対パスなら毎回再解決できるので安全
- Hive のレコードサイズを抑えてパフォーマンス確保

**削除:** `ObjectDetailScreenV2._deleteObject()` が画像ファイルも `File.delete()` する。
`StorageService.clearAllData()` は Hive のみクリア (画像ファイルは残る — 既知の小さな leak)。

## 属性 (attribute)

`AppConstants.attributes` で定義。9 種類。

| 属性 | ロマ字 | 色 (hex) |
|---|---|---|
| 炎 | INFERNO | `#FF4444` |
| 氷 | GLACIER | `#44AAFF` |
| 雷 | TEMPEST | `#FFFF44` |
| 闇 | ABYSS | `#9966CC` |
| 光 | RADIANCE | `#FFFFAA` |
| 風 | GALE | `#44FF88` |
| 地 | TERRA | `#AA7744` |
| 水 | TIDE | `#4488FF` |
| 無 | VOID | `#888888` |

`AppColors.attributeColors[attribute]` でアクセス。

特殊イベント由来の属性として `時空 / 封印 / 虚無 / 混沌` も legacy code に残るが、
通常生成では出てこない。`_AttributeRomaji` 等のマッピングはこの 9 種類のみ網羅。

## レア度 (rarity)

`AppConstants.rarityLevels` で定義。5 階層。

| 日本語 | 漢字一字 | ロマ字 | rank |
|---|---|---|---|
| コモン | 常 | COMMON | 1 |
| レア | 稀 | RARE | 2 |
| エピック | 叙 | EPIC | 3 |
| レジェンダリー | 伝 | LEGENDARY | 4 |
| ミシック | 神 | MYTHIC | 5 |

**正規化:** AI レスポンスは英語 (例: `Mythic`) で来ることがあるので、
`StorageService._normalizeRarity()` が日本語に揃える。フィルター・ソート・統計はすべて
正規化後の値で動く。

**漢字一字マッピング:** `_kRarityKanji` (collection_screen_v2)、`_rarityShort` (各画面の helper)
で重複定義されている。今後共通化の余地あり。

## SpecialEvent

`lib/core/services/special_event_service.dart`。
当該時刻に発生する「超レア神器」モード。

```dart
enum SpecialEventType {
  none,
  ultraRareArtifact,    // 超レア神器
  dimensionDistortion,  // 次元歪曲現象
}

class SpecialEvent {
  final SpecialEventType type;
  final String name;                     // "次元歪曲現象" 等
  final String description;
  final double rarityMultiplier;         // AI プロンプトに渡してレア度を底上げ
  final Map<String, dynamic> config;
}
```

ホーム画面の `EventSealStamp` に表示。
`SpecialEventService.updateEventStatus()` を 1 分ごとに呼んで現在のイベントを判定 (HomeScreenV2 がタイマー保持)。

## SharedPreferences キー

`AppConstants` で定義:
```dart
static const String prefKeyFirstLaunch = 'first_launch';
static const String prefKeySoundEnabled = 'sound_enabled';
static const String prefKeyEffectsEnabled = 'effects_enabled';
static const String prefKeyLanguage = 'language';
```

**現状:** ほぼ未配線。設定画面が無い (= ユーザーが切り替える UI が無い) ため。
将来 `効 設 定` 等の歯車画面を作る際に使う想定。
