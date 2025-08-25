# 📱 CHAOS VISION - 中二スキャナー

> **現実世界の物体にAIが生成する中二病的な異名と壮大な設定を付与するARエンタメアプリ**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

CHAOS VISIONは、スマートフォンのカメラで現実世界の物体をスキャンし、AIが生成する壮大で中二病的な異名と設定を付与するエンターテイメントアプリです。日常の冷蔵庫が「氷封の魔牢《フリージア・コア》」に、あなたのスマートフォンが「次元通信術式端末《インフィニティ・リンク》」に生まれ変わります。

## ✨ 主な機能

### 🔍 リアルタイムARスキャン
- **AI生成**: OpenAI GPT APIを使用した創造的な異名・設定生成
- **AR演出**: 魔法陣エフェクトとアニメーション

### 📚 神器図鑑システム
- **コレクション管理**: スキャンした「神器」の永続保存
- **属性システム**: 炎・氷・雷・闇・光・風・地・水の8属性
- **レア度分類**: 通常・レア・超レア・伝説・神話の5段階
- **検索・フィルター**: 属性、レア度、キーワードによる柔軟な検索

### 🎭 特別イベント
- **時限イベント**: 特定の時間帯・日付での超レア神器出現
- **次元歪曲モード**: 突発的な演出強化モード

### 📱 ソーシャル機能
- **シェア機能**: 生成された神器情報をSNS投稿
- **カスタマイズ**: 音響効果・エフェクトの設定変更

## 🚀 セットアップガイド

### 必要環境
- **Flutter**: 3.0.0 以上
- **Dart**: 3.0.0 以上
- **iOS**: 12.0 以上
- **Android**: API level 21 (Android 5.0) 以上

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/your-username/chaos-vision.git
   cd chaos-vision
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **環境設定**
   ```bash
   # .env ファイルを作成（.env.example を参考）
   cp .env.example .env
   ```

4. **OpenAI API キーの設定**
   ```bash
   # .env ファイルに API キーを追加
   OPENAI_API_KEY=your_openai_api_key_here
   ```

5. **コード生成**
   ```bash
   flutter packages pub run build_runner build
   ```

6. **アプリの実行**
   ```bash
   # デバッグモード
   flutter run
   
   # リリースモード
   flutter run --release
   ```

## 🧪 テスト実行

```bash
# 全テストの実行
flutter test

# ユニットテストのみ
flutter test test/unit/

# ウィジェットテストのみ
flutter test test/widget/

# 統合テストの実行
flutter test integration_test/

# コードカバレッジ
flutter test --coverage
```

## 🏗️ アーキテクチャ

### ディレクトリ構造
```
lib/
├── core/                   # コア機能
│   ├── constants/          # 定数定義
│   ├── services/          # サービス層
│   └── theme/             # テーマ設定
├── features/              # 機能別画面
│   ├── home/              # ホーム画面
│   ├── scanner/           # スキャナー画面
│   ├── scan_result/       # スキャン結果画面
│   ├── collection/        # コレクション画面
│   └── settings/          # 設定画面
└── shared/                # 共通要素
    ├── models/            # データモデル
    └── widgets/           # 共通ウィジェット
```

### 主要技術スタック

| 分野 | 技術 |
|------|------|
| **フレームワーク** | Flutter 3.0+ |
| **状態管理** | Riverpod |
| **ローカルDB** | Hive + SQLite |
| **AI/ML** | OpenAI GPT API |
| **物体認識** | Google ML Kit |
| **アニメーション** | Lottie, Flutter Animate |
| **設定管理** | SharedPreferences |

## 🔧 開発コマンド

```bash
# 開発サーバー起動
flutter run

# ホットリロード中の開発
flutter run --hot

# Webブラウザでテスト実行
flutter run -d chrome

# 静的解析
flutter analyze

# コードフォーマット
flutter format .

# 依存関係の更新確認
flutter pub outdated

# ビルド（Android）
flutter build apk

# ビルド（iOS）
flutter build ipa

# ビルド（Web）
flutter build web
```

## 📋 開発ガイドライン

### コーディング規約
- **言語**: Dart 3.0+ の最新機能を活用
- **命名**: lowerCamelCase（変数・関数）、UpperCamelCase（クラス）
- **ファイル名**: snake_case
- **インデント**: スペース2文字

### コミット規約
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント更新
- **style**: コードスタイル修正
- **refactor**: リファクタリング
- **test**: テスト追加・修正

### ブランチ戦略
- **main**: 本番用安定版
- **develop**: 開発用最新版
- **feature/**: 機能開発ブランチ
- **hotfix/**: 緊急修正ブランチ

## 🎯 今後の開発予定

### Phase 2 機能
- [ ] **ユーザー認証**: Firebase Auth連携
- [ ] **クラウド同期**: 複数デバイス間でのコレクション同期
- [ ] **ソーシャル機能**: ユーザー間での神器シェア
- [ ] **ストーリーモード**: 収集した神器を使った冒険モード

### Phase 3 拡張
- [ ] **ARフィルター**: リアルタイムエフェクト強化
- [ ] **音声認識**: 呪文詠唱による特殊効果
- [ ] **機械学習**: ユーザー好みに基づく生成内容カスタマイズ
- [ ] **多言語対応**: 英語・中国語対応

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. Pull Request を作成

## 📄 ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。

## 🙏 謝辞

- **OpenAI**: GPT APIによるクリエイティブなコンテンツ生成
- **Google**: ML Kitによる高精度物体認識
- **Flutter Team**: 優れたクロスプラットフォーム開発環境
- **コミュニティ**: オープンソースライブラリとサポート

---

**「現実は幻想、幻想が現実となる時、真の力が目覚める」** ⚡️
