# CHAOS VISION ドキュメント

このディレクトリは「将来の自分 / 担当する Claude セッション / 共同作業者」が
プロジェクトの文脈をすばやく取り戻すための索引と詳細仕様の置き場です。

CLAUDE.md（リポジトリ直下）は AI 用に毎回読み込まれる短い概要、
こちら docs/ は読み込み式の詳細仕様、という役割分担です。

## 目次

- [architecture.md](architecture.md) — レイヤ構成、データフロー、技術スタック
- [design-system.md](design-system.md) — 「禁忌教典」ビジュアル言語（色／フォント／モチーフ／効果）
- [screens.md](screens.md) — 画面カタログ（各画面のコンセプト名・主要 widget・遷移）
- [services.md](services.md) — サービス層の責務と API 概要
- [data-model.md](data-model.md) — `ScannedObject` / Hive スキーマ / 正規化
- [decisions.md](decisions.md) — 重要な設計決定と背景

## 現在のスナップショット

- バージョン: `1.0.2+1`
- 最新コミット (本ドキュメント作成時): `98b3cf8`
- 主要画面リメイク: 全 9 画面 (Forbidden Codex v2) 完了
- 旧 v1 ファイル: 削除済み (`chore: drop v1 screens` でクリーンアップ)
- ファイル名は `_v2` サフィックスのまま（リネームは保留中）
- テスト: `flutter test` で 11 件パス、`StorageService` を中心にカバー
- iOS 配布: 未実施（v1.0.2 の TestFlight も未）

## 既知の事項 / TODO

| 区分 | 内容 |
|---|---|
| 🔴 セキュリティ | 旧 OpenAI API キーは revoke 済。履歴も `git filter-repo` で除去済。**新しいキーが必要** (現状ダミーレスポンスで動く) |
| 🟡 ビルド | `flutter analyze` は環境依存でクラッシュ。常に `dart analyze` を使う |
| 🟡 メモリ | `MemoryMonitorService` の低メモリモード自動切替・定期チェックは無効化されている (`main.dart:21-25`)。過去に不安定だった経緯あり |
| 🟡 macOS | macOS desktop ビルドは debug 用に動く (Xcode 検証用)。リリース配布は iOS のみ前提 |
| 🟢 残作業 | TestFlight 配布、v1.0.3 bump、SE 音声追加、`_v2` サフィックス削除等 |

## このリポジトリで作業を再開する人へ

1. CLAUDE.md を読む（毎回読み込まれるので最新の概要が書いてある）
2. このディレクトリの該当ドキュメントを必要に応じて参照
3. 大きな変更を入れる前に [decisions.md](decisions.md) で「なぜ今の形か」を確認
4. 開発コマンドは CLAUDE.md / README_SETUP.md にも書いてあるが、実機で動かす際は API キーを `--dart-define=OPENAI_API_KEY=...` で渡すこと（未指定でもダミーで起動はする）
