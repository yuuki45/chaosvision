import 'package:flutter/material.dart';
import '../../shared/widgets/codex/codex_legal_scaffold.dart';

class PrivacyPolicyScreenV2 extends StatelessWidget {
  const PrivacyPolicyScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return CodexLegalScaffold(
      headerKanji: '誓   約',
      headerRoman: 'PRIVACY POLICY',
      pageMark: '― Ⅷ ―',
      footerLabel: 'PRIVACY',
      lede:
          'CHAOS VISION（以下「本アプリ」）は、ユーザーの皆様のプライバシーを尊重し、'
          '個人情報の保護に努めます。本プライバシーポリシーは、本アプリにおける個人情報の取り扱いについて説明します。',
      children: const [
        CodexSection(
          kanji: '一  ・  収  集',
          roman: 'DATA COLLECTED',
          children: [
            CodexSubheading('1.1  カメラ画像'),
            CodexBullets(items: [
              '目的: 物体認識および AI 生成による異名・設定の作成',
              '送信: 中継サーバー (Cloudflare Workers) を経由して OpenAI に転送',
              '送信前の処理: 最大 512px に縮小・JPEG 圧縮',
              '端末内保存: アプリ専用領域 (Documents/scanned_images/) に保存され、図鑑から参照',
              '中継サーバーでの保存: 画像は保存せず転送のみ',
            ]),
            CodexSubheading('1.2  生成されたコンテンツ'),
            CodexBullets(items: [
              '内容: スキャンした物体の名称、 生成された異名、 説明文、 属性、 レア度',
              '保存場所: 端末内のローカルデータベース (Hive)',
              '用途: アプリ内の神器図鑑、 共有用カード画像の生成',
            ]),
            CodexSubheading('1.3  取得しない情報'),
            CodexBullets(items: [
              '氏名・メールアドレス・電話番号などの個人特定情報',
              '位置情報・連絡先・写真ライブラリ全体へのアクセス',
              'デバイス識別子・広告 ID・トラッキング用 ID',
            ]),
          ],
        ),
        CodexSection(
          kanji: '二  ・  提  供',
          roman: 'THIRD-PARTY DISCLOSURE',
          children: [
            CodexSubheading('2.1  中継サーバー (Cloudflare)'),
            CodexBullets(items: [
              '事業者: Cloudflare, Inc. (Cloudflare Workers サービス)',
              '目的: OpenAI への通信中継、 API キーをアプリから分離して保護',
              '保管: 画像は保存せず転送のみ',
              'プライバシーポリシー: https://www.cloudflare.com/privacypolicy/',
            ]),
            CodexSubheading('2.2  OpenAI 社への情報提供'),
            CodexBullets(items: [
              '提供する情報: 縮小・圧縮された画像、 生成依頼テキスト',
              '目的: AI による創造的な異名・設定の生成',
              'OpenAI のプライバシーポリシー: https://openai.com/policies/privacy-policy',
            ]),
            CodexSubheading('2.3  その他の第三者への提供'),
            CodexBody(
              '本アプリは、 上記の業務委託先を除き、 ユーザーの個人情報を第三者に提供、 販売、 または共有することはありません。',
            ),
          ],
        ),
        CodexSection(
          kanji: '三  ・  目  的',
          roman: 'PURPOSE OF USE',
          children: [
            CodexBullets(items: [
              '物体の認識・分析',
              'AI 技術による創造的コンテンツの生成',
              'アプリ機能の提供・改善',
              'ユーザーサポートの提供',
            ]),
          ],
        ),
        CodexSection(
          kanji: '四  ・  権  利',
          roman: 'YOUR RIGHTS',
          children: [
            CodexSubheading('4.1  データの削除'),
            CodexBullets(items: [
              'アプリ内の神器図鑑から個別のアイテムを削除可能',
              'アプリをアンインストールすることで、 すべてのローカルデータが削除されます',
            ]),
            CodexSubheading('4.2  利用停止'),
            CodexBullets(items: [
              'いつでもアプリの使用を停止できます',
              'カメラアクセス権限は端末の設定から変更可能です',
            ]),
          ],
        ),
        CodexSection(
          kanji: '五  ・  年  齢',
          roman: 'AGE RESTRICTION',
          children: [
            CodexBody(
              '本アプリは 4 歳以上のユーザーを対象としています。'
              '13 歳未満のユーザーは保護者の同意のもとでご利用ください。',
            ),
          ],
        ),
        CodexSection(
          kanji: '六  ・  問  合',
          roman: 'CONTACT',
          children: [
            CodexBody(
              '本プライバシーポリシーに関するご質問やご懸念がございましたら、'
              'アプリ内のお問い合わせ機能からご連絡ください。',
            ),
          ],
        ),
        CodexImprint(
          revised: '2026  年  5  月  5  日',
          copyright: '©  2025 - 2026  CHAOS  VISION  ─  All  rights  reserved.',
        ),
      ],
    );
  }
}
