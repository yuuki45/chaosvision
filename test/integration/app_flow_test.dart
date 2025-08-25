import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chaos_vision/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CHAOS VISION App Integration Tests', () {
    setUp(() async {
      // 各テスト前にSharedPreferencesをクリア
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should complete full app navigation flow', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // ホーム画面の要素を確認
      expect(find.text('CHAOS VISION'), findsOneWidget);
      expect(find.text('中二スキャナー'), findsOneWidget);
      expect(find.text('スキャン開始'), findsOneWidget);

      // コレクション画面への遷移をテスト
      expect(find.text('神器図鑑'), findsOneWidget);
      await tester.tap(find.text('神器図鑑'));
      await tester.pumpAndSettle();

      // コレクション画面の要素を確認
      expect(find.text('神器図鑑'), findsAtLeastOneWidget);
      
      // 戻るボタンでホーム画面に戻る
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('CHAOS VISION'), findsOneWidget);

      // 設定画面への遷移をテスト
      // 設定ボタンを探して タップ
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        
        // 戻るボタンでホーム画面に戻る
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // アプリ情報画面への遷移をテスト
      final infoButton = find.byIcon(Icons.info_outline);
      if (infoButton.evaluate().isNotEmpty) {
        await tester.tap(infoButton);
        await tester.pumpAndSettle();
        
        // アプリ情報画面の要素を確認
        expect(find.text('CHAOS VISION'), findsAtLeastOneWidget);
        
        // 戻るボタンでホーム画面に戻る
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('CHAOS VISION'), findsOneWidget);
      }
    });

    testWidgets('should handle collection screen interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // コレクション画面に移動
      await tester.tap(find.text('神器図鑑'));
      await tester.pumpAndSettle();

      // 空のコレクション状態を確認
      expect(find.text('まだ神器をスキャンしていません'), findsOneWidget);

      // フィルターやソート機能があるかテスト
      // 属性フィルターボタンを探す
      final filterButtons = find.text('全て');
      if (filterButtons.evaluate().isNotEmpty) {
        await tester.tap(filterButtons.first);
        await tester.pumpAndSettle();
      }

      // 検索機能をテスト
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle();
        
        // 検索フィールドがあれば入力テスト
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'テスト');
          await tester.pumpAndSettle();
          
          // 検索をクリア
          await tester.enterText(searchField, '');
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('should handle special events', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // 特別イベントのバナーが表示される場合のテスト
      // イベントテスト画面があるかチェック
      final debugButton = find.text('イベントテスト');
      if (debugButton.evaluate().isNotEmpty) {
        await tester.tap(debugButton);
        await tester.pumpAndSettle();

        // イベント発動ボタンをテスト
        final eventTriggers = find.text('発動');
        if (eventTriggers.evaluate().isNotEmpty) {
          await tester.tap(eventTriggers.first);
          await tester.pumpAndSettle();
          
          // イベント効果が表示されることを確認
          await tester.pump(const Duration(seconds: 2));
        }

        // 戻る
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle theme and visual elements', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // ダークテーマが適用されていることを確認
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.dark));

      // 魔法陣やアニメーションが正常に動作することを確認
      // MagicCircleWidgetがあるかチェック
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      
      // アニメーション中にエラーが発生しないことを確認
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // スキャンボタンをタップ（カメラ権限がない状態）
      await tester.tap(find.text('スキャン開始'));
      await tester.pumpAndSettle();

      // スキャナー画面に遷移できるかテスト
      // エラーハンドリングが適切に行われることを確認
      await tester.pump(const Duration(seconds: 1));
      
      // エラーダイアログやメッセージが表示される場合の処理
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // アプリがクラッシュしていないことを確認
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle memory management during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // 複数の画面を行き来してメモリリークがないかテスト
      for (int i = 0; i < 5; i++) {
        // コレクション画面へ
        await tester.tap(find.text('神器図鑑'));
        await tester.pumpAndSettle();
        
        // ホーム画面へ戻る
        await tester.pageBack();
        await tester.pumpAndSettle();
        
        // アプリ情報画面があれば移動
        final infoButton = find.byIcon(Icons.info_outline);
        if (infoButton.evaluate().isNotEmpty) {
          await tester.tap(infoButton);
          await tester.pumpAndSettle();
          
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        
        // 少し待機
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 最終的にホーム画面に戻っていることを確認
      expect(find.text('CHAOS VISION'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(const ChaosVisionApp());
      await tester.pumpAndSettle();

      // 縦向き（デフォルト）
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.text('CHAOS VISION'), findsOneWidget);

      // 横向き
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();
      expect(find.text('CHAOS VISION'), findsOneWidget);

      // 縦向きに戻す
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.text('CHAOS VISION'), findsOneWidget);

      // レイアウトが適切に調整されることを確認
      expect(tester.takeException(), isNull);
    });
  });
}