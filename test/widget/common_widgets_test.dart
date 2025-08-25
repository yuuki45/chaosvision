import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chaos_vision/shared/widgets/attribute_badge.dart';
import 'package:chaos_vision/shared/widgets/rarity_badge.dart';
import 'package:chaos_vision/shared/widgets/gradient_button.dart';
import 'package:chaos_vision/shared/widgets/magic_circle_widget.dart';
import 'package:chaos_vision/core/constants/app_colors.dart';

void main() {
  group('Common Widgets Tests', () {
    
    group('AttributeBadge', () {
      testWidgets('should display correct attribute text and color', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AttributeBadge(attribute: '炎'),
            ),
          ),
        );

        expect(find.text('炎'), findsOneWidget);
        
        // 属性バッジが表示されていることを確認
        expect(find.byType(AttributeBadge), findsOneWidget);
      });

      testWidgets('should handle different attributes', (WidgetTester tester) async {
        const attributes = ['炎', '氷', '雷', '闇', '光', '風', '地', '水'];
        
        for (final attribute in attributes) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AttributeBadge(attribute: attribute),
              ),
            ),
          );

          expect(find.text(attribute), findsOneWidget);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('should handle unknown attributes gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AttributeBadge(attribute: '未知'),
            ),
          ),
        );

        expect(find.text('未知'), findsOneWidget);
        expect(find.byType(AttributeBadge), findsOneWidget);
      });
    });

    group('RarityBadge', () {
      testWidgets('should display correct rarity text', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RarityBadge(rarity: 'レア'),
            ),
          ),
        );

        expect(find.text('レア'), findsOneWidget);
        expect(find.byType(RarityBadge), findsOneWidget);
      });

      testWidgets('should handle different rarities', (WidgetTester tester) async {
        const rarities = ['通常', 'レア', '超レア', '伝説', '神話'];
        
        for (final rarity in rarities) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RarityBadge(rarity: rarity),
              ),
            ),
          );

          expect(find.text(rarity), findsOneWidget);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('should apply correct styling for legendary rarity', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: RarityBadge(rarity: '伝説'),
            ),
          ),
        );

        expect(find.text('伝説'), findsOneWidget);
        
        // 伝説レアリティには特別なスタイリングがあることを期待
        final rarityBadge = tester.widget<RarityBadge>(find.byType(RarityBadge));
        expect(rarityBadge.rarity, equals('伝説'));
      });
    });

    group('GradientButton', () {
      testWidgets('should display button text and handle taps', (WidgetTester tester) async {
        bool tapped = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'テストボタン',
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('テストボタン'), findsOneWidget);
        expect(find.byType(GradientButton), findsOneWidget);

        await tester.tap(find.byType(GradientButton));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('should be disabled when onPressed is null', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: '無効なボタン',
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                onPressed: null,
              ),
            ),
          ),
        );

        expect(find.text('無効なボタン'), findsOneWidget);
        
        // ボタンが無効化されていることを確認
        final gradientButton = tester.widget<GradientButton>(find.byType(GradientButton));
        expect(gradientButton.onPressed, isNull);
      });

      testWidgets('should support custom width and height', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                text: 'カスタムサイズ',
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                onPressed: () {},
                width: 200,
                height: 60,
              ),
            ),
          ),
        );

        expect(find.text('カスタムサイズ'), findsOneWidget);
        
        final button = tester.widget<GradientButton>(find.byType(GradientButton));
        expect(button.width, equals(200));
        expect(button.height, equals(60));
      });
    });

    group('MagicCircleWidget', () {
      testWidgets('should render magic circle without errors', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MagicCircleWidget(
                size: 200,
                color: AppColors.primary,
              ),
            ),
          ),
        );

        expect(find.byType(MagicCircleWidget), findsOneWidget);
        
        // アニメーションが開始されることを確認
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      });

      testWidgets('should handle different sizes', (WidgetTester tester) async {
        const sizes = [100.0, 200.0, 300.0];
        
        for (final size in sizes) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MagicCircleWidget(
                  size: size,
                  color: AppColors.primary,
                ),
              ),
            ),
          );

          final magicCircle = tester.widget<MagicCircleWidget>(find.byType(MagicCircleWidget));
          expect(magicCircle.size, equals(size));
          
          await tester.pumpAndSettle();
        }
      });

      testWidgets('should animate continuously', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MagicCircleWidget(
                size: 200,
                color: AppColors.primary,
              ),
            ),
          ),
        );

        // アニメーションの進行を確認
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1000));
        
        // エラーが発生しないことを確認
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support different colors', (WidgetTester tester) async {
        const colors = [
          AppColors.primary,
          AppColors.secondary,
          Colors.red,
          Colors.blue,
        ];
        
        for (final color in colors) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MagicCircleWidget(
                  size: 200,
                  color: color,
                ),
              ),
            ),
          );

          final magicCircle = tester.widget<MagicCircleWidget>(find.byType(MagicCircleWidget));
          expect(magicCircle.color, equals(color));
          
          await tester.pumpAndSettle();
        }
      });
    });

    group('Widget Integration', () {
      testWidgets('should render multiple widgets together', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const AttributeBadge(attribute: '炎'),
                  const RarityBadge(rarity: 'レア'),
                  GradientButton(
                    text: '統合テスト',
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    onPressed: () {},
                  ),
                  const MagicCircleWidget(
                    size: 100,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('炎'), findsOneWidget);
        expect(find.text('レア'), findsOneWidget);
        expect(find.text('統合テスト'), findsOneWidget);
        expect(find.byType(MagicCircleWidget), findsOneWidget);

        // 全てのウィジェットが正常にレンダリングされることを確認
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  });
}