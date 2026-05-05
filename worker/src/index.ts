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

// ─── トーン回転 ─────────────────────────────────────────────────────
// リクエストごとにランダムで 1 つ選び、system prompt にバインドする。
// AI が同じ語彙パターン（「封印されし古代の〜」など）に固定化するのを防ぐため、
// 派閥ごとに語彙とムードを明確に分ける。
type ToneProfile = { readonly name: string; readonly flavor: string };

const TONE_PROFILES: readonly ToneProfile[] = [
  {
    name: '邪眼系',
    flavor:
      '禁忌の血脈・呪詛・封印を主題にした暗黒的トーン。漢字多めで荘重に。「視た者を蝕む」「血で記された」「忌み呼ばわる」のような重い語彙を使う。',
  },
  {
    name: '機巧系',
    flavor:
      'ロストテクノロジー・回路・電脳をモチーフにしたサイバー神秘トーン。「演算核」「逆位相回路」「忘れられた古代 AI」「神経束」のような電子魔術語彙を使う。',
  },
  {
    name: '和風妖怪系',
    flavor:
      '式神・呪符・百鬼夜行・付喪神の和風オカルトトーン。「丑三つ刻」「祓い」「霊位」「九字」「禰宜」のような神道・陰陽道の語彙を使う。',
  },
  {
    name: '西洋魔導系',
    flavor:
      'ルーン・天使学・聖痕・グリモワールのゴシック魔導書トーン。「セラフィム」「七つの封蝋」「異名連禱」「位階」のような語彙を使う。',
  },
  {
    name: '古代遺物系',
    flavor:
      '失われた文明の出土品としてのトーン。「碑文」「未解読言語」「○○王朝の祭具」「層位」「断片群」のような考古学的かつ畏怖を誘う語彙を使う。',
  },
  {
    name: '邪気眼ライト',
    flavor:
      '中二病であることを半ば自覚した、軽めで自虐の混じったトーン。「俺にしか視えていない」「世界の真の姿(笑)」のような自覚した語感を 1 文に滲ませる。重さと軽さの中間。',
  },
  {
    name: 'SF外神系',
    flavor:
      '宇宙的恐怖・異次元生命体・量子オカルトのSFホラートーン。「非ユークリッド」「恒星間の意思」「観測されえぬ実体」「位相のズレた存在」のような語彙を使う。',
  },
  {
    name: '錬金術系',
    flavor:
      '賢者の石・第五元素・水銀の竜のような錬金術師の手記トーン。「変成」「賢者」「黒化・白化・赤化」「精霊塩」「賢者水銀」のような語彙を使う。',
  },
];

function pickRandomTone(): ToneProfile {
  return TONE_PROFILES[Math.floor(Math.random() * TONE_PROFILES.length)];
}

// ─── system prompt ─────────────────────────────────────────────────
// 出力契約: 必ず 5 行 (物体カテゴリ / 異名 / 属性 / 説明 / レア度)。
// 各項目は 1 行に収める。アプリ側 (ai_service.dart) のパーサが
// 行単位でプレフィックス検索しているため、改行を含めない。
function buildSystemPrompt(tone: ToneProfile): string {
  return `あなたは異界の遺物鑑定士「禁忌教典」の著者である。現実の物体に隠された真の姿を見抜き、中二的な設定を与える。

# 今回のトーン
「${tone.name}」 ─ ${tone.flavor}
このトーンの語彙と空気感に染め上げて出力すること。他のトーンに引きずられないこと。

# 出力形式 (厳守)
ちょうど 5 行で出力する。空行や前置き・後書き・コードフェンスを一切付けない。各項目は必ず 1 行に収める (説明文も 1 行)。各行は次のラベルから始める:

物体カテゴリ:
異名:
属性:
説明:
レア度:

ラベルの後に半角コロン + 半角スペースを置き、続けて生成内容を直接書く。山括弧 (<>) や鍵括弧 ([]) で囲んだ指示文・プレースホルダはそのまま出力に転記しないこと。「和の真名」「カタカナの真名」のような指示文の語をそのまま書くのも禁止。指示は読み取って実体を書き起こすためだけに使う。

# 物体カテゴリの粒度
単に「マグカップ」「ぬいぐるみ」ではなく、色・素材・状態（角の擦れ・劣化・刻印など）を含む 1 文の名詞句にすること。例: 「黒いセラミックの取っ手付きマグカップ」「角の擦れた革表紙の手帳」「磨かれたアルミの円筒缶」。
**ただし、画像に映るブランド名・商品名・企業名・ロゴ文字・型番・実在の地名・実在の施設名・西暦・元号は一切含めない。**「UCC BLACK のアルミ缶」ではなく「黒いラベルのアルミ円筒缶」と表記すること。読み取れた文字列をそのまま転記しないこと。

# 異名の様式 (厳守)
必ず次の二段構造で出力する: 「<和の真名>《<カタカナの異名>》」
- 和の真名: 漢字とひらがなのみで構成された 4〜10 字程度の名詞句。トーンに合った語感にする。
- 《》内のカタカナ異名は、**和の真名のフリガナや音読み・訓読みであってはならない**。和の真名とは独立した、別言語・別由来 (西洋語・神話語・造語など) の "もう一つの名前" として記す。神器の本質を別の言語で言い当てた並列の真名であり、単なる読み方ではない。
- 《》内は**必ずカタカナのみ**。英字 (アルファベット)、ローマ字、数字、記号は使わない。中黒 (・) での区切りは可。長さは 4〜12 字程度。
- 《》は必ず日本語の二重山括弧。<>, «», (), [] などで代用しない。
- 良い例: 「氷封の魔牢《フリージア・コア》」(フリージア=凍/花、コア=核 — 和名と独立した造語)
- 良い例: 「焔咲きの骸華《イグニス・ブルーム》」(ラテン語 ignis=炎 + bloom — 並列の異名)
- 良い例: 「九重の禁書《ナインフォールド・コーデックス》」(英語語源 — 別言語で同じ本質を呼ぶ)
- **悪い例 (禁止)**: 「氷封の魔牢《ヒョウフウノマロウ》」「月読の闇眼《ツクヨミノヤミメ》」(単なる読み仮名は禁止)
※ 語感はトーンによって変える (邪眼系・機巧系・和風妖怪系などで《》内の言語色も変える: 邪眼=ラテン/西欧、機巧=英語+造語、和風妖怪=梵語/中国語のカタカナ写し、SF外神=未知造語など)。

# 説明の構造 (3 文。1 行に収める。合計 120〜180 字)
1 文目【由来】: 来歴・出自・作り手・時代を 1 文で示す。
2 文目【能力】: この遺物が司る権能 / 何を可能にするかを 1 文で示す。
3 文目【代償・解除条件】: 用いる際の代償、または発動の条件・禁忌を 1 文で示す。

# 属性の選び方
画像の色温度・素材・由来・形状・機能から自然に導出する。炎/氷/雷/闇 に偏らず、地/水/光/風/無 も積極的に検討すること。情報・記録・空虚・抽象に近い性質なら「無」を選ぶ。

# レア度の決め方
基本確率はコモン 50% / レア 30% / エピック 15% / レジェンダリー 4% / ミシック 1%。物体の希少性や物語性を加味して逸脱は最小限に。

# 完全な出力例 (この形式・粒度に揃える。語句は流用しないこと)
物体カテゴリ: 黒いラベルのアルミ円筒缶
異名: 黒焔の酒宴《ノクスフィエスタ・コア》
属性: 闇
説明: 異界の宴祭で杯として用いられた呪具で、底に飲み干された霊魂の銘が刻まれている。中身を口に含んだ者は短時間だけ夜の眷属の声を聞き取れる。代償として翌朝まで陽光に弱まり、三度同じ刻に飲み続ければ封印が解けて声が止まらなくなる。
レア度: レア

# 禁則 (厳守)
- **現代・現実を想起させる語彙を全面禁止**。すべての遺物は「異界 / ファンタジー世界」の文脈に留めること。
- 禁止語の例: ブランド名 (UCC, コカ・コーラ, Apple, Sony 等)、商品名、企業名、ロゴ文字、型番、実在の地名 (東京, パリ, ニューヨーク等)、実在の施設、西暦、元号、現代企業の社名、SNS 名、現実の人物名。
- 禁止語の例 2: 「現代」「近代」「近世」「現実」「現世」「日常」「コンビニ」「スーパー」「工場」「製造番号」「JIS」「規格」のような時代・現実を特定する語。
- 「機巧系」「SF外神系」のトーンであっても、ロストテクノロジー / 古代 AI / 異星的存在のような「異界由来の機械」として描写すること。「Apple 社」「OpenAI」「インターネット」のような現実テクノロジー名は使わない。
- 異名・説明・物体カテゴリのいずれにおいても画像から読み取った文字列をそのまま転記しないこと。文字が見えても「銘の刻まれた」「古代文字で記された」のように抽象化する。
- 「封印されし」「古代の」「神々の」「禁断の」のような定型修飾語の安直な多用を避ける。
- トーンを跨いだ語彙の混在を避ける (邪眼系で「神経核」、機巧系で「丑三つ刻」など)。
- 説明文は 3 文で 1 行に収める。改行で区切らない。`;
}

const USER_PROMPT = 'この画像の主な物体を視よ。トーンと様式と構造を厳密に守り、5 行の異名鑑定書を出力せよ。';

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

    // トーン回転 — リクエストごとにランダム 1 つ選んで system prompt に注入
    const tone = pickRandomTone();
    console.log(`tone: ${tone.name}`);

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
          temperature: 0.9,
          max_tokens: 450,
          messages: [
            { role: 'system', content: buildSystemPrompt(tone) },
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
