import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Static Audit: Zero forbidden dark-mode keywords in lib/', () {
    final forbiddenKeywords = [
      'darkTheme',
      'ThemeMode.dark',
      'ThemeMode.system',
      'Brightness.dark',
      'ColorScheme.dark',
      'ThemeData.dark',
      'platformBrightness',
      'isDark',
      'isDarkMode',
    ];

    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib directory must exist');

    final violations = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = entity.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();

          // Skip comments
          if (trimmed.startsWith('//') || trimmed.startsWith('/*')) {
            continue;
          }

          for (final keyword in forbiddenKeywords) {
            if (line.contains(keyword)) {
              violations.add(
                '${entity.path}:${i + 1} contains "$keyword": "$trimmed"',
              );
            }
          }
        }
      }
    }

    if (violations.isNotEmpty) {
      fail(
        'Found ${violations.length} forbidden dark-mode occurrences in lib/:\n'
        '${violations.join('\n')}\n\n'
        'DevOS is strictly a single-theme light application. All dark theme branching '
        'and tokens must be removed.',
      );
    }
  });
}

