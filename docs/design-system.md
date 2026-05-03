# Design System — Forbidden Codex

CHAOS VISION の v2 ビジュアル言語は「**禁忌教典 (Forbidden Codex)**」と名付けています。
ペルソナ5の編集的・斜め非対称構図 × 古代占星術書 × 占い計器、を中二病スキャナーに翻案。

## コンセプト 4 原則

1. **古文書の頁を捲る感覚** — 縦書き spine、章番号 (Ⅰ〜Ⅸ)、奥付、コロフォン
2. **精緻なヘアライン** — 太い塗り潰しよりも細い金線・点線・bracket 装飾
3. **AR 計器の HUD** — 走査線、十字 crosshair、メタストリップ、漢字方位マーク
4. **儀式の劇性** — 入場時のドラマチックな入場、円形遷移、巨大な真名 typewriter

過剰な glow / blur / 透過は最小限。"濡れた wax" 風の柔らかい立体は禁止
(過去に蝋印が浮く問題が発生 → 六角形 sigil に置換した経緯)。

## カラーパレット

`lib/core/constants/app_colors.dart` の `Forbidden Codex palette` セクション。

| トークン | hex | 主な用途 |
|---|---|---|
| `inkBlack` | `#0A0805` | 通常背景 (warm near-black) |
| `inkDeeper` | `#050302` | 最深部 / vignette / モーダル背景 |
| `blood` | `#8B1A1A` | 古血の赤 (背景・ボーダー陰) |
| `bloodBright` | `#C8102E` | 強調・警告・SCAN・破壊操作 |
| `goldTarnish` | `#A18540` | 経年金 (区切り線・サブ罫線) |
| `goldLeaf` | `#D4AF37` | 金箔 (主アクセント・メインアイコン) |
| `bone` | `#E8DCC4` | 羊皮紙色 (本文テキスト・主タイポ) |
| `boneDim` | `#6B5F4D` | 褪せたインク (補足・ディム) |
| `violetDeep` | `#2D1A4F` | 深紫 (補助・成功 toast) |
| `frost` | `#7FBED1` | 氷青 (3つ目の tile / 並び替えチップ) |
| `frostDeep` | `#3A6B7E` | frost の dim 版 |

レガシー名 (`primary` `secondary` 等) も残っているが、新規 widget は Codex 名を使うこと。

属性カラー (`attributeColors`) とレア度カラー (`rarityColors`) はそのまま継続使用
(image color grade、rarity 蝋印の色等)。

## タイポグラフィ

すべて `google_fonts` から動的取得 (初回起動時にネット必要、以降キャッシュ)。

| 用途 | フォント | 例 |
|---|---|---|
| 大見出し (英) | **Bodoni Moda Italic** | `CHAOS / VISION`, `RESCAN`, `RETURN` |
| 日本語 (見出し / 本文) | **Shippori Mincho** | `中二スキャナー`, `真 名`, `観 測 の 儀` |
| メタ / モノスペース | **JetBrains Mono** | `// EDITION 1.0.2`, `INFERNO`, `NEWEST` |

### よく使うパターン

- 日本語見出し: `letterSpacing: 4-8` で**広めに空ける** (儀式感)
- 章ヘッダー: `kanji ─── ROMAN` (e.g. `異 聞 ─── LORE`)
- メタストリップ: `// LABEL  ─  VALUE  ─  TIMESTAMP` (mono 9-10pt)
- ローマ字補助: 上の和文より小さい mono、属性色 alpha 0.85

## モチーフ

### 漢字一文字シジル

各画面・タイル・章に**漢字一字**を割り当ててアイデンティティを作っている。
新しい画面を作るときも踏襲すること。

| 用途 | 漢字 | 意味 |
|---|---|---|
| ホームタイル | `視` `蔵` `識` | スキャン / 図鑑 / 知識 |
| スキャナー方位マーク | `北 東 南 西` | viewfinder の四方 |
| アクションタイル | `共` `帰` `視` | 共有 / 戻る / 再観測 |
| レア度 (蝋印) | `常 稀 叙 伝 神` | コモン / レア / エピック / レジェンダリー / ミシック |
| 法的書類 | `誓` `律` `伝` | プライバシー / 規約 / 連絡 |
| 章立て | `概 念` `儀 式` `顕 現` 等 | DOCTRINE / RITUAL / EMERGENCE |

### 六角形 (hex) シジル

`WaxStamp` (旧名 wax だが**現在は六角形メダリオン**) のベース形状。
頂点 6 ドット + 辺 6 tick + 二重ヘアライン。
レア度色を縁に、内側は inkBlack 塗り。

### ブラケットコーナー

`L 字` の太い線 + 角ドット。viewfinder、画像枠、IndexTile 等で使用。
`tick` 長は 14-26px、線幅 1.0-2.0px。

### 漢字バックドロップ

`KanjiBackdrop` widget。`禁` `視` を巨大に半透明配置（ホーム / 詳細系画面の地紋）。
背景に深みを与える。

### 走査線・グレイン

- `ScanlineOverlay` — 3px 間隔の薄い水平線 (alpha 0.035)
- `GrainOverlay` — procedural ノイズ (`density 1400-2200`、alpha 0.05-0.07)

両方とも `Positioned.fill` + `IgnorePointer` で常に最前列。

## 効果 (Effects)

### 属性カラーグレード (写真用)

`CodexImageFrame` 内: `ColorFilter.mode(attributeColor, BlendMode.color)` α 0.4。
luminance を保持しつつ色相のみ属性側にシフト。炎なら赤橙、氷なら青。

### 霊視オーバーレイ (写真用)

写真上に `MagicCircleWidget(animate: false)` を 78% サイズ・α 0.22 で重ねる。
"スキャンした真の姿が透けて見える" 感を演出。

### スキャン儀式 (`_ScanRitual` in scanner_screen_v2.dart)

3 層魔法陣:
- 外輪 (CW 9s): 56dash + 24tick + 12 sigil dot (blood)
- 中輪 (CCW 5s): 六芒星 + 6 vertex dot (gold)
- 内輪 (CW 3s): 逆三角形 + 3 vertex dot (blood)
- 中心: 1.1s 脈動 glow + 骨色 crosshair

入場 600ms (scale 0.55→1.0 + opacity 0→1, easeOutCubic)。

### 円形 reveal 遷移

`_CircularRevealClipper`。スキャナー → 結果画面で使用。
中心 (画面横中央, 縦 42%)、半径 = 画面対角線 × progress。
720ms 進入 / 480ms 戻り。

### Haptic

- シャッター押下: `HapticFeedback.heavyImpact()`
- AI 完了 → 結果画面遷移直前: `HapticFeedback.mediumImpact()`

## 必須レイアウトパターン

### 狭幅対応

iPhone SE (375pt) でレイアウトが崩れないこと。常に以下を考慮:

- 長い英字メタ → `Flexible(child: FittedBox(scaleDown, child: Text(maxLines:1, softWrap:false)))`
- 強調タイトル → `FittedBox(scaleDown)` で個別に縮小
- 複数行になり得る日本語 → `strutStyle: forceStrutHeight` で行高固定

### 章構造

`CodexLegalScaffold` で導入したパターン (`docs/services.md` 参照):
```
[CodexSection kanji: '一  ・  概  要', roman: 'OVERVIEW']
  CodexSubheading('1.1  サービス内容')
  CodexBody('...')
  CodexBullets(items: [...])
[CodexSection]
  ...
```
Privacy / Terms 以外でも、長文を持つ画面で使い回せる。

## アニメーション一覧

| 場面 | 種類 | duration | curve |
|---|---|---|---|
| ホーム入場 | fadeIn + slideY | 700-1500ms | easeOutCubic |
| ホームタイル staircase | fadeIn + slideY (delay 段階的) | 600-700ms | easeOutCubic |
| 真名 typewriter | 順次表示 | 75ms/字 + 50ms/字 | linear |
| 円形 reveal | progress 0→1 | 720ms | easeOutCubic |
| スキャン儀式入場 | opacity + scale | 600ms | easeOutCubic |
| 蝋印 / sigil 入場 | fadeIn | 600-900ms | easeOutCubic |
| GrimoireCard グリッド | 段階 fadeIn | 350ms each, stagger 40ms | linear |

`flutter_animate` の `.animate().fadeIn()...slideY()` パターンで統一。

## "やってはいけない"集

- `Material(color: ...)` の塗り潰しを背景に使う (codex は黒地が必須)
- `borderRadius` を画像枠に付ける (codex はシャープなブラケット)
- 円形 → 角丸ロゴへの変更 (六角 / 直線が世界観の核)
- `Inter` `Roboto` `Arial` 等の generic フォントを直接指定する
- 派手な紫 / 蛍光色アクセント (palette 外)
- 過度な BlurStyle.normal で foreground テキストをぼかす
