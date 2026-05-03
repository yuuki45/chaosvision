import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chaos_vision/core/services/storage_service.dart';
import 'package:chaos_vision/shared/models/scanned_object.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('cv_storage_test_');

    // Hive.initFlutter() under the hood asks path_provider for the
    // documents directory; stub it so the service can boot in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir.path,
    );
    SharedPreferences.setMockInitialValues({});

    await StorageService.instance.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    await StorageService.instance.clearAllData();
  });

  ScannedObject make({
    required String id,
    String objectCategory = '冷蔵庫',
    String alternateName = '氷封の魔牢',
    String attribute = '氷',
    String description = '冷たい力を秘めた古代の遺物',
    String rarity = 'コモン',
    DateTime? scannedAt,
    double confidence = 0.9,
  }) {
    return ScannedObject(
      id: id,
      objectCategory: objectCategory,
      alternateName: alternateName,
      attribute: attribute,
      description: description,
      rarity: rarity,
      scannedAt: scannedAt ?? DateTime(2026, 5, 1, 12, 0),
      confidence: confidence,
    );
  }

  group('StorageService — CRUD', () {
    test('saves and retrieves an object', () async {
      final obj = make(id: '1');
      await StorageService.instance.saveScannedObject(obj);

      final all = StorageService.instance.getAllScannedObjects();
      expect(all, hasLength(1));
      expect(all.first.id, '1');
      expect(all.first.alternateName, '氷封の魔牢');
    });

    test('deletes a single object', () async {
      await StorageService.instance.saveScannedObject(make(id: 'a'));
      await StorageService.instance.saveScannedObject(make(id: 'b'));

      final ok = await StorageService.instance.deleteScannedObject('a');

      expect(ok, isTrue);
      final all = StorageService.instance.getAllScannedObjects();
      expect(all.map((e) => e.id), ['b']);
    });

    test('clearAllData removes everything', () async {
      await StorageService.instance.saveScannedObject(make(id: 'a'));
      await StorageService.instance.saveScannedObject(make(id: 'b'));

      await StorageService.instance.clearAllData();

      expect(StorageService.instance.getAllScannedObjects(), isEmpty);
    });
  });

  group('StorageService — filters', () {
    test('filters by attribute', () async {
      await StorageService.instance.saveScannedObject(
        make(id: '1', attribute: '炎'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: '2', attribute: '氷'),
      );

      final result = StorageService.instance.getObjectsWithFilters(
        limit: 10,
        attributeFilter: '炎',
      );

      expect(result.objects.map((e) => e.id), ['1']);
      expect(result.totalCount, 1);
    });

    test('filters by rarity, normalising English values', () async {
      await StorageService.instance.saveScannedObject(
        make(id: 'jp', rarity: 'ミシック'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'en', rarity: 'Mythic'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'common', rarity: 'コモン'),
      );

      final result = StorageService.instance.getObjectsWithFilters(
        limit: 10,
        rarityFilter: 'ミシック',
      );

      expect(result.objects.map((e) => e.id).toSet(), {'jp', 'en'});
    });

    test('filter "すべて" returns everything', () async {
      await StorageService.instance.saveScannedObject(
        make(id: '1', attribute: '炎'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: '2', attribute: '氷'),
      );

      final result = StorageService.instance.getObjectsWithFilters(
        limit: 10,
        attributeFilter: 'すべて',
        rarityFilter: 'すべて',
      );

      expect(result.totalCount, 2);
    });
  });

  group('StorageService — sort', () {
    test('newest is the default', () async {
      await StorageService.instance.saveScannedObject(
        make(id: 'old', scannedAt: DateTime(2026, 1, 1)),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'new', scannedAt: DateTime(2026, 5, 1)),
      );

      final result =
          StorageService.instance.getObjectsWithFilters(limit: 10);

      expect(result.objects.map((e) => e.id), ['new', 'old']);
    });

    test('oldest reverses the order', () async {
      await StorageService.instance.saveScannedObject(
        make(id: 'old', scannedAt: DateTime(2026, 1, 1)),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'new', scannedAt: DateTime(2026, 5, 1)),
      );

      final result = StorageService.instance.getObjectsWithFilters(
        limit: 10,
        sortMode: SortMode.oldest,
      );

      expect(result.objects.map((e) => e.id), ['old', 'new']);
    });

    test('rarityDesc puts mythic first', () async {
      await StorageService.instance.saveScannedObject(
        make(id: 'common', rarity: 'コモン'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'mythic', rarity: 'ミシック'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: 'epic', rarity: 'エピック'),
      );

      final result = StorageService.instance.getObjectsWithFilters(
        limit: 10,
        sortMode: SortMode.rarityDesc,
      );

      expect(
        result.objects.map((e) => e.id),
        ['mythic', 'epic', 'common'],
      );
    });
  });

  group('StorageService — pagination', () {
    test('respects limit and offset and reports hasMore', () async {
      for (int i = 0; i < 5; i++) {
        await StorageService.instance.saveScannedObject(
          make(
            id: '$i',
            scannedAt: DateTime(2026, 5, i + 1),
          ),
        );
      }

      final page1 = StorageService.instance.getObjectsWithFilters(
        limit: 2,
        offset: 0,
      );
      expect(page1.objects, hasLength(2));
      expect(page1.totalCount, 5);
      expect(page1.hasMore, isTrue);

      final tail = StorageService.instance.getObjectsWithFilters(
        limit: 2,
        offset: 4,
      );
      expect(tail.objects, hasLength(1));
      expect(tail.hasMore, isFalse);
    });
  });

  group('StorageService — stats', () {
    test('rarityStats counts each tier and normalises English', () async {
      await StorageService.instance.saveScannedObject(
        make(id: '1', rarity: 'コモン'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: '2', rarity: 'コモン'),
      );
      await StorageService.instance.saveScannedObject(
        make(id: '3', rarity: 'Mythic'),
      );

      final stats = StorageService.instance.rarityStats;

      expect(stats['コモン'], 2);
      expect(stats['ミシック'], 1);
      expect(stats['レア'], 0);
      expect(stats['エピック'], 0);
      expect(stats['レジェンダリー'], 0);
    });
  });
}
