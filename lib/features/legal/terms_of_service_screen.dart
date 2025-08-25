import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.background,
              Color(0xFF000000),
            ],
          ),
        ),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '利用規約',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                '本利用規約（以下「本規約」）は、CHAOS VISION（以下「本アプリ」）の利用条件を定めるものです。本アプリをご利用になる場合には、本規約の全ての内容をご承諾いただいたものとみなします。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '1. 本アプリについて',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '1.1 サービス内容',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本アプリは、スマートフォンのカメラで現実世界の物体をスキャンし、AI技術を用いて創造的な異名・設定を生成するエンターテイメントアプリです。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '1.2 提供環境',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• iOS 12.0以上\n'
                '• インターネット接続環境\n'
                '• カメラ機能',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '2. 利用条件',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '2.1 年齢制限',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本アプリは4歳以上のユーザーを対象としています。13歳未満のユーザーは保護者の同意が必要です。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '3. 禁止事項',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'ユーザーは本アプリの利用において、以下の行為を行ってはいけません：',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '3.1 コンテンツに関する禁止事項',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 違法、有害、脅迫的、虐待的、中傷的な内容の物体をスキャンすること\n'
                '• 他者の知的財産権を侵害する物体をスキャンすること\n'
                '• プライバシーを侵害する可能性のある物体をスキャンすること',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '3.2 技術的禁止事項',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 本アプリの動作を妨害する行為\n'
                '• 不正なアクセスやハッキング行為\n'
                '• 本アプリの脆弱性を悪用する行為',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '4. 知的財産権',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '4.1 アプリの知的財産権',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本アプリに関する知的財産権は、開発者に帰属します。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '4.2 生成コンテンツ',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本アプリで生成された異名・説明文等のコンテンツは、ユーザーが自由に利用できます。ただし、生成に使用したAI技術は第三者の知的財産権の対象である場合があります。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '5. 免責事項',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '5.1 サービスの提供',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 本アプリの継続的な提供を保証するものではありません\n'
                '• 技術的な問題やメンテナンスにより、一時的にサービスが利用できない場合があります',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '5.2 生成コンテンツ',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• AI技術により生成されるコンテンツの正確性を保証するものではありません\n'
                '• 生成されたコンテンツによる損害について責任を負いません',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '6. 準拠法・管轄裁判所',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '本規約は日本法に準拠します。本アプリに関する紛争については、開発者の所在地を管轄する裁判所を専属的合意管轄裁判所とします。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '7. お問い合わせ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '本利用規約に関するご質問がございましたら、アプリ内のお問い合わせ機能からご連絡ください。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '制定日: 2025年8月18日\n最終更新日: 2025年8月18日',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '© 2025 CHAOS VISION. All rights reserved.',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}