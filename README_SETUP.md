# CHAOS VISION セットアップガイド

## APIキーの設定

実機テストでGPT連携を使用するには、OpenAI APIキーの設定が必要です：

### 方法1: dart-defineを使用（推奨）

```bash
# デバッグ実行
flutter run --dart-define=OPENAI_API_KEY=your_api_key_here

# リリースビルド（iOS）
flutter build ios --release --dart-define=OPENAI_API_KEY=your_api_key_here
```

### 方法2: .envファイル使用

1. `.env.example`をコピーして`.env`ファイルを作成
2. 実際のAPIキーを設定
3. ビルド時に環境変数が読み込まれます

## 注意事項

- APIキーは絶対にGitにコミットしないでください
- `.env`ファイルは`.gitignore`に含まれています
- 実機テストでは`--dart-define`方式が確実に動作します