import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devos/core/theme/app_theme.dart';
import 'package:devos/features/auth/login_screen.dart';
import 'package:devos/features/dashboard/dashboard_screen.dart';
import 'package:devos/features/courses/courses_screen.dart';
import 'package:devos/features/skills/skills_screen.dart';
import 'package:devos/features/projects/projects_screen.dart';
import 'package:devos/features/workload/workload_screen.dart';
import 'package:devos/features/notes/notes_screen.dart';

Widget wrapForGolden(Widget child, {ThemeMode mode = ThemeMode.light, Size size = const Size(412, 850)}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      home: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final goldensDir = Directory('test/design_audit/goldens');
    if (!goldensDir.existsSync()) {
      goldensDir.createSync(recursive: true);
    }
  });

  group('Phase 1D: Visual Evidence & Golden Capture', () {
    testWidgets('Capture LoginScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // 1. Light Mode
      await tester.pumpWidget(
        wrapForGolden(LoginScreen(onLoginSuccess: () {}), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen_light.png'),
      );

      // 2. Dark Mode
      await tester.pumpWidget(
        wrapForGolden(LoginScreen(onLoginSuccess: () {}), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture DashboardScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(DashboardScreen(onNavigateToTab: (_) {}), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dashboard_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(DashboardScreen(onNavigateToTab: (_) {}), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dashboard_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture WorkloadScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(const WorkloadScreen(), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workload_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(const WorkloadScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workload_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture NotesScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(const NotesScreen(), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notes_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(const NotesScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notes_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture CoursesScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(const CoursesScreen(), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/courses_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(const CoursesScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/courses_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture ProjectsScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(const ProjectsScreen(), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/projects_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(const ProjectsScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/projects_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture SkillsScreen Goldens (Light & Dark)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      // Light
      await tester.pumpWidget(
        wrapForGolden(const SkillsScreen(), mode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/skills_screen_light.png'),
      );

      // Dark
      await tester.pumpWidget(
        wrapForGolden(const SkillsScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/skills_screen_dark.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
