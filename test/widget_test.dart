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
  testWidgets('Đăng nhập opens shared OTP flow', (WidgetTester tester) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Nhập số điện thoại'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Mã OTP đã được gửi tới'), findsOneWidget);
    expect(find.text('Nhập mã OTP'), findsOneWidget);
  });

  testWidgets('Đăng ký button opens register page', (WidgetTester tester) async {
    await tester.pumpWidget(const GluCareApp());

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký tài khoản mới'), findsOneWidget);
    expect(find.text('Nhập số điện thoại'), findsOneWidget);
    expect(find.text('Tiếp theo'), findsOneWidget);
  });

  testWidgets('Tiếp theo transitions to OTP step', (WidgetTester tester) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Mã OTP đã được gửi tới'), findsOneWidget);
    expect(find.text('Nhập mã OTP'), findsOneWidget);
  });

  testWidgets('Register OTP continue transitions to profile setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GluCareApp());

    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0999123456');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập mã OTP'), findsOneWidget);

    final Finder continueButton = find.widgetWithText(ElevatedButton, 'Tiếp theo').last;
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập hồ sơ bệnh án'), findsOneWidget);
    expect(find.text('Tên của bạn'), findsOneWidget);
    expect(find.text('Giới tính'), findsOneWidget);
    expect(find.text('Ngày sinh'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nguyễn Văn An');
    await tester.pumpAndSettle();

    final Finder profileContinueButton = find.widgetWithText(ElevatedButton, 'Tiếp theo').last;
    await tester.ensureVisible(profileContinueButton);
    await tester.tap(profileContinueButton);
    await tester.pumpAndSettle();

    expect(find.text('Xin chào!'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsOneWidget);

    final Finder greetingContinueButton = find.widgetWithText(ElevatedButton, 'Tiếp theo').last;
    await tester.ensureVisible(greetingContinueButton);
    await tester.tap(greetingContinueButton);
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng đến với'), findsOneWidget);
    expect(find.text('GlucoDia'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
