# Screens

各画面のコンセプト名・章番号・主要 widget・遷移をまとめます。
コンセプト名は意図的にチューニ感がある名称、章番号は footer に表示される
ローマ数字 (Ⅰ〜Ⅸ) です。

## 画面一覧

| 番号 | コンセプト | ファイル | 役割 |
|---|---|---|---|
| Ⅰ | **Forbidden Codex** | `features/home/home_screen_v2.dart` | エントリ画面 |
| Ⅱ | **Rite of Observation** | `features/scanner/scanner_screen_v2.dart` | カメラスキャン |
| Ⅲ | **Seal Undone** | `features/scan_result/scan_result_screen_v2.dart` | スキャン直後の AI 結果開示 |
| Ⅳ | **Grimoire Index** | `features/collection/collection_screen_v2.dart` | スキャン履歴の図鑑 |
| Ⅴ | **Specimen Record** | `features/collection/object_detail_screen_v2.dart` | 個別エントリの詳細閲覧 |
| Ⅵ | **Arcanum** | `features/about/app_info_screen_v2.dart` | アプリ情報・遊び方 |
| Ⅶ | **Dispatch** | `features/contact/contact_screen_v2.dart` | お問い合わせ |
| Ⅷ | **Privacy Policy** | `features/legal/privacy_policy_screen_v2.dart` | プライバシー (chrome のみ codex) |
| Ⅸ | **Terms of Service** | `features/legal/terms_of_service_screen_v2.dart` | 利用規約 (同上) |

## Ⅰ Forbidden Codex (Home)

エントリ画面。ペルソナ5的な編集的非対称構図で「禁書を開いた瞬間」を演出。

**主要要素:**
- `SpineLabel` — 左端の縦書き製本背 `禁忌教典 Ⅰ ─ CHAOS VISION ─ Ⅺ.MMXXVI`
- `KanjiBackdrop` — 巨大な薄い `禁` `視` 漢字
- `CodexHeader` — `// EDITION 1.0.2 ─ ENTRY №.001` + 巨大 Bodoni Italic タイトル + 中二スキャナー + ステータスストリップ
- `MantraBlock` — 引用 `現実は── 此の眼に映る幻にすぎぬ`
- `MagicAuraCircle` — 右上に半クリップ
- `EventSealStamp` — 特殊イベント発火中のみ表示
- `IndexTile` × 3 (階段状オフセット)
  - `01 視 SCAN` (primary, blood)
  - `02 蔵 CODEX` (secondary, gold)
  - `03 識 ARCANUM` (tertiary, frost)
- `FooterMarginalia` — `─ Ⅰ ─` + version

**遷移:**
- `01 SCAN` → `ScannerScreenV2` (PageRouteBuilder fade+slide)
- `02 CODEX` → `CollectionScreenV2`
- `03 ARCANUM` → `AppInfoScreenV2`

## Ⅱ Rite of Observation (Scanner)

カメラフィード上に占い計器の HUD を被せる。

**主要要素:**
- `_CameraSurface` — 微妙な色補正 (`ColorFilter.matrix` でクール寄り) + `_Vignette`
- `GrainOverlay` (low alpha)
- `HudMetaBar` — 戻る + `// 観 測 の 儀 ─ RITE OF OBSERVATION` + 4-dot scan indicator + `LENS / APERTURE / GRIMOIRE` メタ
- `RuneFrame` — L字ブラケット枠 + 北東南西の漢字方位 + crosshair。走査時 scan beam が天地に動く
- `_ScanRitual` (走査時のみ表示) — 3 層魔法陣 (外輪 CW / 中輪 CCW / 内輪 CW + 中心 glow)
- `_ScanFlash` — シャッター押下時の血赤フラッシュ
- `_RiteCaption` — 段階表示 `霊 視 受 信 中 → 真 名 解 読 中 → 属 性 鑑 定 中 → 封 印 生 成 中`
- `RitualShutter` — 眼の印章カスタム描画ボタン (アイドル: pulse / 走査: 外周 dash 回転 + 血赤化)
- `_PageMark` — `― Ⅱ ―`

**フロー:**
1. シャッタータップ → `HapticFeedback.heavyImpact()` + `_isScanning = true`
2. `_ScanFlash` (フラッシュ) + `_ScanRitual` (魔法陣展開)
3. `CameraService.takePicture()` → `_persistImage()` でアプリ documents に保存
4. `AIService.analyzeImageAndGenerate(path)` で `objectCategory` `alternateName` `attribute` `description` `rarity` を取得
5. `StorageService.saveScannedObject(obj)`
6. `HapticFeedback.mediumImpact()` + `_revealRoute(obj)` で円形 reveal 遷移
7. `ScanResultScreenV2` がマウントされ、戻ってくると `_isScanning = false`

**特殊ステート:**
- `_permissionDenied` 時 → `RiteLoading` を `視 力 が 封 じ ら れ て い る` で表示、再試行ボタン
- `_isInitialized = false` 時 → `RiteLoading` で `異 界 へ 接 続 中` + ステップ表示

## Ⅲ Seal Undone (ScanResult)

スキャン直後の最大ドラマ。AI が解読した「真名」を typewriter で出す。

**主要要素:**
- ヘッダー: 戻る + `封 印 解 除 / SEAL UNDONE` + 共有 (shareService 経由)
- メタ行: `// ENTRY No.013 ─ XI.MMXXVI ─ 2026.05.03 21:32`
- `CodexImageFrame` — 写真 + 属性カラーグレード + 霊視 magic circle + ブラケット + 蝋印 (レア度漢字 + SIGIL)
- `_TrueNameBlock` — `真 名` ヘッダー + 1 文字ずつ typewriter する大字 (主名) + 2 行目 (`《カタカナ》` 部分) + `※ 元 の 姿 ─ ◯◯`
- `_ChipRow` — 属性 / 階級の双子チップ (kanji + romaji)
- `_LoreBlock` — `異 聞 ─── LORE` + Mincho 本文
- `_Readings` — `計 測 ─── READINGS`: TIMESTAMP / CONFIDENCE バー (アニメーション fill) / ARCHIVED
- `_ActionTiles` — `視 RESCAN` (戻る) + `帰 RETURN` (popUntil first)
- `_Footer` — `― Ⅲ ―` + ENTRY 番号

## Ⅳ Grimoire Index (Collection)

個人の禁書館。スキャン済アーティファクトの一覧 + フィルター。

**主要要素:**
- `_Header` — `神 器 図 鑑 / GRIMOIRE INDEX` + 件数バッジ + 削除 rune
- `_StatusPanel` — 横スクロール 6 chip: `[全 17] [常 12] [稀 4] [叙 1] [伝 0] [神 0]` (各タップでレア度フィルター ON/OFF)
- `_SecondaryFilters` — `属 性` (modal) + `並` (cycle: 新→古→級→属) + RESET
- `_Grid` — 2 列のスタガー fadeIn グリッド、`GrimoireCard` で表示
- `_FilterSheet` — 属性選択モーダル (codex pill list)
- `_DeleteAllDialog` — `完 全 消 去 / 此 の 業 は 還 ら ぬ` + 止む / 断つ
- `_Footer` — `― Ⅳ ─ GRIMOIRE`

`GrimoireCard` (in `shared/widgets/codex/grimoire_card.dart`):
- 1:1 写真 + 属性ブラケット + 小型 hex sigil + `No.013` メタタグ
- 下部: 異名 (《》前のみ抽出) + 属性漢字 + レア度ロマ字

## Ⅴ Specimen Record (ObjectDetail)

`Seal Undone` と同型の構造を「閲覧」用に調整。typewriter なし、削除 rune を持つ。

**違い:**
- ヘッダー: `神 器 詳 録 / SPECIMEN RECORD` + 戻る + 削除 rune (blood)
- メタ行: `// ARCHIVE No.013` (ENTRY ではなく ARCHIVE)
- 真名: 即時表示 (タイプアウトなし)
- アクションタイル: `共 SHARE` + `帰 RETURN`
- 削除ダイアログ (`_DeleteDialog`): 神器消去 + 属性色プレビューブロック

## Ⅵ Arcanum (AppInfo)

「創始者の覚書」、新人へ儀式を教える序文。

**章立て:**
- Frontispiece: 大型 Bodoni `CHAOS VISION` + 中二スキャナー副題 + マントラ引用
- `概 念 / DOCTRINE` — アプリ概要
- `儀 式 / RITUAL` — 5 ステップ (`視を押す → 視界に捉え → シャッター → AI解読 → 自動封印`)
- `顕 現 / EMERGENCE` — 4 イベント枠 (呪われた時刻 / 13日金曜 / 聖なる日付 / 次元歪曲)
- `属 性 / ATTRIBUTES` — 9 属性ロスター (色バー + kanji + romaji + 説明)
- `書 類 / TOMES` — 3 リンクタイル `誓 PRIVACY` `律 TERMS` `伝 CONTACT`
- `奥 付 / COLOPHON` — 版数 + 本のコロフォン風

## Ⅶ Dispatch (Contact)

書状を送る連絡画面。

**章立て:**
- Lede: `書` 漢字ボックス + `書 を 寄 こ す が よ い`
- `用 件 / PURPOSE`
- `連 絡 先 / EMISSARY` — メアド (SelectableText + コピー) + `送 COMPOSE DISPATCH` タイル (`mailto:` 起動)
- `必 携 / REQUIRED CONTEXT` — 機種 / iOS / 版数 / 再現手順 / 影写
- `但 し 書 / CAVEATS`

メールアドレス: `web-studio@ymail.ne.jp` (このコードに直書き)。

## Ⅷ Privacy / Ⅸ Terms

`CodexLegalScaffold` (`shared/widgets/codex/codex_legal_scaffold.dart`) を使った
"chrome のみ codex 化、本文は読みやすさ優先" の方針。

**章立て構造のヘルパー:**
- `CodexSection(kanji, roman, children)` — `kanji ─── ROMAN` 罫線ヘッダー + ボディスロット
- `CodexSubheading(text)` — 1.1 / 1.2 等の下位見出し (金縦バー)
- `CodexBody(text)` — Mincho パラグラフ (13pt / 1.85)
- `CodexBullets(items: [...])` — 金ドットの箇条書き
- `CodexImprint(established, revised, copyright)` — 奥付風

文章自体は v1 のまま。レイアウト/タイポのみ刷新。

---

## 命名上の注意

すべての画面が `_v2` サフィックスを持つ。これは旧 v1 と並存させていた名残で、
v1 を削除した後もリネームコストを避けて維持している。
新画面を追加する場合は、新規なら `_v2` 不要 (シンプルな名前で OK) だが、
既存のリネームは別タスクで一気にやる方針。詳細は [decisions.md](decisions.md)。
