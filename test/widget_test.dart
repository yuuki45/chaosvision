// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chaos_vision/main.dart';

void main() {
  testWidgets('CHAOS VISION app smoke test', (WidgetTester tester) async {
    // Set a larger screen size for testing
    await tester.binding.setSurfaceSize(const Size(400, 800));
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChaosVisionApp());
    await tester.pump();

    // Verify that the app title is displayed
    expect(find.text('CHAOS VISION'), findsOneWidget);
    expect(find.text('中二スキャナー'), findsOneWidget);

    // Verify that the scan button exists
    expect(find.text('スキャン開始'), findsOneWidget);
  });
}
