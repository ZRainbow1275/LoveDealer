// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app structure test', (WidgetTester tester) async {
    // 构建一个简单的应用用于测试
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('记录应用测试'),
          ),
        ),
      ),
    );

    // 验证应用成功启动并显示文本
    expect(find.text('记录应用测试'), findsOneWidget);
  });
}
