import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
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
                'プライバシーポリシー',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Text(
                'CHAOS VISION（以下「本アプリ」）は、ユーザーの皆様のプライバシーを尊重し、個人情報の保護に努めます。本プライバシーポリシーは、本アプリにおける個人情報の取り扱いについて説明します。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '1. 収集する情報',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '1.1 カメラ画像',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 目的: 物体認識およびAI生成による異名・設定の作成\n'
                '• 処理: 撮影された画像は一時的に処理され、OpenAI APIに送信されます\n'
                '• 保存: 撮影画像そのものは端末に永続保存されません',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '1.2 生成されたコンテンツ',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 内容: スキャンした物体の名称、生成された異名、説明文、属性、レア度\n'
                '• 保存場所: 端末内のローカルデータベース\n'
                '• 用途: アプリ内での神器図鑑機能',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '2. 第三者への情報提供',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '2.1 OpenAI社への情報提供',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• 提供する情報: カメラで撮影した画像データ、物体名\n'
                '• 目的: AI技術を用いた創造的な異名・設定の生成\n'
                '• 法的根拠: ユーザーの同意\n'
                '• OpenAIのプライバシーポリシー: https://openai.com/privacy/',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '2.2 その他の第三者への提供',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '本アプリは、上記を除き、ユーザーの個人情報を第三者に提供、販売、または共有することはありません。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '3. 情報の利用目的',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '• 物体の認識・分析\n'
                '• AI技術による創造的コンテンツの生成\n'
                '• アプリ機能の提供・改善\n'
                '• ユーザーサポートの提供',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '4. ユーザーの権利',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              Text(
                '4.1 データの削除',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• アプリ内の神器図鑑から個別のアイテムを削除可能\n'
                '• アプリをアンインストールすることで、すべてのローカルデータが削除されます',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              Text(
                '4.2 利用停止',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• いつでもアプリの使用を停止できます\n'
                '• カメラアクセス権限は端末の設定から変更可能です',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '5. 年齢制限',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '本アプリは4歳以上のユーザーを対象としています。13歳未満のユーザーは保護者の同意のもとでご利用ください。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '6. お問い合わせ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '本プライバシーポリシーに関するご質問やご懸念がございましたら、アプリ内のお問い合わせ機能からご連絡ください。',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                '最終更新日: 2025年8月18日',
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