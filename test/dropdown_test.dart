import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/features/auth/login_screen.dart';

void main() {
  testWidgets('Test LoginScreen rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen(onLoginSuccess: () {})),
      ),
    );

    expect(find.text('DevOS'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });
}
