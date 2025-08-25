import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/rune_button.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせ'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダーアイコン
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.contact_support,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // タイトル
                const Text(
                  'お問い合わせ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // 説明文
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHAOS VISIONについて',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'アプリの使用方法、不具合報告、機能要望、その他ご質問など、何でもお気軽にお問い合わせください。'
                        '皆様からのフィードバックは、アプリの改善に役立てさせていただきます。',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // お問い合わせ方法
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: AppColors.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'メールでのお問い合わせ',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        '下記のメールアドレスまでご連絡ください：',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 16,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // メールアドレス表示
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'web-studio@ymail.ne.jp',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () => _copyToClipboard(context),
                              tooltip: 'コピー',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'お問い合わせの際は、以下の情報を含めていただけると、より迅速にサポートできます：',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const Text(
                        '• ご使用のデバイス（iPhone機種）\n'
                        '• iOSバージョン\n'
                        '• アプリバージョン\n'
                        '• 問題の詳細や再現手順\n'
                        '• スクリーンショット（該当する場合）',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 注意事項
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.onBackground.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.onBackground.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ご注意',
                            style: TextStyle(
                              color: AppColors.onBackground.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 返信には1〜3営業日いただく場合があります\n'
                        '• 営業や宣伝目的のメールにはお返事できません\n'
                        '• お問い合わせ内容によっては、お答えできない場合があります',
                        style: TextStyle(
                          color: AppColors.onBackground.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // メールアプリを開くボタン
                SizedBox(
                  width: double.infinity,
                  child: RuneButton(
                    text: 'メールアプリでお問い合わせ',
                    onPressed: () => _openMailApp(context),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    glowColor: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 戻るボタン
                SizedBox(
                  width: double.infinity,
                  child: RuneButton(
                    text: '戻る',
                    onPressed: () => Navigator.of(context).pop(),
                    gradient: const LinearGradient(
                      colors: [AppColors.surfaceVariant, AppColors.surface],
                    ),
                    glowColor: AppColors.onBackground,
                    isOutlined: true,
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'web-studio@ymail.ne.jp'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('メールアドレスをコピーしました'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openMailApp(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'web-studio@ymail.ne.jp',
      query: 'subject=CHAOS VISION お問い合わせ',
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar(context, 'メールアプリが見つかりません');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'メールアプリの起動に失敗しました');
    }
  }
  
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}