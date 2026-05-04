# Decisions

このプロジェクトの今ある形に至る重要な選択と背景を時系列で残します。
新たに大きな変更を加える前に、ここを読んで「なぜこうなっているか」を確認してください。

---

## D-001: 物体検出は OpenAI Vision の単発呼び出しで行う (ML Kit を使わない)

**選択:** ML Kit / Cloud Vision 等の **物体分類専用 API は使わない**。OpenAI gpt-4o-mini の
画像入力で「物体カテゴリの認識」と「中二異名・属性・裏設定の生成」を**1リクエストにまとめる**。

**背景:**
- アプリの主目的はエンタメ (中二病的な解釈)。物体分類の精度より「面白い結果」が重要
- AI 1 回呼び出しで全情報を生成する方が、UI の状態遷移がシンプル
- ML Kit は端末リソースを食う上、Vision API キーの管理が増える
- gpt-4o-mini は安価で、Vision タスクの精度も実用上十分

**含意:**
- AI 応答に依存するフィールド (objectCategory / alternateName / attribute / description / rarity) を
  単一の Map で受け取る
- API キー必須。未設定時は `_generateDummyFromImage` がダミーで返す (オフライン開発・初期確認用)

---

## D-002: API キーをハードコードからdart-defineへ移行 + 履歴除去

**選択:** OpenAI API キーは `String.fromEnvironment('OPENAI_API_KEY')` 経由で受け取る。
**初期コミットで誤ってハードコードされていたキーは revoke + `git filter-repo` で全コミット履歴から除去**した。

**背景:**
- 2026-05-03 の整備中、`lib/core/constants/app_constants.dart:12` に本番キーが直書きされていることを発見
- README_SETUP.md の指針 (`--dart-define`) と矛盾していた
- ユーザーがキーを revoke した上で、`git filter-repo --replace-text` で全コミットの当該文字列を `REDACTED_OPENAI_KEY` に置換 → force push

**含意:**
- 履歴に旧キーは残っていない (確認済)
- `clean-main` ブランチを `main` に統合し、リモートも `main` を default に
- バックアップタグ `backup-before-filter-repo` `backup-main-before-filter-repo` がローカルに残存
  (1〜2週間後に削除推奨)

---

## D-003: 全画面を「Forbidden Codex」コンセプトで v2 リメイク

**選択:** 既存 v1 画面群はすべて、ペルソナ5×古文書ハイブリッドの新しいデザイン言語に置き換える。
コンセプト名・章番号を画面ごとに割り振る。

**背景:**
- 元の v1 はテンプレ的なダーク UI で、アプリの「中二病」エッセンスが伝わらなかった
- ユーザーが design 大幅 upgrade を希望、「センスに任せる」と委任
- ペルソナ5 (アグレッシブな非対称・編集レイアウト) を起点に、占星術書 / 計器 HUD を融合

**含意:**
- 9 画面すべてを `_v2.dart` ファイルとして並行開発、確認後に main で v1 削除
- `lib/shared/widgets/codex/` 以下に共通 widget 群を集約
- 詳細は [design-system.md](design-system.md) と [screens.md](screens.md)

---

## D-004: v1 削除後も `_v2` サフィックスを維持

**選択:** v1 画面ファイル群は削除したが、v2 ファイル群のリネーム (例: `home_screen_v2.dart` → `home_screen.dart`) は**しない**。

**背景:**
- v1 と v2 を並行運用していた時期にロールバック保険として `_v2` を付けていた
- v1 削除後にユーザーへリネーム提案 → 「いいえ」と回答
- 機能的影響はゼロ。クラス名 (`HomeScreenV2`) も file 名と整合しているので一貫性は保てる

**含意:**
- 新画面を追加する場合は `_v2` 不要 (シンプルな名前で OK)
- 将来「v3」が始まるときにまとめてリネームする可能性は残す

---

## D-005: 蝋印を「濡れた wax 風」から「六角形メダリオン」に作り直し

**選択:** 当初 `WaxStamp` widget は不規則な blob + glow + 内側ハイライトで「蝋を押した」見た目だったが、
ユーザーの「世界観と合わない、浮いて見える」フィードバックを受けて
**精緻なヘアラインの六角形メダリオン**に作り直した (`_ArchiveSigilPainter`)。

**背景:**
- Forbidden Codex 全体の言語は「ヘアライン精緻 / ブラケット / 直線」
- 柔らかい blob + 強い glow は、その言語と矛盾していた
- 占星術 / 結界の文脈で六角形は意味的にもフィット

**含意:**
- クラス名は `WaxStamp` のまま (import 影響回避)
- glow / blur は最小限に。形は完全に六角形 (12 頂点ドット + 12 辺 tick + 二重ヘアライン)
- ScanResult / ObjectDetail / GrimoireCard / ShareCard で同じ widget を size 違いで使い回し

---

## D-006: 共有はテキストだけでなく画像付きで送る

**選択:** `ScanResult` / `ObjectDetail` の共有は、`Share.share` ではなく `Share.shareXFiles` で
**動的生成した PNG 画像 + キャプション** を送る。

**背景:**
- テキストだけだと SNS のプレビューに何も写らず弱い
- ユーザーフィードバックで画像強化を希望

**実装:**
- `ShareCard` widget (`lib/shared/widgets/codex/share_card.dart`) を 360×360 (1080×1080@3x) で構成
- Twitter / Instagram / Threads のプレビュー crop で見切れない 1:1 比率を採用
- `OverlayEntry` で off-screen にレンダ → `RepaintBoundary.toImage(pixelRatio: 3.0)` で PNG 化
- `getTemporaryDirectory()/share/chaos_vision_<id>.png` に書き出して共有
- `sharePositionOrigin` を `MediaQuery` から計算して渡す (iOS の必須引数化を回避)

---

## D-007: 検索バーは廃止、フィルターは status panel + sort cycle に集約

**選択:** `Grimoire Index` の検索バーを削除。代わりに**横スクロールのレア度 chip** ([全/常/稀/叙/伝/神]) で
クリックフィルター、別行に**属性 modal + 並び替え cycle ボタン**を配置。

**背景:**
- 図鑑のレコード件数は数百件規模。多くのユーザーは検索より属性/レア度ブラウジングを使う
- 検索バーが縦 50pt 食っており、グリッドの可視領域を圧迫
- レア度 chip は count を見せられるので「収蔵概況」と兼用できる

**含意:**
- `StorageService.getObjectsWithFilters` の `searchQuery` パラメータは内部 API のみ残存 (UI から呼ばれない)
- 必要なら将来「ヘッダの🔍アイコン → モーダルで検索」を追加する余地あり

---

## D-008: テストは StorageService に絞った最小カバレッジ

**選択:** v1 時代に書かれていたテストはすべて削除し、`StorageService` のみ 11 件の焦点テストで再構築。
画面の widget test や AI service の mocking は当面しない。

**背景:**
- 旧テストは API 変更を追えておらず壊れていた
- google_fonts がテスト環境でフォントを動的取得しようとして smoke test が失敗
- 個人開発・iPhone 手動確認中心、自動テストはリファクタ時の安全網が目的
- StorageService がデータ整合性のコアなので、ここだけ硬く守れば十分

**実装:**
- `test/unit/storage_service_test.dart` (11 tests) — CRUD / フィルター / ソート / ページネーション / 統計
- `path_provider` を `TestDefaultBinaryMessenger.setMockMethodCallHandler` でスタブ → Hive.initFlutter() を成立させる
- `flutter test` がグリーン

**将来余地:**
- 画面 widget test を書くなら `GoogleFonts.config.allowRuntimeFetching = false` + 必要フォントをアセット同梱
- AIService は HTTP モックで integration tests を組む価値あり (キー漏洩防止のためテスト環境専用キーを使う)

---

## D-009: テストツールから mockito + AI service 専用ファイル群を削除

**選択:** `mockito` パッケージ自体は pubspec から外していないが、関連する `*.mocks.dart` 生成物と
empty stub の `ai_service_test.dart` は削除した。

**背景:**
- `mockito` は AI service テスト専用に入れたが、当該テストが空のまま放置されていた
- 旧 mocks ファイルは古い AI service 実装に依存しており、再生成も走っていなかった

**含意:**
- 将来 mocking を始めたい場合は、`mockito` を使うか `mocktail` 等への移行を検討
- `pubspec.yaml` から mockito を抜くのは tightening として後でも可能

---

## D-010: ローディング演出を codex 化、SE は保留

**選択:** 各種ローディング (スキャナー処理中・図鑑読込・ページネーション・共有生成) を `CodexLoader` に統一。
SE (効果音) は将来 (audioplayers が依存に入っているが現状未配線)。

**背景:**
- 体感時間 2-5 秒の AI 処理中、画面の動きが少なすぎて停止に見えていた
- SE は素材の調達 + 音量・タイミング設計が必要で、別タスク化したい

**実装 (Codex Loader):**
- `lib/shared/widgets/codex/codex_loader.dart` — 魔法陣 + label + sublabel
- スキャナー: 段階表示 (`霊視受信中 → 真名解読中 → 属性鑑定中 → 封印生成中`) を 750ms ごとに進行
- 図鑑: 大型 `MANIFESTING ARTIFACTS`
- ページネーション: 36pt の小型
- 共有生成: 全画面オーバーレイ `封 を 解 い て お る / PREPARING THE DISPATCH`

---

## D-011: AI 通信を Cloudflare Worker proxy 経由に切り替え

**選択:** OpenAI を直接叩かず、自前の Cloudflare Worker proxy (`worker/`) を経由する
構成に切り替えた。アプリバイナリには OpenAI キーが入らず、Worker と共有する
`CHAOS_APP_SECRET` (Bearer トークン) のみを持つ。

**背景:**
- ¥300 買い切りモデルで配布する関係上、IPA 抽出による OpenAI キー漏洩 →
  攻撃者が無制限に OpenAI を叩いて課金が爆発するリスクが現実的
- D-002 で revoke + history rewrite はやったが、**dart-define で渡したキーは
  バイナリの Dart スナップショットに焼き込まれる**ので、根本対策にならない
- バックエンドプロキシが正攻法。Cloudflare Workers Free Tier (100k req/day) で
  個人アプリの規模なら無料運用可能

**実装:**
- `worker/` に TypeScript Cloudflare Worker (`POST /scan` エンドポイント)
- secret は `wrangler secret put` で Cloudflare 側に登録 (`OPENAI_API_KEY`,
  `APP_SECRET`)
- Worker は `model='gpt-4o-mini'` / `max_tokens=300` / `detail='low'` /
  `SYSTEM_PROMPT` をすべて server-side で固定 → 仮に `APP_SECRET` が漏れても
  攻撃者は CHAOS VISION 用 chuuni 解読しか叩けない
- アプリ側 `AIService` は `${WORKER_URL}/scan` に `{ imageBase64 }` を投げる
  だけのシンプル実装に書き換え。古い system prompt / parser dead code を削除
- ローカル開発は `secrets.json` (gitignored) に値を書いて
  `flutter run --dart-define-from-file=secrets.json` で起動

**含意:**
- プロンプト改善が**アプリ更新を伴わない**で可能 (Worker デプロイのみ)
- 鍵ローテーションも `wrangler secret put` で即時反映
- 将来 Apple Receipt 検証や KV ベースのレート制限を Worker で追加できる
  (現状は素の Bearer 認証のみ)
- `--dart-define-from-file` を忘れると `Generated.xcconfig` の `DART_DEFINES`
  が空のままビルドされ、ダミー応答に戻る → Makefile / シェルスクリプト化が望ましい

---

## メモ: 今後の議論余地

**未決定事項:**
- `_v2` サフィックスのリネームをいつやるか (D-004 の延長)
- SE の音源と配置 (D-010 の続き)
- Settings 画面の追加 (`AppConstants.prefKey...` を実際に生かす)
- テスト (D-008) の widget test 補強
- iOS 配布: TestFlight 設定、ストアメタデータ、スクリーンショット (1.0.3 bump も含む)
- 物体認識モード追加 (現在のチューニ生成と別の路線、例えば真面目な分類)
- Worker レート制限 (KV namespace + IP 別カウンタ) の実装
- Apple Receipt 検証で購入済みユーザーのみ Worker を通す (D-011 の延長)
- 開発時の `--dart-define-from-file` 忘れ対策 (Makefile / scripts/dev.sh)
