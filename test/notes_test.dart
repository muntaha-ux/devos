import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devos/models/note_model.dart';
import 'package:devos/providers/app_providers.dart';
import 'package:devos/features/notes/notes_screen.dart';
import 'package:devos/features/notes/note_detail_screen.dart';
import 'package:devos/features/notes/note_editor_screen.dart';
import 'package:devos/features/notes/widgets/markdown_renderer.dart';

void main() {
  final sampleNotes = [
    Note(
      id: 'test-note-1',
      title: 'Red-Black Tree Balancing Invariants',
      category: 'Algorithms & DSA',
      isFavorite: true,
      tags: ['#trees', '#algorithms', '#cpp'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      content: '''# Red-Black Tree Invariants
A self-balancing binary search tree.
```cpp
void leftRotate(Node*& root, Node* x) {
    // left rotate logic
}
```
> Rotation executes in O(1) time.''',
    ),
    Note(
      id: 'test-note-2',
      title: 'Distributed Sagas & Event Architecture',
      category: 'System Architecture',
      isFavorite: false,
      tags: ['#architecture', '#distributed', '#sql'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      content: '''# Saga Pattern Architecture
Eventual consistency across distributed services.
```sql
UPDATE order_reservations SET status = 'COMPENSATED';
```''',
    ),
    Note(
      id: 'test-note-3',
      title: 'Dart 3 Records Cheatsheet',
      category: 'Quick Cheatsheets',
      isFavorite: true,
      tags: ['#dart', '#flutter'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      content: '''# Dart 3 Records
Pattern matching and records syntax.''',
    ),
  ];

  Widget createNotesWidget({List<Note>? customNotes}) {
    return ProviderScope(
      overrides: [
        notesProvider.overrideWith(
          (ref) => MockNotesNotifier(customNotes ?? sampleNotes),
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: NotesScreen())),
    );
  }

  testWidgets(
    'NotesScreen renders banner, metrics, folder pills, and initial notes',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createNotesWidget());
      await tester.pumpAndSettle();

      // Verify Header Banner
      expect(find.text('Knowledge Base'), findsOneWidget);
      expect(find.text('MARKDOWN NOTEBOOK & SNIPPET LIBRARY'), findsOneWidget);

      // Verify Metric Cards
      expect(find.text('Total Notes'), findsOneWidget);
      expect(find.text('Active Folders'), findsOneWidget);
      expect(find.text('Code Snippets'), findsOneWidget);
      expect(find.text('Starred Notes'), findsOneWidget);

      // Verify Categorized Folder Structure Pills
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Algorithms & DSA'), findsOneWidget);
      expect(find.text('System Architecture'), findsOneWidget);
      expect(find.text('Quick Cheatsheets'), findsOneWidget);

      // Verify Multi-tag Filter Chips
      expect(find.text('#trees'), findsWidgets);
      expect(find.text('#cpp'), findsWidgets);

      // Verify Notes Cards
      expect(find.text('Red-Black Tree Balancing Invariants'), findsOneWidget);
      expect(
        find.text('Distributed Sagas & Event Architecture'),
        findsOneWidget,
      );
      expect(find.text('Dart 3 Records Cheatsheet'), findsOneWidget);
    },
  );

  testWidgets('Folder filtering isolates notes belonging to selected folder', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createNotesWidget());
    await tester.pumpAndSettle();

    // Tap 'Algorithms & DSA' folder pill
    final algoFolder = find.widgetWithText(InkWell, 'Algorithms & DSA');
    expect(algoFolder, findsOneWidget);
    await tester.tap(algoFolder);
    await tester.pumpAndSettle();

    // Only Red-Black tree note should appear
    expect(find.text('Red-Black Tree Balancing Invariants'), findsOneWidget);
    expect(find.text('Distributed Sagas & Event Architecture'), findsNothing);
    expect(find.text('Dart 3 Records Cheatsheet'), findsNothing);

    // Tap 'All' folder pill
    final allFolder = find.widgetWithText(InkWell, 'All');
    await tester.tap(allFolder);
    await tester.pumpAndSettle();

    // All notes visible again
    expect(find.text('Red-Black Tree Balancing Invariants'), findsOneWidget);
    expect(find.text('Distributed Sagas & Event Architecture'), findsOneWidget);
  });

  testWidgets(
    'Multi-tag filtering correctly filters notes with concurrent tags',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createNotesWidget());
      await tester.pumpAndSettle();

      // Select tag '#trees'
      final treesChip = find.widgetWithText(FilterChip, '#trees');
      expect(treesChip, findsOneWidget);
      await tester.tap(treesChip);
      await tester.pumpAndSettle();

      // Only trees note visible
      expect(find.text('Red-Black Tree Balancing Invariants'), findsOneWidget);
      expect(find.text('Distributed Sagas & Event Architecture'), findsNothing);

      // Select tag '#cpp' as second tag
      final cppChip = find.widgetWithText(FilterChip, '#cpp');
      expect(cppChip, findsOneWidget);
      await tester.tap(cppChip);
      await tester.pumpAndSettle();

      // Red-Black tree has both #trees and #cpp
      expect(find.text('Red-Black Tree Balancing Invariants'), findsOneWidget);

      // Tap 'Clear Tags'
      await tester.tap(find.textContaining('Clear Tags'));
      await tester.pumpAndSettle();

      // All notes return
      expect(
        find.text('Distributed Sagas & Event Architecture'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Search query filters notes by title or content preview', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createNotesWidget());
    await tester.pumpAndSettle();

    // Enter search text 'Sagas'
    await tester.enterText(find.byType(TextField), 'Sagas');
    await tester.pumpAndSettle();

    expect(find.text('Distributed Sagas & Event Architecture'), findsOneWidget);
    expect(find.text('Red-Black Tree Balancing Invariants'), findsNothing);
  });

  testWidgets(
    'NoteDetailScreen renders markdown and toggles Distraction-Free Zen Mode',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testNote = sampleNotes.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesProvider.overrideWith((ref) => MockNotesNotifier(sampleNotes)),
          ],
          child: MaterialApp(home: NoteDetailScreen(note: testNote)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title and Markdown rendering
      expect(find.text('Red-Black Tree Balancing Invariants'), findsWidgets);
      expect(find.text('CPP'), findsOneWidget); // Language badge
      expect(find.text('COPY'), findsOneWidget); // Copy button

      // Toggle Zen Mode
      final zenBtn = find.text('ZEN READING');
      expect(zenBtn, findsOneWidget);
      await tester.tap(zenBtn);
      await tester.pumpAndSettle();

      // Zen Mode banner
      expect(find.text('ZEN MODE ACTIVE'), findsOneWidget);
      expect(find.text('Exit Zen Mode'), findsOneWidget);

      // Exit Zen Mode
      await tester.tap(find.text('Exit Zen Mode'));
      await tester.pumpAndSettle();

      expect(find.text('ZEN MODE ACTIVE'), findsNothing);
    },
  );

  testWidgets('MarkdownRenderer formats code snippets, headings, and quotes', (
    WidgetTester tester,
  ) async {
    const md = '''# Title H1
## Sub H2
> Important Note
```python
def solve():
    return 42
```''';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: MarkdownRenderer(content: md)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Title H1'), findsOneWidget);
    expect(find.text('Sub H2'), findsOneWidget);
    expect(find.text('PYTHON'), findsOneWidget);
    expect(find.text('COPY'), findsOneWidget);
  });

  testWidgets(
    'NoteEditorScreen switches between Editor, Preview, and Zen Focus',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesProvider.overrideWith((ref) => MockNotesNotifier(sampleNotes)),
          ],
          child: const MaterialApp(home: NoteEditorScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Editor Mode tabs
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Live Preview'), findsOneWidget);
      expect(find.text('Zen Focus'), findsOneWidget);

      // Switch to Live Preview
      await tester.tap(find.text('Live Preview'));
      await tester.pumpAndSettle();
      expect(find.text('No markdown content to preview.'), findsOneWidget);

      // Switch to Zen Focus
      await tester.tap(find.text('Zen Focus'));
      await tester.pumpAndSettle();
      expect(find.text('Exit Zen Focus'), findsOneWidget);

      // Exit Zen Focus
      await tester.tap(find.text('Exit Zen Focus'));
      await tester.pumpAndSettle();
      expect(find.text('Editor'), findsOneWidget);
    },
  );
}

// ===================== MOCK NOTIFIERS FOR QA TESTING =====================

class MockNotesNotifier extends StateNotifier<List<Note>>
    implements NotesNotifier {
  MockNotesNotifier(super.initialNotes);

  @override
  Future<void> loadNotes() async {}

  @override
  Future<void> toggleFavorite(String noteId) async {
    state = state.map((n) {
      if (n.id == noteId) {
        return n.copyWith(isFavorite: !n.isFavorite);
      }
      return n;
    }).toList();
  }

  @override
  Future<void> addNote(Note note) async {
    state = [note, ...state];
  }

  @override
  Future<void> updateNote(Note updated) async {
    state = state.map((n) => n.id == updated.id ? updated : n).toList();
  }

  @override
  Future<void> deleteNote(String noteId) async {
    state = state.where((n) => n.id != noteId).toList();
  }
}
