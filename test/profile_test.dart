import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/models/profile_model.dart';
import 'package:devos/providers/app_providers.dart';
import 'package:devos/features/profile/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders header, credentials, and live metrics', (tester) async {
    final testProfile = UserProfile(
      id: 'test-user-uuid-1234',
      email: 'muntahashidratul3@gmail.com',
      fullName: 'Muntaha Shidratul',
      avatarUrl: '',
      institution: 'Bangladesh Army University of Science and Technology',
      major: 'Computer Science & Engineering',
      academicYear: '3rd Year (Junior)',
      learningStreak: 14,
      bio: 'Distributed Systems & Robotics Researcher',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            (ref) => ProfileNotifier(ref.read(databaseRepositoryProvider))..setProfile(testProfile),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Student Credentials
    expect(find.text('Engineering Profile'), findsOneWidget);
    expect(find.text('Muntaha Shidratul'), findsAtLeastNWidgets(1));
    expect(find.text('Computer Science & Engineering'), findsAtLeastNWidgets(1));
    expect(find.text('Bangladesh Army University of Science and Technology'), findsAtLeastNWidgets(1));
    expect(find.text('14d Streak'), findsOneWidget);
    expect(find.text('3rd Year (Junior)'), findsAtLeastNWidgets(1));

    // Verify Monogram Initials
    expect(find.text('MS'), findsOneWidget);

    // Verify Metrics Section
    expect(find.text('ACADEMIC PULSE & VELOCITY'), findsOneWidget);
    expect(find.text('COURSES'), findsOneWidget);
    expect(find.text('TASKS DONE'), findsOneWidget);
    expect(find.text('PROJECTS'), findsOneWidget);
    expect(find.text('SKILLS'), findsOneWidget);
  });

  testWidgets('Toggling Edit Profile allows updating fields and saving', (tester) async {
    final testProfile = UserProfile(
      id: 'test-user-uuid-1234',
      email: 'alex.dev@university.edu',
      fullName: 'Alex Vance',
      avatarUrl: '',
      institution: 'University of Science & Tech',
      major: 'Computer Science & Engineering',
      academicYear: '3rd Year (Junior)',
      learningStreak: 12,
    );

    late ProfileNotifier profileNotifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith((ref) {
            profileNotifier = ProfileNotifier(ref.read(databaseRepositoryProvider));
            profileNotifier.setProfile(testProfile);
            return profileNotifier;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap "Edit Profile"
    final editButton = find.text('Edit Profile');
    expect(editButton, findsOneWidget);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Button should now show "Save Profile"
    expect(find.text('Save Profile'), findsOneWidget);

    // Enter new name
    final nameField = find.widgetWithText(TextFormField, 'Alex Vance');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Dr. Gordon Freeman');
    await tester.pumpAndSettle();

    // Tap "Save Profile"
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    // Verify state was updated
    expect(profileNotifier.state.fullName, equals('Dr. Gordon Freeman'));
  });

  testWidgets('ProfileScreen renders base64 data URI avatar image cleanly', (tester) async {
    // 1x1 transparent GIF encoded as Base64 Data URI
    const transparentGif =
        'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

    final testProfile = UserProfile(
      id: 'test-user-uuid-1234',
      email: 'avatar.tester@devos.app',
      fullName: 'Image Tester',
      avatarUrl: transparentGif,
      institution: 'Tech Academy',
      major: 'Robotics',
      academicYear: '4th Year (Senior)',
      learningStreak: 20,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            (ref) => ProfileNotifier(ref.read(databaseRepositoryProvider))..setProfile(testProfile),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Image.memory should be inflated without exceptions
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Tapping streak increment button increases learning streak in state', (tester) async {
    final testProfile = UserProfile(
      id: 'test-user-uuid-1234',
      email: 'streak.tester@devos.app',
      fullName: 'Streak Tester',
      avatarUrl: '',
      institution: 'Tech Academy',
      major: 'Computer Science',
      academicYear: '2nd Year (Sophomore)',
      learningStreak: 5,
    );

    late ProfileNotifier profileNotifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith((ref) {
            profileNotifier = ProfileNotifier(ref.read(databaseRepositoryProvider));
            profileNotifier.setProfile(testProfile);
            return profileNotifier;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(profileNotifier.state.learningStreak, equals(5));

    // Tap "Log Today's Study Session (+1 Streak)"
    final streakTile = find.text("Log Today's Study Session (+1 Streak)");
    expect(streakTile, findsOneWidget);
    await tester.ensureVisible(streakTile);
    await tester.pumpAndSettle();
    await tester.tap(streakTile);
    await tester.pumpAndSettle();

    // Verify streak increased to 6
    expect(profileNotifier.state.learningStreak, equals(6));
  });
}
