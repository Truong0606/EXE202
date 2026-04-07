// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/app.dart';

void main() {
  testWidgets('Đăng nhập opens password flow', (WidgetTester tester) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Nhập số điện thoại'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập mật khẩu cho số'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
  });

  testWidgets('Đăng ký button opens register page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GluCareApp());

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký tài khoản mới'), findsOneWidget);
    expect(find.text('Nhập số điện thoại'), findsOneWidget);
    expect(find.text('Tiếp theo'), findsOneWidget);
  });

  testWidgets('Tiếp theo transitions to password step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập mật khẩu cho số'), findsOneWidget);
    expect(find.text('Tối thiểu 8 ký tự'), findsOneWidget);
  });

  testWidgets('Quên mật khẩu opens reset screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();

    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(find.text('Đặt lại mật khẩu'), findsOneWidget);
    expect(find.text('Cập nhật mật khẩu'), findsOneWidget);
  });

  testWidgets('Register password continue transitions to profile setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập mật khẩu cho số'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '12345678');
    await tester.pumpAndSettle();

    final Finder continueButton = find.text('Tiếp theo').last;
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập hồ sơ bệnh án'), findsOneWidget);
    expect(find.text('Tên của bạn'), findsOneWidget);
    expect(find.text('Giới tính'), findsOneWidget);
    expect(find.text('Ngày sinh'), findsOneWidget);
  });
}
