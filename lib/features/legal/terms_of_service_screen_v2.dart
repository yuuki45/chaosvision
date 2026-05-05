import 'package:flutter/material.dart';
import '../../shared/widgets/codex/codex_legal_scaffold.dart';

class TermsOfServiceScreenV2 extends StatelessWidget {
  const TermsOfServiceScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return CodexLegalScaffold(
      headerKanji: '律   令',
      headerRoman: 'TERMS OF SERVICE',
      pageMark: '― Ⅸ ―',
      footerLabel: 'TERMS',
      lede:
          '本利用規約（以下「本規約」）は、CHAOS VISION（以下「本アプリ」）の利用条件を定めるものです。'
          '本アプリをご利用になる場合には、本規約の全ての内容をご承諾いただいたものとみなします。',
      children: const [
        CodexSection(
          kanji: '一  ・  概  要',
          roman: 'OVERVIEW',
          children: [
            CodexSubheading('1.1  サービス内容'),
            CodexBody(
              '本アプリは、 スマートフォンのカメラで現実世界の物体をスキャンし、'
              ' AI 技術を用いて創造的な異名・設定を生成するエンターテイメントアプリです。',
            ),
            CodexSubheading('1.2  提供環境'),
            CodexBullets(items: [
              'iOS 13.0 以上',
              'インターネット接続環境',
              'カメラへのアクセス権限',
            ]),
          ],
        ),
        CodexSection(
          kanji: '二  ・  条  件',
          roman: 'ELIGIBILITY',
          children: [
            CodexSubheading('2.1  年齢制限'),
            CodexBody(
              '本アプリは 4 歳以上のユーザーを対象としています。'
              '13 歳未満のユーザーは保護者の同意が必要です。',
            ),
          ],
        ),
        CodexSection(
          kanji: '三  ・  禁  止',
          roman: 'PROHIBITED CONDUCT',
          children: [
            CodexBody(
              'ユーザーは本アプリの利用において、以下の行為を行ってはいけません。',
            ),
            CodexSubheading('3.1  コンテンツに関する禁止事項'),
            CodexBullets(items: [
              '違法、 有害、 脅迫的、 虐待的、 中傷的な内容の物体をスキャンすること',
              '他者の知的財産権を侵害する物体をスキャンすること',
              'プライバシーを侵害する可能性のある物体をスキャンすること',
            ]),
            CodexSubheading('3.2  技術的禁止事項'),
            CodexBullets(items: [
              '本アプリおよび中継サーバーの動作を妨害する行為',
              '不正なアクセス、 リバースエンジニアリング',
              '自動化ツールによる過剰なリクエスト',
              '本アプリの脆弱性を悪用する行為',
              'アプリから抽出した認証情報を別用途で利用する行為',
            ]),
          ],
        ),
        CodexSection(
          kanji: '四  ・  権  利',
          roman: 'INTELLECTUAL PROPERTY',
          children: [
            CodexSubheading('4.1  アプリの知的財産権'),
            CodexBody('本アプリに関する知的財産権は、開発者に帰属します。'),
            CodexSubheading('4.2  生成コンテンツ'),
            CodexBody(
              '本アプリで生成された異名・説明文等のコンテンツは、ユーザーが自由に利用できます。'
              'ただし、生成に使用した AI 技術は第三者の知的財産権の対象である場合があります。',
            ),
          ],
        ),
        CodexSection(
          kanji: '五  ・  免  責',
          roman: 'DISCLAIMER',
          children: [
            CodexSubheading('5.1  サービスの提供'),
            CodexBullets(items: [
              '本アプリの継続的な提供を保証するものではありません',
              '中継サーバー (Cloudflare) または OpenAI の障害・規約変更により、 AI 解析機能が利用不可となる場合があります',
              '技術的な問題やメンテナンスにより、 一時的にサービスが利用できない場合があります',
            ]),
            CodexSubheading('5.2  生成コンテンツ'),
            CodexBullets(items: [
              'AI 技術により生成されるコンテンツの正確性・適切性・無害性を保証しません',
              '生成されたコンテンツによる損害について一切の責任を負いません',
            ]),
          ],
        ),
        CodexSection(
          kanji: '六  ・  準  拠',
          roman: 'GOVERNING LAW',
          children: [
            CodexBody(
              '本規約は日本法に準拠します。'
              '本アプリに関する紛争については、開発者の所在地を管轄する裁判所を専属的合意管轄裁判所とします。',
            ),
          ],
        ),
        CodexSection(
          kanji: '七  ・  問  合',
          roman: 'CONTACT',
          children: [
            CodexBody(
              '本利用規約に関するご質問がございましたら、'
              'アプリ内のお問い合わせ機能からご連絡ください。',
            ),
          ],
        ),
        CodexImprint(
          established: '2025  年  8  月  18  日',
          revised: '2026  年  5  月  5  日',
          copyright: '©  2025 - 2026  CHAOS  VISION  ─  All  rights  reserved.',
        ),
      ],
    );
  }
}
