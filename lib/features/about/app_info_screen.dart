import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/rune_button.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../contact/contact_screen.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Stack(
          children: [
            // メインコンテンツ
            SafeArea(
              child: Column(
                children: [
                  // ヘッダー
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CHAOS VISION について',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // スクロール可能なコンテンツ
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // アプリタイトル
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  AppConstants.appName,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.appSubtitle,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // アプリ概要セクション
                          _buildSection(
                            context,
                            title: 'アプリ概要',
                            icon: Icons.auto_awesome,
                            content: '現実世界に存在するあらゆる物体に"異名"と"裏設定"を付与し、中二病的視点で再解釈するARスキャンアプリです。\n\n'
                                   'スマホをかざすだけで、この世界の"真の姿"を見ることができます。AI技術により、あなたの身の回りの物体が神秘的な異名と設定を持つようになります。',
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 使い方セクション
                          _buildSection(
                            context,
                            title: '使い方',
                            icon: Icons.touch_app,
                            content: '1. ホーム画面で「スキャン開始」ボタンをタップ\n\n'
                                   '2. カメラを物体に向ける\n\n'
                                   '3. 魔法陣が現れたらスキャン完了\n\n'
                                   '4. AIが生成した異名と設定を確認\n\n'
                                   '5. 神器図鑑で収集した神器を閲覧・管理',
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 特殊イベントセクション
                          _buildSection(
                            context,
                            title: '特殊イベント',
                            icon: Icons.star,
                            content: '特定の時間帯や条件で"超レア神器"が出現することがあります：\n\n'
                                   '🌙 呪われた時刻\n'
                                   '4:44、13:13、23:23 - 現実と異界の境界が最も薄くなる瞬間\n\n'
                                   '🔥 13日の金曜日\n'
                                   '不吉な力が高まる恐怖の日\n\n'
                                   '🎃 特別な日付\n'
                                   'ハロウィン、クリスマスイブ、新年、エイプリルフール\n\n'
                                   '⚡ 次元歪曲モード発生時\n'
                                   '時空の歪みにより異世界の神器が出現\n\n'
                                   'これらの時間には通常よりも強力で神秘的な神器が発見される可能性が高くなります。',
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 神器の属性セクション
                          _buildSection(
                            context,
                            title: '神器の属性',
                            icon: Icons.whatshot,
                            content: '発見される神器には様々な属性が付与されます：\n\n'
                                   '🔥 炎属性 - 燃え盛る力を宿す\n'
                                   '🌊 水属性 - 流れる癒しの力\n'
                                   '⚡ 雷属性 - 電撃の破壊力\n'
                                   '🌪️ 風属性 - 疾風の機動力\n'
                                   '🌍 地属性 - 大地の頑強さ\n'
                                   '🌙 闇属性 - 深淵の神秘力\n'
                                   '☀️ 光属性 - 聖なる浄化力\n\n'
                                   '属性によって異なる視覚効果と設定が生成されます。',
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // バージョン情報
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'バージョン情報',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Version: ${AppConstants.appVersion}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '中二スキャナー - CHAOS VISION -',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurface.withValues(alpha: 0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // 法的文書ボタン
                          SizedBox(
                            width: double.infinity,
                            child: RuneButton(
                              text: 'プライバシーポリシー',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, AppColors.secondaryDark],
                              ),
                              glowColor: AppColors.secondary,
                              isOutlined: true,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          SizedBox(
                            width: double.infinity,
                            child: RuneButton(
                              text: '利用規約',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TermsOfServiceScreen(),
                                  ),
                                );
                              },
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, AppColors.secondaryDark],
                              ),
                              glowColor: AppColors.secondary,
                              isOutlined: true,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          SizedBox(
                            width: double.infinity,
                            child: RuneButton(
                              text: 'お問い合わせ',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ContactScreen(),
                                  ),
                                );
                              },
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, AppColors.secondaryDark],
                              ),
                              glowColor: AppColors.secondary,
                              isOutlined: true,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 戻るボタン
                          SizedBox(
                            width: double.infinity,
                            child: RuneButton(
                              text: 'ホームに戻る',
                              onPressed: () => Navigator.of(context).pop(),
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              glowColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.2),
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
                icon,
                color: AppColors.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}