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

Widget wrapForGolden(Widget child, {Size size = const Size(412, 850)}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
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
    GoogleFonts.config.allowRuntimeFetching = true;
    final goldensDir = Directory('test/design_audit/goldens');
    if (!goldensDir.existsSync()) {
      goldensDir.createSync(recursive: true);
    }
  });

  group('Visual Evidence & Golden Capture (Light Only)', () {
    testWidgets('Capture LoginScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(LoginScreen(onLoginSuccess: () {})),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture DashboardScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(DashboardScreen(onNavigateToTab: (_) {})),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dashboard_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture WorkloadScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(const WorkloadScreen()),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workload_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture NotesScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(const NotesScreen()),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/notes_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture CoursesScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(const CoursesScreen()),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/courses_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture ProjectsScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(const ProjectsScreen()),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/projects_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Capture SkillsScreen Goldens (Light)', (tester) async {
      tester.view.physicalSize = const Size(824, 1700);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        wrapForGolden(const SkillsScreen()),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/skills_screen_light.png'),
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
