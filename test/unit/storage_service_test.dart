import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chaos_vision/core/services/storage_service.dart';
import 'package:chaos_vision/shared/models/scanned_object.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() async {
      // SharedPreferences の mock を設定
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService.instance;
      await storageService.init();
      
      // テスト開始時にストレージをクリア
      await storageService.clearAllData();
    });

    tearDown(() async {
      // 各テスト後にクリーンアップ
      await storageService.clearAllData();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(storageService, isNotNull);
      });

      test('should handle multiple init calls gracefully', () async {
        await storageService.init();
        await storageService.init();
        expect(storageService, isNotNull);
      });
    });

    group('Scanned Objects Management', () {
      test('should save and retrieve scanned object', () async {
        final testObject = ScannedObject(
          id: 'test-1',
          objectName: '氷封の魔牢《フリージア・コア》',
          objectCategory: '冷蔵庫',
          attribute: '氷',
          rarity: 'レア',
          description: 'テスト用の冷蔵庫の設定',
          imageUrl: '/path/to/test/image.jpg',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject);
        
        final retrievedObjects = await storageService.getAllScannedObjects();
        expect(retrievedObjects.objects, hasLength(1));
        expect(retrievedObjects.objects.first.id, equals('test-1'));
        expect(retrievedObjects.objects.first.objectName, equals('氷封の魔牢《フリージア・コア》'));
      });

      test('should handle duplicate object IDs', () async {
        final testObject1 = ScannedObject(
          id: 'duplicate-id',
          objectName: '初回オブジェクト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: '最初の説明',
          scannedAt: DateTime.now(),
        );

        final testObject2 = ScannedObject(
          id: 'duplicate-id',
          objectName: '更新されたオブジェクト',
          objectCategory: 'テスト',
          attribute: '氷',
          rarity: 'レア',
          description: '更新された説明',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject1);
        await storageService.saveScannedObject(testObject2);
        
        final retrievedObjects = await storageService.getAllScannedObjects();
        expect(retrievedObjects.objects, hasLength(1));
        expect(retrievedObjects.objects.first.objectName, equals('更新されたオブジェクト'));
      });

      test('should retrieve objects with pagination', () async {
        // 複数のオブジェクトを作成
        for (int i = 0; i < 25; i++) {
          final testObject = ScannedObject(
            id: 'test-$i',
            objectName: 'オブジェクト$i',
            objectCategory: 'テスト',
            attribute: '炎',
            rarity: '通常',
            description: 'テスト用オブジェクト$i',
            scannedAt: DateTime.now().subtract(Duration(minutes: i)),
          );
          await storageService.saveScannedObject(testObject);
        }

        // 最初のページを取得（デフォルト20件）
        final firstPage = await storageService.getAllScannedObjects(page: 0, limit: 20);
        expect(firstPage.objects, hasLength(20));
        expect(firstPage.totalCount, equals(25));
        expect(firstPage.hasMore, isTrue);

        // 2ページ目を取得
        final secondPage = await storageService.getAllScannedObjects(page: 1, limit: 20);
        expect(secondPage.objects, hasLength(5));
        expect(secondPage.totalCount, equals(25));
        expect(secondPage.hasMore, isFalse);
      });

      test('should filter objects by attribute', () async {
        final fireObject = ScannedObject(
          id: 'fire-1',
          objectName: '炎のオブジェクト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: '炎属性のテストオブジェクト',
          scannedAt: DateTime.now(),
        );

        final iceObject = ScannedObject(
          id: 'ice-1',
          objectName: '氷のオブジェクト',
          objectCategory: 'テスト',
          attribute: '氷',
          rarity: '通常',
          description: '氷属性のテストオブジェクト',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(fireObject);
        await storageService.saveScannedObject(iceObject);

        final fireObjects = await storageService.getAllScannedObjects(attribute: '炎');
        expect(fireObjects.objects, hasLength(1));
        expect(fireObjects.objects.first.attribute, equals('炎'));

        final iceObjects = await storageService.getAllScannedObjects(attribute: '氷');
        expect(iceObjects.objects, hasLength(1));
        expect(iceObjects.objects.first.attribute, equals('氷'));
      });

      test('should filter objects by rarity', () async {
        final commonObject = ScannedObject(
          id: 'common-1',
          objectName: '通常のオブジェクト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: '通常レアのテストオブジェクト',
          scannedAt: DateTime.now(),
        );

        final rareObject = ScannedObject(
          id: 'rare-1',
          objectName: 'レアなオブジェクト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: 'レア',
          description: 'レアのテストオブジェクト',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(commonObject);
        await storageService.saveScannedObject(rareObject);

        final commonObjects = await storageService.getAllScannedObjects(rarity: '通常');
        expect(commonObjects.objects, hasLength(1));
        expect(commonObjects.objects.first.rarity, equals('通常'));

        final rareObjects = await storageService.getAllScannedObjects(rarity: 'レア');
        expect(rareObjects.objects, hasLength(1));
        expect(rareObjects.objects.first.rarity, equals('レア'));
      });

      test('should search objects by query', () async {
        final testObject1 = ScannedObject(
          id: 'search-1',
          objectName: '魔法の剣',
          objectCategory: '武器',
          attribute: '炎',
          rarity: 'レア',
          description: '古代の魔法が込められた剣',
          scannedAt: DateTime.now(),
        );

        final testObject2 = ScannedObject(
          id: 'search-2',
          objectName: '氷の盾',
          objectCategory: '防具',
          attribute: '氷',
          rarity: '通常',
          description: '氷の力で身を守る盾',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject1);
        await storageService.saveScannedObject(testObject2);

        // 名前での検索
        final swordResults = await storageService.getAllScannedObjects(searchQuery: '剣');
        expect(swordResults.objects, hasLength(1));
        expect(swordResults.objects.first.objectName, equals('魔法の剣'));

        // 説明での検索
        final iceResults = await storageService.getAllScannedObjects(searchQuery: '氷の力');
        expect(iceResults.objects, hasLength(1));
        expect(iceResults.objects.first.objectName, equals('氷の盾'));
      });
    });

    group('Settings Management', () {
      test('should manage sound settings', () async {
        // デフォルト値の確認
        expect(storageService.isSoundEnabled, isTrue);

        await storageService.setSoundEnabled(false);
        expect(storageService.isSoundEnabled, isFalse);

        await storageService.setSoundEnabled(true);
        expect(storageService.isSoundEnabled, isTrue);
      });

      test('should manage effects settings', () async {
        // デフォルト値の確認
        expect(storageService.isEffectsEnabled, isTrue);

        await storageService.setEffectsEnabled(false);
        expect(storageService.isEffectsEnabled, isFalse);

        await storageService.setEffectsEnabled(true);
        expect(storageService.isEffectsEnabled, isTrue);
      });

      test('should track first launch', () async {
        expect(storageService.isFirstLaunch, isTrue);
        
        await storageService.setFirstLaunchCompleted();
        expect(storageService.isFirstLaunch, isFalse);
      });
    });

    group('Statistics', () {
      test('should track total scanned count', () async {
        expect(storageService.totalScannedCount, equals(0));

        final testObject = ScannedObject(
          id: 'stats-1',
          objectName: 'テスト統計',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: '統計テスト用',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject);
        expect(storageService.totalScannedCount, equals(1));
      });

      test('should provide collection statistics', () async {
        // 異なる属性とレア度のオブジェクトを作成
        final objects = [
          ScannedObject(
            id: 'stat-fire-common',
            objectName: '炎・通常',
            objectCategory: 'テスト',
            attribute: '炎',
            rarity: '通常',
            description: 'テスト',
            scannedAt: DateTime.now(),
          ),
          ScannedObject(
            id: 'stat-fire-rare',
            objectName: '炎・レア',
            objectCategory: 'テスト',
            attribute: '炎',
            rarity: 'レア',
            description: 'テスト',
            scannedAt: DateTime.now(),
          ),
          ScannedObject(
            id: 'stat-ice-common',
            objectName: '氷・通常',
            objectCategory: 'テスト',
            attribute: '氷',
            rarity: '通常',
            description: 'テスト',
            scannedAt: DateTime.now(),
          ),
        ];

        for (final obj in objects) {
          await storageService.saveScannedObject(obj);
        }

        final stats = storageService.stats;
        expect(stats['totalObjects'], equals(3));
        expect(stats['attributeBreakdown']['炎'], equals(2));
        expect(stats['attributeBreakdown']['氷'], equals(1));
        expect(stats['rarityBreakdown']['通常'], equals(2));
        expect(stats['rarityBreakdown']['レア'], equals(1));
      });
    });

    group('Data Management', () {
      test('should delete individual objects', () async {
        final testObject = ScannedObject(
          id: 'delete-test',
          objectName: '削除テスト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: '削除テスト用',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject);
        expect((await storageService.getAllScannedObjects()).objects, hasLength(1));

        await storageService.deleteScannedObject('delete-test');
        expect((await storageService.getAllScannedObjects()).objects, hasLength(0));
      });

      test('should clear all data', () async {
        // データを追加
        final testObject = ScannedObject(
          id: 'clear-test',
          objectName: 'クリアテスト',
          objectCategory: 'テスト',
          attribute: '炎',
          rarity: '通常',
          description: 'クリアテスト用',
          scannedAt: DateTime.now(),
        );

        await storageService.saveScannedObject(testObject);
        await storageService.setSoundEnabled(false);
        
        expect((await storageService.getAllScannedObjects()).objects, hasLength(1));
        expect(storageService.isSoundEnabled, isFalse);

        // 全データクリア
        await storageService.clearAllData();
        
        expect((await storageService.getAllScannedObjects()).objects, hasLength(0));
        expect(storageService.isSoundEnabled, isTrue); // デフォルト値に戻る
      });
    });
  });
}