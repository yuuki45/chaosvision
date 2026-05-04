# CHAOS VISION Proxy (Cloudflare Worker)

iOS アプリと OpenAI の間に立つ薄い proxy。
OpenAI API キーをアプリバイナリから切り離すのが目的。

## アーキテクチャ

```
[iPhone (Flutter)]
    ↓ POST /scan  Bearer <APP_SECRET>  body: { imageBase64 }
[Cloudflare Worker]   ← OPENAI_API_KEY / APP_SECRET (env)
    ↓ 認証 → server-side で system prompt / model 固定
[OpenAI gpt-4o-mini]
    ↓ JSON 応答
[Worker] → 透過的に iPhone に返す
```

- `model` `system prompt` `max_tokens` `detail` はすべて Worker 内で固定。
  APP_SECRET が漏れても、攻撃者は CHAOS VISION 用の chuuni 解読しかできない。
- Cloudflare Workers Free Tier (100,000 req/day) で運用想定。
  個人エンタメアプリの規模なら無料枠内に余裕で収まる。

## デプロイ手順

### 0. 前提
- Cloudflare アカウント (無料、3分で作成可能 → https://dash.cloudflare.com/sign-up)
- Node.js 18+ がローカルにあること

### 1. 依存インストール
```sh
cd worker
npm install
```

### 2. Cloudflare ログイン
```sh
npx wrangler login
```
ブラウザが開く → 認可。

### 3. Secrets を登録

**OpenAI キー** (新しいキーを発行してから):
```sh
npx wrangler secret put OPENAI_API_KEY
# プロンプトで sk-proj-... を貼る
```

**アプリ共有トークン** (32文字程度のランダム文字列を生成して使う):
```sh
# 例: macOS で生成
openssl rand -hex 32
# → 出力された文字列をコピー

npx wrangler secret put APP_SECRET
# プロンプトで上記文字列を貼る
```

### 4. デプロイ
```sh
npx wrangler deploy
```
出力に Worker の URL が表示される。例:
```
Published chaos-vision-proxy
  https://chaos-vision-proxy.<YOUR-SUBDOMAIN>.workers.dev
```
この URL を iOS アプリ側に渡す（後述の `Local.xcconfig`）。

### 5. 動作確認
```sh
# ヘルスチェック
curl https://chaos-vision-proxy.<YOUR-SUBDOMAIN>.workers.dev/
# → {"ok":true,"name":"chaos-vision-proxy"}

# scan エンドポイント (認証エラー期待)
curl -X POST https://chaos-vision-proxy.<YOUR-SUBDOMAIN>.workers.dev/scan
# → {"error":"Unauthorized"}

# scan エンドポイント (画像なし)
curl -X POST https://chaos-vision-proxy.<YOUR-SUBDOMAIN>.workers.dev/scan \
  -H "Authorization: Bearer <APP_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{}'
# → {"error":"imageBase64 is required"}
```

### 6. ログ監視
```sh
npx wrangler tail
```
リアルタイムでリクエストログを見られる。

## エンドポイント

### `GET /`
ヘルスチェック。`{ "ok": true, "name": "..." }`

### `POST /scan`
中二病異名生成。

**Request:**
```http
POST /scan
Authorization: Bearer <APP_SECRET>
Content-Type: application/json

{
  "imageBase64": "<JPEG を base64 エンコードしたもの>"
}
```

**Response (成功):** OpenAI Chat Completion API のレスポンスを透過的に返す
```json
{
  "id": "chatcmpl-...",
  "choices": [{
    "message": {
      "content": "物体カテゴリ: 冷蔵庫\n異名: 氷封の魔牢《...》\n属性: 氷\n説明: ...\nレア度: レア"
    }
  }],
  "usage": { ... }
}
```

**Response (エラー):**
| Status | 意味 |
|---|---|
| 400 | `imageBase64` が無い／無効 |
| 401 | `Authorization` が不正 |
| 405 | POST 以外のメソッド |
| 413 | 画像が大きすぎる (> ~1.5MB) |
| 502 | OpenAI への接続失敗 |
| 5xx | OpenAI からのエラーをそのまま透過 |

## ローカル開発

```sh
npx wrangler dev
```
ローカル `http://localhost:8787` で動く。secrets はローカル `.dev.vars` ファイルに記述:
```
OPENAI_API_KEY=sk-proj-...
APP_SECRET=...
```
※ `.dev.vars` は `.gitignore` 済み。

## メンテナンス

- **新キー発行時:** `npm run secret:openai` でセット → `npm run deploy`
- **アプリ側トークン更新:** `npm run secret:app` で新トークン → アプリの `Local.xcconfig` も同期 → 再デプロイ
- **プロンプト変更:** `src/index.ts` の `SYSTEM_PROMPT` を編集 → `npm run deploy`
  - アプリ更新不要。ストアレビュー待たずにプロンプト改善できる
- **モデル切替:** `src/index.ts` の `model: 'gpt-4o-mini'` を変更 → デプロイ
