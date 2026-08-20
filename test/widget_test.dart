import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/main.dart';

void main() {
  testWidgets('DevOS smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DevOSApp()));

    // Verify that DevOS app title or main UI loads properly
    expect(find.text('Dashboard Overview'), findsOneWidget);
  });
}
