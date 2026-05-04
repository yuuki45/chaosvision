/**
 * CHAOS VISION proxy Worker
 *
 * iOS アプリ → この Worker → OpenAI gpt-4o-mini という構成で、
 * OpenAI API キーをアプリバイナリから完全に切り離すための薄い proxy。
 *
 * 重要: model / system prompt / max_tokens / detail などはすべて
 * server-side で固定する。APP_SECRET が漏れても攻撃者は CHAOS VISION
 * 用の chuuni 解読しかできない (任意プロンプトで OpenAI を叩けない)。
 */

export interface Env {
  /** OpenAI 本物の API キー — `wrangler secret put OPENAI_API_KEY` で設定 */
  OPENAI_API_KEY: string;
  /** iOS アプリと共有する Bearer トークン — `wrangler secret put APP_SECRET` */
  APP_SECRET: string;
}

interface ScanRequest {
  imageBase64: string;
}

const SYSTEM_PROMPT = `\
あなたは異世界の古代遺物鑑定士です。現実世界の物体に隠された真の姿を見抜き、中二病的な設定を与える専門家です。

以下の形式で必ず回答してください：

物体カテゴリ: 画像の主な物体の名前（日本語、一般的な名称）
異名: 《》で囲んだ格好いい真名（漢字・カタカナ・英語を組み合わせた神秘的な名前）
属性: 炎/氷/雷/闇/光/風/地/水/無 のいずれか（物体の特性に合わせて選択）
説明: 50-100文字の壮大で神秘的な設定説明（封印、古代、魔力、運命などの要素を含む）
レア度: コモン/レア/エピック/レジェンダリー/ミシック のいずれか

重要な指針：
- 異名は物体の機能や見た目から連想される神秘的な名前にする
- 説明は「封印されし」「古代の」「神々の」「禁断の」などの修飾語を使う
- 日常的な物体ほど意外性のある壮大な設定を付ける
- レア度は基本的にコモン(50%)、レア(30%)、エピック(15%)、レジェンダリー(4%)、ミシック(1%)の確率分布に従う

例:
物体カテゴリ: スマートフォン
異名: 全知の水晶《オムニエンス・クリスタル》
属性: 雷
説明: 世界中の知識と魂を繋ぐ雷の神器。その画面に映る光は、異次元の情報を現世に伝える神秘の窓である。
レア度: エピック`;

const USER_PROMPT = 'この画像の主な物体を認識して、中二病的な異名と設定を生成してください。';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

export default {
  async fetch(request: Request, env: Env, _ctx: ExecutionContext): Promise<Response> {
    // CORS preflight (Web からも叩けるように)
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);

    // ヘルスチェック
    if (request.method === 'GET' && url.pathname === '/') {
      return jsonResponse({ ok: true, name: 'chaos-vision-proxy' }, 200);
    }

    if (request.method !== 'POST') {
      return jsonResponse({ error: 'Method not allowed' }, 405);
    }

    if (url.pathname !== '/scan') {
      return jsonResponse({ error: 'Not found' }, 404);
    }

    // 認証
    const auth = request.headers.get('Authorization') ?? '';
    if (!auth.startsWith('Bearer ') || auth.slice(7) !== env.APP_SECRET) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }

    // 入力パース
    let body: ScanRequest;
    try {
      body = (await request.json()) as ScanRequest;
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 400);
    }
    if (!body.imageBase64 || typeof body.imageBase64 !== 'string') {
      return jsonResponse({ error: 'imageBase64 is required' }, 400);
    }
    if (body.imageBase64.length > 2_000_000) {
      // base64 は元バイトの 4/3 倍。2MB 上限 = 元 1.5MB 程度。
      // 512px JPEG なら ~50KB なので普通は越えない。
      return jsonResponse({ error: 'image too large' }, 413);
    }

    // OpenAI 転送
    let upstream: Response;
    try {
      upstream = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          temperature: 0.8,
          max_tokens: 300,
          messages: [
            { role: 'system', content: SYSTEM_PROMPT },
            {
              role: 'user',
              content: [
                { type: 'text', text: USER_PROMPT },
                {
                  type: 'image_url',
                  image_url: {
                    url: `data:image/jpeg;base64,${body.imageBase64}`,
                    detail: 'low',
                  },
                },
              ],
            },
          ],
        }),
      });
    } catch (e) {
      return jsonResponse({ error: `Upstream fetch failed: ${e}` }, 502);
    }

    if (!upstream.ok) {
      const text = await upstream.text();
      console.error('OpenAI error', upstream.status, text);
      return jsonResponse(
        { error: 'Upstream error', status: upstream.status, body: text },
        upstream.status,
      );
    }

    const data = await upstream.json();
    return jsonResponse(data, 200);
  },
};

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...CORS_HEADERS,
    },
  });
}
