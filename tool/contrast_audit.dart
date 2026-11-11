import 'dart:io';
import 'dart:math' as math;

class ColorEntry {
  final int value;
  final String name;

  const ColorEntry(this.value, this.name);

  int get a => (value >> 24) & 0xFF;
  int get r => (value >> 16) & 0xFF;
  int get g => (value >> 8) & 0xFF;
  int get b => value & 0xFF;

  double get opacity => a / 255.0;

  String get hexString =>
      '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  ColorEntry blendOver(ColorEntry background) {
    if (a == 255) return this;
    final alpha = opacity;
    final rOut = ((r * alpha) + (background.r * (1.0 - alpha))).round();
    final gOut = ((g * alpha) + (background.g * (1.0 - alpha))).round();
    final bOut = ((b * alpha) + (background.b * (1.0 - alpha))).round();
    final combinedValue = (0xFF << 24) | (rOut << 16) | (gOut << 8) | bOut;
    return ColorEntry(combinedValue, '$name over ${background.name}');
  }

  double get relativeLuminance {
    double linearize(int channel) {
      final s = channel / 255.0;
      return s <= 0.04045
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    final lr = linearize(r);
    final lg = linearize(g);
    final lb = linearize(b);
    return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
  }
}

class ColorPairing {
  final String id;
  final String screen;
  final String element;
  final ColorEntry foreground;
  final ColorEntry background;
  final bool isLargeText;
  final bool isUiComponent;
  final String context;

  const ColorPairing({
    required this.id,
    required this.screen,
    required this.element,
    required this.foreground,
    required this.background,
    this.isLargeText = false,
    this.isUiComponent = false,
    required this.context,
  });

  double get contrastRatio {
    final effectiveFg = foreground.blendOver(background);
    final l1 = effectiveFg.relativeLuminance;
    final l2 = background.relativeLuminance;
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  double get requiredRatio {
    if (isUiComponent || isLargeText) return 3.0;
    return 4.5;
  }

  bool get passes => contrastRatio >= requiredRatio;
}

void main() {
  print('================================================================');
  print('          DevOS WCAG 2.1 CONTRAST AUDIT (Phase 1B)');
  print('================================================================\n');

  // Core Brand Tokens
  const canvasLight = ColorEntry(0xFFD6BDBD, 'Canvas Light (#D6BDBD)');
  const canvasDark = ColorEntry(0xFF0D1117, 'Obsidian Canvas Dark (#0D1117)');
  const darkBanner = ColorEntry(0xFF2E1065, 'Dark Purple Banner (#2E1065)');
  const darkPurpleBanner = ColorEntry(0xFF352554, 'Design Banner (#352554)');
  const crimsonAction = ColorEntry(0xFF8F0030, 'Crimson Action (#8F0030)');
  const codeBadgeGreen = ColorEntry(0xFF0EA358, 'Code Badge (#0EA358)');
  const metricCardLight = ColorEntry(0xFFF3F3F3, 'Metric Card Light (#F3F3F3)');
  const cardDark = ColorEntry(0xFF21262D, 'Card Dark (#21262D)');
  const cardBorderLight = ColorEntry(0xFF333333, 'Card Border Light (#333333)');
  const urgentCardBg = ColorEntry(0xFFCECECE, 'Urgent Card (#CECECE)');
  const maroonText = ColorEntry(0xFF7A0C16, 'Maroon Text (#7A0C16)');
  const white = ColorEntry(0xFFFFFFFF, 'White (#FFFFFF)');
  const black = ColorEntry(0xFF000000, 'Black (#000000)');
  const black87 = ColorEntry(0xDD000000, 'Black87');
  const black54 = ColorEntry(0x8A000000, 'Black54');
  const white70 = ColorEntry(0xB3FFFFFF, 'White70');
  const white38 = ColorEntry(0x61FFFFFF, 'White38');
  const figmaTextRed = ColorEntry(0xFFB91C1C, 'Figma Text Red (#B91C1C)');
  const figmaBlue = ColorEntry(0xFF1E56FF, 'Figma Blue (#1E56FF)');
  const primaryBlue = ColorEntry(0xFF2563EB, 'Primary Blue (#2563EB)');
  const lavenderCard = ColorEntry(0xFFE4DBEA, 'Lavender Card (#E4DBEA)');
  const forestBanner = ColorEntry(0xFF2E6316, 'Forest Banner (#2E6316)');
  const orangeCard = ColorEntry(0xFFEA580C, 'Orange Card (#EA580C)');
  const cyanCard = ColorEntry(0xFF0284C7, 'Cyan Card (#0284C7)');
  const purpleCard = ColorEntry(0xFF7C3AED, 'Purple Card (#7C3AED)');
  const plusBtnBg = ColorEntry(0xFFE8C4C4, 'Plus Button Light Pink (#E8C4C4)');
  const yellowAmber = ColorEntry(0xFFF59E0B, 'Amber (#F59E0B)');
  const lightGreyBadge = ColorEntry(0xFFE5E7EB, 'Light Grey Tag (#E5E7EB)');
  const darkCodeContainer = ColorEntry(0xFF201633, 'Dark Code Container (#201633)');
  const lightPurplePill = ColorEntry(0xFFD6BCFA, 'Light Purple Pill Text (#D6BCFA)');

  final pairings = <ColorPairing>[
    // --- System / Theme Defaults ---
    ColorPairing(
      id: 'PAL-01',
      screen: 'Theme / Global',
      element: 'Floating Action Button Text',
      foreground: black,
      background: primaryBlue,
      context: 'lib/core/theme/app_theme.dart:69 - black text on primary blue',
    ),
    ColorPairing(
      id: 'PAL-02',
      screen: 'Global',
      element: 'Maroon Heading on Canvas',
      foreground: maroonText,
      background: canvasLight,
      isLargeText: true,
      context: 'lib/core/constants/app_colors.dart:104 - maroon text on light canvas #D6BDBD',
    ),
    ColorPairing(
      id: 'PAL-03',
      screen: 'Global',
      element: 'White Text on Light Canvas',
      foreground: white,
      background: canvasLight,
      context: 'Discovered in un-themed cards or default white text rendered on canvas',
    ),
    ColorPairing(
      id: 'PAL-04',
      screen: 'Global',
      element: 'Black Text on Obsidian Canvas',
      foreground: black87,
      background: canvasDark,
      context: 'Dark mode when widgets hardcode Colors.black87 on dark canvas',
    ),
    ColorPairing(
      id: 'PAL-05',
      screen: 'Global',
      element: 'White Text on Crimson Action',
      foreground: white,
      background: crimsonAction,
      context: 'Crimson button label (LAUNCH, SUBMIT, NEW TASK)',
    ),
    ColorPairing(
      id: 'PAL-06',
      screen: 'Global',
      element: 'White Text on Code Badge Green',
      foreground: white,
      background: codeBadgeGreen,
      isLargeText: true,
      context: 'Code badge </> label and sprint indicators',
    ),
    ColorPairing(
      id: 'PAL-07',
      screen: 'Global',
      element: 'Black Text on Code Badge Green',
      foreground: black87,
      background: codeBadgeGreen,
      context: 'Done pill or text on code badge green',
    ),

    // --- Screen 1: Dashboard ---
    ColorPairing(
      id: 'DSH-01',
      screen: 'Dashboard',
      element: 'Urgent Task Title on Urgent Card',
      foreground: figmaTextRed,
      background: urgentCardBg,
      context: 'lib/features/dashboard/dashboard_screen.dart:212 - red text on grey urgent card',
    ),
    ColorPairing(
      id: 'DSH-02',
      screen: 'Dashboard',
      element: 'Urgent Task Subtitle on Urgent Card',
      foreground: black54,
      background: urgentCardBg,
      context: 'lib/features/dashboard/dashboard_screen.dart:223 - black54 text on grey urgent card',
    ),
    ColorPairing(
      id: 'DSH-03',
      screen: 'Dashboard',
      element: 'Metric Card Value on Metric Card Light',
      foreground: black87,
      background: metricCardLight,
      isLargeText: true,
      context: 'lib/features/dashboard/dashboard_screen.dart - metric card number on white/grey card',
    ),
    ColorPairing(
      id: 'DSH-04',
      screen: 'Dashboard',
      element: 'Submit Button Label',
      foreground: white,
      background: const ColorEntry(0xFF2D2D2D, 'Submit Btn Dark (#2D2D2D)'),
      context: 'lib/features/dashboard/dashboard_screen.dart:240 - mark completed button',
    ),
    ColorPairing(
      id: 'DSH-05',
      screen: 'Dashboard',
      element: 'Active Learning Tag on Lavender Card',
      foreground: const ColorEntry(0xFF6B21A8, 'Deep Purple (#6B21A8)'),
      background: lavenderCard,
      context: 'lib/features/dashboard/dashboard_screen.dart:315 - category badge on lavender card',
    ),
    ColorPairing(
      id: 'DSH-06',
      screen: 'Dashboard',
      element: 'Light Purple Text on Dark Banner',
      foreground: lightPurplePill,
      background: darkBanner,
      context: 'Dashboard banner subtitle on dark purple',
    ),

    // --- Screen 2: Courses ---
    ColorPairing(
      id: 'CRS-01',
      screen: 'Courses',
      element: 'Course Card Header on Purple Card',
      foreground: white,
      background: purpleCard,
      isLargeText: true,
      context: 'lib/features/courses/courses_screen.dart - course name on purple card',
    ),
    ColorPairing(
      id: 'CRS-02',
      screen: 'Courses',
      element: 'Instructor Text on Purple Card',
      foreground: white70,
      background: purpleCard,
      context: 'lib/features/courses/courses_screen.dart - instructor name on purple card',
    ),
    ColorPairing(
      id: 'CRS-03',
      screen: 'Courses',
      element: 'Topic Pill Done on Green Topic',
      foreground: white,
      background: const ColorEntry(0xFF2E805F, 'Green Topic (#2E805F)'),
      context: 'lib/features/courses/courses_screen.dart - topic checklist item badge',
    ),
    ColorPairing(
      id: 'CRS-04',
      screen: 'Courses',
      element: 'Topic Pill Pending on Olive Topic',
      foreground: white,
      background: const ColorEntry(0xFF737C3E, 'Olive Topic (#737C3E)'),
      context: 'lib/features/courses/courses_screen.dart - pending topic pill',
    ),
    ColorPairing(
      id: 'CRS-05',
      screen: 'Courses',
      element: 'Black Text on Olive Topic',
      foreground: black87,
      background: const ColorEntry(0xFF737C3E, 'Olive Topic (#737C3E)'),
      context: 'Courses screen topic indicator',
    ),

    // --- Screen 3: Skills ---
    ColorPairing(
      id: 'SKL-01',
      screen: 'Skills',
      element: 'White Text on Forest Banner',
      foreground: white,
      background: forestBanner,
      isLargeText: true,
      context: 'lib/features/skills/skills_screen.dart:180 - skills header on forest green',
    ),
    ColorPairing(
      id: 'SKL-02',
      screen: 'Skills',
      element: 'Plus Button Text on Light Pink',
      foreground: maroonText,
      background: plusBtnBg,
      context: 'lib/features/skills/skills_screen.dart:210 - plus button icon on pink bg',
    ),
    ColorPairing(
      id: 'SKL-03',
      screen: 'Skills',
      element: 'White Text on Cyan/Sky Card',
      foreground: white,
      background: cyanCard,
      context: 'lib/features/skills/skills_screen.dart - skill card badge on #0284C7',
    ),
    ColorPairing(
      id: 'SKL-04',
      screen: 'Skills',
      element: 'White Text on Red Subtopic',
      foreground: white,
      background: const ColorEntry(0xFFDC2626, 'Red Subtopic (#DC2626)'),
      context: 'lib/features/skills/skills_screen.dart - incomplete skill badge',
    ),
    ColorPairing(
      id: 'SKL-05',
      screen: 'Skills',
      element: 'White Text on Green Subtopic',
      foreground: white,
      background: const ColorEntry(0xFF16A34A, 'Green Subtopic (#16A34A)'),
      context: 'lib/features/skills/skills_screen.dart - completed skill badge',
    ),

    // --- Screen 4: Projects ---
    ColorPairing(
      id: 'PRJ-01',
      screen: 'Projects',
      element: 'White Text on Dark Purple Banner',
      foreground: white,
      background: darkBanner,
      isLargeText: true,
      context: 'lib/features/projects/projects_screen.dart - banner title',
    ),
    ColorPairing(
      id: 'PRJ-02',
      screen: 'Projects',
      element: 'White Text on Orange Card',
      foreground: white,
      background: orangeCard,
      isLargeText: true,
      context: 'lib/features/projects/projects_screen.dart - project name on orange',
    ),
    ColorPairing(
      id: 'PRJ-03',
      screen: 'Projects',
      element: 'White Text on Pipeline Green',
      foreground: white,
      background: const ColorEntry(0xFF3F5A1F, 'Pipeline Green (#3F5A1F)'),
      context: 'lib/features/projects/projects_screen.dart - pipeline stepper node',
    ),
    ColorPairing(
      id: 'PRJ-04',
      screen: 'Projects',
      element: 'White Text on Sprint Purple',
      foreground: white,
      background: const ColorEntry(0xFF6B21A8, 'Sprint Purple (#6B21A8)'),
      context: 'lib/features/projects/projects_screen.dart - sprint item card',
    ),
    ColorPairing(
      id: 'PRJ-05',
      screen: 'Projects',
      element: 'White Text on Sprint Rust',
      foreground: white,
      background: const ColorEntry(0xFF9A3412, 'Sprint Rust (#9A3412)'),
      context: 'lib/features/projects/projects_screen.dart - sprint badge',
    ),

    // --- Screen 5: Workload & Tasks ---
    ColorPairing(
      id: 'WKL-01',
      screen: 'Workload',
      element: 'Urgent Badge Text on Red',
      foreground: white,
      background: const ColorEntry(0xFFC72836, 'Urgent Red (#C72836)'),
      context: 'lib/features/workload/workload_screen.dart - urgent priority badge',
    ),
    ColorPairing(
      id: 'WKL-02',
      screen: 'Workload',
      element: 'High Priority Text on Amber',
      foreground: white,
      background: const ColorEntry(0xFFD97706, 'High Amber (#D97706)'),
      context: 'lib/features/workload/workload_screen.dart - high priority badge',
    ),
    ColorPairing(
      id: 'WKL-03',
      screen: 'Workload',
      element: 'Black Text on High Amber',
      foreground: black87,
      background: const ColorEntry(0xFFD97706, 'High Amber (#D97706)'),
      context: 'Workload priority chip high text variant',
    ),
    ColorPairing(
      id: 'WKL-04',
      screen: 'Workload',
      element: 'State Pill Active Text on Crimson',
      foreground: white,
      background: crimsonAction,
      context: 'lib/features/workload/workload_screen.dart - selected state filter pill',
    ),
    ColorPairing(
      id: 'WKL-05',
      screen: 'Workload',
      element: 'State Pill Inactive Text on Card',
      foreground: black87,
      background: white,
      context: 'lib/features/workload/workload_screen.dart - unselected state filter pill',
    ),
    ColorPairing(
      id: 'WKL-06',
      screen: 'Workload',
      element: 'Task Title on Metric Card Light',
      foreground: black,
      background: metricCardLight,
      context: 'lib/features/workload/workload_screen.dart - task card title',
    ),
    ColorPairing(
      id: 'WKL-07',
      screen: 'Workload',
      element: 'Task Title on Dark Card',
      foreground: const ColorEntry(0xFFE6EDF3, 'Text Primary Dark (#E6EDF3)'),
      background: cardDark,
      context: 'lib/features/workload/workload_screen.dart - dark mode task card title',
    ),

    // --- Screen 6: Technical Notes ---
    ColorPairing(
      id: 'NTS-01',
      screen: 'Notes',
      element: 'Folder Badge Text on Dark Purple',
      foreground: lightPurplePill,
      background: darkBanner,
      context: 'lib/features/notes/notes_screen.dart - note folder badge',
    ),
    ColorPairing(
      id: 'NTS-02',
      screen: 'Notes',
      element: 'Code Tag Text on Dark Purple',
      foreground: white,
      background: darkCodeContainer,
      context: 'lib/features/notes/notes_screen.dart - CODE pill badge',
    ),
    ColorPairing(
      id: 'NTS-03',
      screen: 'Notes',
      element: 'Tag Chip Text on Grey Tag',
      foreground: black87,
      background: lightGreyBadge,
      context: 'lib/features/notes/notes_screen.dart - tag chip text',
    ),
    ColorPairing(
      id: 'NTS-04',
      screen: 'Notes',
      element: 'White Text on Grey Tag',
      foreground: white,
      background: lightGreyBadge,
      context: 'Notes tag chip when dark mode text leaks into light chip',
    ),
    ColorPairing(
      id: 'NTS-05',
      screen: 'Notes',
      element: 'Star Icon Inactive on Metric Card',
      foreground: const ColorEntry(0x73000000, 'Black45 (#73000000)'),
      background: metricCardLight,
      isUiComponent: true,
      context: 'lib/features/notes/notes_screen.dart - unstarred star icon',
    ),
    ColorPairing(
      id: 'NTS-06',
      screen: 'Notes (Markdown)',
      element: 'Inline Code Text on Code Bg',
      foreground: const ColorEntry(0xFFE11D48, 'Code Rose (#E11D48)'),
      background: const ColorEntry(0xFFF1F5F9, 'Code Light Bg (#F1F5F9)'),
      context: 'lib/features/notes/widgets/markdown_renderer.dart - inline code',
    ),
    ColorPairing(
      id: 'NTS-07',
      screen: 'Notes (Markdown)',
      element: 'Code Block Syntax Keyword on Dark Editor',
      foreground: const ColorEntry(0xFF93C5FD, 'Syntax Keyword (#93C5FD)'),
      background: const ColorEntry(0xFF1E1E2E, 'Editor Bg (#1E1E2E)'),
      context: 'lib/features/notes/widgets/markdown_renderer.dart - syntax keyword',
    ),

    // --- Screen 7: Auth / Login ---
    ColorPairing(
      id: 'ATH-01',
      screen: 'Auth',
      element: 'Field Label on Canvas Light',
      foreground: black,
      background: canvasLight,
      context: 'lib/features/auth/login_screen.dart - email & password labels',
    ),
    ColorPairing(
      id: 'ATH-02',
      screen: 'Auth',
      element: 'Hint Text on White Input Fill',
      foreground: const ColorEntry(0xFF757575, 'Hint Grey (#757575)'),
      background: white,
      context: 'lib/features/auth/login_screen.dart - text input field hint',
    ),
    ColorPairing(
      id: 'ATH-03',
      screen: 'Auth',
      element: 'Demo Account Banner Text',
      foreground: const ColorEntry(0xFF15803D, 'Green Text (#15803D)'),
      background: const ColorEntry(0xFFF0FDF4, 'Light Green Bg (#F0FDF4)'),
      context: 'lib/features/auth/login_screen.dart - demo info banner',
    ),
    ColorPairing(
      id: 'ATH-04',
      screen: 'Auth',
      element: 'Demo Mode Secondary Button Text',
      foreground: white,
      background: const ColorEntry(0xFF1F2937, 'Dark Button Bg (#1F2937)'),
      context: 'lib/features/auth/login_screen.dart - demo student button label',
    ),
    ColorPairing(
      id: 'ATH-05',
      screen: 'Auth',
      element: 'Create Account Link on Canvas',
      foreground: figmaBlue,
      background: canvasLight,
      context: 'lib/features/auth/login_screen.dart - create account link on canvas #D6BDBD',
    ),
  ];

  int totalTested = pairings.length;
  int passed = 0;
  int failed = 0;

  final failedList = <ColorPairing>[];

  print('| ID | Screen | Element | Foreground | Background | Ratio | Target | Status |');
  print('| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |');

  for (final pair in pairings) {
    final ratio = pair.contrastRatio;
    final target = pair.requiredRatio;
    final isPass = pair.passes;
    if (isPass) {
      passed++;
    } else {
      failed++;
      failedList.add(pair);
    }

    final ratioStr = '${ratio.toStringAsFixed(2)}:1';
    final targetStr = '${target.toStringAsFixed(1)}:1';
    final statusStr = isPass ? 'PASS' : '**FAIL**';

    print(
      '| ${pair.id} | ${pair.screen} | ${pair.element} | `${pair.foreground.name}` | `${pair.background.name}` | $ratioStr | $targetStr | $statusStr |',
    );
  }

  print('\n----------------------------------------------------------------');
  print('SUMMARY: $totalTested pairings audited | $passed PASSED | $failed FAILED');
  print('----------------------------------------------------------------\n');

  if (failedList.isNotEmpty) {
    print('=== CRITICAL & HIGH CONTRAST FAILURES ===');
    for (final f in failedList) {
      print(
        '  - [${f.id}] ${f.screen} > ${f.element}: ${f.contrastRatio.toStringAsFixed(2)}:1 (Requires ${f.requiredRatio.toStringAsFixed(1)}:1)\n'
        '    Context: ${f.context}',
      );
    }
  }

  // Generate markdown report snippet
  final reportFile = File('tool/contrast_results.md');
  final buffer = StringBuffer();
  buffer.writeln('### Palette & Pairing Contrast Matrix (WCAG 2.1 AA/AAA)\n');
  buffer.writeln('| ID | Screen | Element | Foreground | Background | Ratio | Target | Status |');
  buffer.writeln('| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |');
  for (final pair in pairings) {
    final ratioStr = '${pair.contrastRatio.toStringAsFixed(2)}:1';
    final targetStr = '${pair.requiredRatio.toStringAsFixed(1)}:1';
    final statusStr = pair.passes ? 'PASS' : '**FAIL**';
    buffer.writeln(
      '| ${pair.id} | ${pair.screen} | ${pair.element} | `${pair.foreground.name}` | `${pair.background.name}` | $ratioStr | $targetStr | $statusStr |',
    );
  }
  reportFile.writeAsStringSync(buffer.toString());
  print('\nMarkdown table exported to: tool/contrast_results.md');
}

