# リリースノート

## v1.0.3 (build 2)

### ユーザー向け（App Store "What's New" 用）

#### 日本語版

```
全画面のビジュアルを大幅に刷新しました。
"禁忌教典 / Forbidden Codex" をテーマに、
古代の魔導書を開くような体験へと作り変えています。

主な変更:
- ホーム / スキャナー / 図鑑 / 結果画面のフルリデザイン
- スキャン時のドラマチックな魔法陣展開と封印解除演出
- 共有機能を強化、神器カード画像を生成して SNS に投稿可能
- 神器図鑑にレア度別の収蔵概況パネルと並び替えを追加
- AI 解読の安定性とセキュリティを強化（バックエンド経由化）
- 様々な細かい不具合を修正
```

#### 英語版（参考）

```
Major visual overhaul. The whole app has been redesigned around
the "Forbidden Codex" theme — opening it feels like cracking open
an ancient grimoire.

What's new:
- Full redesign of Home / Scanner / Grimoire / Result screens
- Dramatic three-ring magic circle ritual on scan capture
- Share generates a 1080x1080 codex card with photo + chuuni name
- Grimoire Index gets rarity-distribution panel and sort cycling
- AI decoding now runs through a secure backend
- Many small fixes
```

---

### 開発者向け内部メモ

**この版で何が変わったか:**

1. **デザイン全面刷新 (Forbidden Codex v2)**
   - 9 画面すべてを刷新（home / scanner / scan_result / collection /
     object_detail / about / contact / privacy / terms）
   - 新しい配色 (ink black + blood + tarnished gold + bone)、
     Bodoni Moda + Shippori Mincho + JetBrains Mono のタイポグラフィ
   - 詳細は `docs/design-system.md`

2. **AI 通信の Cloudflare Worker proxy 化** (D-011)
   - OpenAI API キーをアプリバイナリから完全に切り離し
   - Cloudflare Workers Free Tier (`worker/`) でホスト
   - model / prompt / max_tokens を server-side で固定
   - 詳細は `docs/services.md` および `worker/README.md`

3. **画像 detail を low に切替**
   - vision tokens が ~10x 削減 (~¥0.7 → ~¥0.1 / scan)

4. **スキャナーの劇的演出強化**
   - 3 層魔法陣 (`_ScanRitual`)、フラッシュ (`_ScanFlash`)
   - HapticFeedback.heavyImpact / mediumImpact
   - 結果画面への CircularRevealClipper 遷移

5. **写真エフェクト追加**
   - 属性別カラーグレード (BlendMode.color)
   - 霊視オーバーレイ (半透明 magic circle)

6. **共有を画像付きに刷新**
   - `ShareCard` (1:1 1080x1080) を off-screen 描画 → PNG → `Share.shareXFiles`

7. **神器図鑑の操作性強化**
   - レア度クイックチップ + 並び替え cycle (新/古/級/属)
   - 検索バー削除、収蔵概況パネル追加

8. **コーデックス化されたローディング演出**
   - スキャナー処理: 4 段階の cycling caption
   - 図鑑読込・ページネーション・共有生成: `CodexLoader` 統一

9. **テスト整理**
   - 旧テスト全削除、`StorageService` に焦点を絞った 11 テスト

10. **iOS deployment target を 13 に bump**
    - Flutter 3.38 SDK の要件
    - iOS 12 デバイスは非対応に

**既知の制限 / 未対応事項:**
- Apple Receipt 検証は未実装 (v1.0.4 以降の予定)
- Worker 側のレート制限 (KV per-IP) も未実装
- SE (効果音) は未実装
- v1.0.2 からの Hive データ互換性: typeId 0 を維持しているため互換あり (確認済)

**運用に必要な事前条件:**
- Cloudflare Worker が `https://chaos-vision-proxy.clow-ff14.workers.dev` でデプロイ済
- Worker secret に `OPENAI_API_KEY` `APP_SECRET` を登録済
- `secrets.json` (gitignored) に `CHAOS_WORKER_URL` `CHAOS_APP_SECRET` を設定済
- OpenAI 月次予算 $10 + 80%/100% アラートを設定済
