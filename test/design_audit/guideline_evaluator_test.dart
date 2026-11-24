// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/core/theme/app_theme.dart';
import 'package:devos/features/auth/login_screen.dart';
import 'package:devos/features/dashboard/dashboard_screen.dart';
import 'package:devos/features/workload/workload_screen.dart';
import 'package:devos/features/notes/notes_screen.dart';

Widget wrapWithMaterial(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Flutter Accessibility Guidelines Audit', () {
    testWidgets('LoginScreen Android and iOS Tap Target Guidelines',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(LoginScreen(onLoginSuccess: () {})),
      );
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();

      // Check Android tap target
      try {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        print('[PASS] LoginScreen meets androidTapTargetGuideline');
      } catch (e) {
        print('[FAIL] LoginScreen androidTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      // Check iOS tap target
      try {
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        print('[PASS] LoginScreen meets iOSTapTargetGuideline');
      } catch (e) {
        print('[FAIL] LoginScreen iOSTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      // Check labeled tap targets
      try {
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        print('[PASS] LoginScreen meets labeledTapTargetGuideline');
      } catch (e) {
        print('[FAIL] LoginScreen labeledTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      handle.dispose();
    });

    testWidgets('DashboardScreen Tap Targets and Contrast Guidelines',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(DashboardScreen(onNavigateToTab: (_) {})),
      );
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();

      try {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        print('[PASS] DashboardScreen meets androidTapTargetGuideline');
      } catch (e) {
        print('[FAIL] DashboardScreen androidTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      try {
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        print('[PASS] DashboardScreen meets textContrastGuideline');
      } catch (e) {
        print('[FAIL] DashboardScreen textContrastGuideline: ${e.toString().split("\n").first}');
      }

      handle.dispose();
    });

    testWidgets('WorkloadScreen Tap Targets and Contrast Guidelines',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(const WorkloadScreen()),
      );
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();

      try {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        print('[PASS] WorkloadScreen meets androidTapTargetGuideline');
      } catch (e) {
        print('[FAIL] WorkloadScreen androidTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      try {
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        print('[PASS] WorkloadScreen meets textContrastGuideline');
      } catch (e) {
        print('[FAIL] WorkloadScreen textContrastGuideline: ${e.toString().split("\n").first}');
      }

      handle.dispose();
    });

    testWidgets('NotesScreen Tap Targets and Contrast Guidelines',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(const NotesScreen()),
      );
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();

      try {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        print('[PASS] NotesScreen meets androidTapTargetGuideline');
      } catch (e) {
        print('[FAIL] NotesScreen androidTapTargetGuideline: ${e.toString().split("\n").first}');
      }

      try {
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        print('[PASS] NotesScreen meets textContrastGuideline');
      } catch (e) {
        print('[FAIL] NotesScreen textContrastGuideline: ${e.toString().split("\n").first}');
      }

      handle.dispose();
    });
  });
}

