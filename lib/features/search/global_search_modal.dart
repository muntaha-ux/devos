import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/semantic_search_service.dart';
import '../../providers/app_providers.dart';

/// Opens the global workspace semantic search dialog.
Future<void> showGlobalSearch(
  BuildContext context, {
  required void Function(int tabIndex) onNavigateToTab,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => GlobalSearchDialog(onNavigateToTab: onNavigateToTab),
  );
}

class GlobalSearchDialog extends ConsumerStatefulWidget {
  final void Function(int tabIndex) onNavigateToTab;

  const GlobalSearchDialog({super.key, required this.onNavigateToTab});

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  SearchResultType? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setPrompt(String prompt) {
    setState(() {
      _query = prompt;
      _searchController.text = prompt;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: prompt.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final notes = ref.watch(notesProvider);
    final courses = ref.watch(coursesProvider);
    final projects = ref.watch(projectsProvider);
    final skills = ref.watch(skillsProvider);

    final activeConcepts = SemanticSearchService.detectConcepts(_query);

    final results = SemanticSearchService.searchAll(
      query: _query,
      tasks: tasks,
      notes: notes,
      courses: courses,
      projects: projects,
      skills: skills,
      filterType: _selectedCategory,
    );

    // Counts for filter pills
    final allResults = SemanticSearchService.searchAll(
      query: _query,
      tasks: tasks,
      notes: notes,
      courses: courses,
      projects: projects,
      skills: skills,
    );

    final taskCount = allResults.where((r) => r.type == SearchResultType.task).length;
    final noteCount = allResults.where((r) => r.type == SearchResultType.note).length;
    final courseCount = allResults.where((r) => r.type == SearchResultType.course).length;
    final projectCount = allResults.where((r) => r.type == SearchResultType.project).length;
    final skillCount = allResults.where((r) => r.type == SearchResultType.skill).length;

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 720 ? 680.0 : screenWidth * 0.94;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333333), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===================== HEADER =====================
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.brandDarkBanner,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.figmaCodeBadge,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.saved_search_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'SEMANTIC SEARCH',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Semantics(
                          label: 'Close Search',
                          button: true,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white12,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search Input Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF333333), width: 1.2),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        onChanged: (val) => setState(() => _query = val),
                        decoration: InputDecoration(
                          hintText: 'Search tasks, notes, courses, code, stack...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF757575),
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF352554), size: 22),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.black54, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),

                    // Semantic Intent Indicator Badge
                    if (activeConcepts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: activeConcepts.map((concept) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8F0030),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Concept: ${concept.label}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // ===================== CATEGORY FILTER ROW =====================
              Container(
                color: const Color(0xFFEFE8E8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All (${allResults.length})', null, _selectedCategory == null),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Tasks ($taskCount)', SearchResultType.task, _selectedCategory == SearchResultType.task),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Notes ($noteCount)', SearchResultType.note, _selectedCategory == SearchResultType.note),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Courses ($courseCount)', SearchResultType.course, _selectedCategory == SearchResultType.course),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Projects ($projectCount)', SearchResultType.project, _selectedCategory == SearchResultType.project),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Skills ($skillCount)', SearchResultType.skill, _selectedCategory == SearchResultType.skill),
                    ],
                  ),
                ),
              ),

              // ===================== BODY CONTENT =====================
              Expanded(
                child: _query.trim().isEmpty
                    ? _buildEmptyStatePrompt()
                    : results.isEmpty
                        ? _buildNoResultsState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: results.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              return _buildResultCard(item);
                            },
                          ),
              ),

              // ===================== FOOTER =====================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5D5D5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _query.isEmpty
                            ? 'Type a query or tap a suggested prompt'
                            : '${results.length} result${results.length == 1 ? '' : 's'} found • Ranked by semantic relevance',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF4A4A4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: AppColors.brandDarkBanner,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'ESC / Close',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, SearchResultType? type, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedCategory = type),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandDarkBanner : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStatePrompt() {
    final prompts = [
      ('🔥 Urgent & High Priority', 'urgent', 'Find high-priority tasks, deadlines, and exams'),
      ('🗄️ Database & PostgreSQL', 'database', 'Query tables, schema notes, and Supabase modules'),
      ('📱 Flutter & Mobile UI', 'flutter', 'Frontend widgets, responsive layouts, and state'),
      ('🌳 DSA & Binary Trees', 'dsa', 'Algorithms, tree traversals, and dynamic programming'),
      ('🚀 Active Software Projects', 'project', 'Engineering repositories and tech stacks'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF8F0030)),
              const SizedBox(width: 6),
              Text(
                'SUGGESTED SEMANTIC PROMPTS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: const Color(0xFF352554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...prompts.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFD6BDBD), width: 1),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Text(
                      p.$1.split(' ').first,
                      style: const TextStyle(fontSize: 18),
                    ),
                    title: Text(
                      p.$1,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      p.$3,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Colors.black45,
                    ),
                    onTap: () => _setPrompt(p.$2),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF8F0030)),
            const SizedBox(height: 12),
            Text(
              'No semantic matches found for "$_query"',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'Try querying by engineering concept, course code, tech stack, or status ("urgent", "database", "flutter", "tree").',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(SearchResultItem item) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFD0C0C0), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.pop(context);
          widget.onNavigateToTab(item.targetTabIndex);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${item.type.displayName}: ${item.title}'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.brandDarkBanner,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Badge + Semantic Reason + Tab Target
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.type.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.type.icon, size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          item.type.displayName.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.semanticReason != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFD8B4FE), width: 0.8),
                        ),
                        child: Text(
                          item.semanticReason!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B21A8),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'Jump to Tab →',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E56FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),

              // Subtitle
              Text(
                item.subtitle,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: const Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Snippet / Preview
              if (item.snippet.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
