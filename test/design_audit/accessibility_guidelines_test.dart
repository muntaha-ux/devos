import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/core/theme/app_theme.dart';
import 'package:devos/features/auth/login_screen.dart';
import 'package:devos/features/dashboard/dashboard_screen.dart';
import 'package:devos/features/courses/courses_screen.dart';
import 'package:devos/features/skills/skills_screen.dart';
import 'package:devos/features/projects/projects_screen.dart';
import 'package:devos/features/workload/workload_screen.dart';
import 'package:devos/features/notes/notes_screen.dart';

Widget buildTestableScreen({
  required Widget screen,
  ThemeMode mode = ThemeMode.light,
  double textScale = 1.0,
  Size size = const Size(412, 915),
}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: screen,
        ),
      ),
    ),
  );
}

void main() {
  const targetSizes = [
    Size(360, 640),   // Small Phone
    Size(412, 915),   // Normal Phone
    Size(800, 1280),  // Tablet
    Size(915, 412),   // Landscape
  ];

  const textScales = [1.0, 1.3, 2.0];

  group('Phase 1C: Runtime Accessibility & Layout Audits', () {
    testWidgets('LoginScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: LoginScreen(onLoginSuccess: () {}),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('DashboardScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: DashboardScreen(onNavigateToTab: (_) {}),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Dashboard layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('WorkloadScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: const WorkloadScreen(),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Workload layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('NotesScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: const NotesScreen(),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Notes layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('CoursesScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: const CoursesScreen(),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Courses layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('ProjectsScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: const ProjectsScreen(),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Projects layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('SkillsScreen layout stability across screen sizes and scales',
        (tester) async {
      for (final size in targetSizes) {
        for (final scale in textScales) {
          tester.view.physicalSize = size * 2.0;
          tester.view.devicePixelRatio = 2.0;

          await tester.pumpWidget(
            buildTestableScreen(
              screen: const SkillsScreen(),
              textScale: scale,
              size: size,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull,
              reason: 'Skills layout overflow at size $size scale $scale');
        }
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
