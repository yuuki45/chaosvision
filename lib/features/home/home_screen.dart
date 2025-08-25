import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/special_event_service.dart';
import '../../shared/widgets/rune_button.dart';
import '../../shared/widgets/magic_circle_widget.dart';
import '../../shared/widgets/special_event_banner.dart';

import '../scanner/scanner_screen.dart';
import '../collection/collection_screen.dart';
import '../debug/event_test_screen.dart';
import '../about/app_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpecialEventService _eventService = SpecialEventService.instance;
  Timer? _eventTimer;
  
  @override
  void initState() {
    super.initState();
    // イベント状態を更新
    _eventService.updateEventStatus();
    
    // 1分ごとにイベント状態と残り時間を更新
    _eventTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _eventService.updateEventStatus();
        });
      }
    });
  }
  
  @override
  void dispose() {
    _eventTimer?.cancel();
    super.dispose();
  }
  
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
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 
                              MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // 特殊イベントバナー（リアルタイム更新）
                        SpecialEventBanner(
                          event: _eventService.currentEvent,
                          remainingMinutes: _eventService.getEventRemainingMinutes(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // アプリタイトル
                        Column(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: GoogleFonts.cinzel(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: AppColors.primary,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              AppConstants.appSubtitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // サブタイトル
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            '現実世界の真の姿を見よ',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.onBackground.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const Spacer(),
                        
                        // 魔法陣
                        const MagicCircleWidget(size: 200),
                        
                        const SizedBox(height: 60),
                        
                        // ボタン群
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              // スキャン開始ボタン
                              RuneButton(
                                text: 'スキャン開始',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ScannerScreen(),
                                    ),
                                  );
                                },
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                ),
                                width: double.infinity,
                                glowColor: AppColors.primary,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // 神器図鑑ボタン
                              RuneButton(
                                text: '神器図鑑',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const CollectionScreen(),
                                    ),
                                  );
                                },
                                gradient: const LinearGradient(
                                  colors: [AppColors.secondary, AppColors.secondaryDark],
                                ),
                                width: double.infinity,
                                glowColor: AppColors.secondary,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // アプリ情報ボタン
                              RuneButton(
                                text: 'アプリについて',
                                isOutlined: true,
                                gradient: const LinearGradient(
                                  colors: [AppColors.surfaceVariant, AppColors.surface],
                                ),
                                glowColor: AppColors.onBackground,
                                width: double.infinity,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const AppInfoScreen(),
                                    ),
                                  );
                                },
                              ),
                              

                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
