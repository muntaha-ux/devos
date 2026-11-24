import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:devos/core/constants/app_colors.dart';
import 'package:devos/core/theme/app_theme.dart';
import 'package:devos/features/auth/login_screen.dart';
import 'package:devos/features/dashboard/dashboard_screen.dart';
import 'package:devos/features/courses/courses_screen.dart';
import 'package:devos/features/skills/skills_screen.dart';
import 'package:devos/features/projects/projects_screen.dart';
import 'package:devos/features/workload/workload_screen.dart';
import 'package:devos/features/notes/notes_screen.dart';

Widget createLightThemeApp(Widget screen) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      home: Scaffold(
        backgroundColor: AppColors.figmaBackground,
        body: screen,
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Light-Only Single-Theme Immunity Tests', () {
    testWidgets('LoginScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(LoginScreen(onLoginSuccess: () {})));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(LoginScreen));
      expect(Theme.of(context).brightness, Brightness.light);

      // Verify scaffold and canvas stay light
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AppColors.figmaBackground);
    });

    testWidgets('DashboardScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(DashboardScreen(onNavigateToTab: (_) {})));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(DashboardScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('CoursesScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(const CoursesScreen()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(CoursesScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('SkillsScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(const SkillsScreen()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(SkillsScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('ProjectsScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(const ProjectsScreen()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(ProjectsScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('WorkloadScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(const WorkloadScreen()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(WorkloadScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });

    testWidgets('NotesScreen remains strictly Light under OS Dark Brightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(createLightThemeApp(const NotesScreen()));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(NotesScreen));
      expect(Theme.of(context).brightness, Brightness.light);
    });
  });
}

