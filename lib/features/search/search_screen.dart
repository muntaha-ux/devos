import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();
    final courses = ref.watch(coursesProvider);
    final skills = ref.watch(skillsProvider);
    final projects = ref.watch(projectsProvider);
    final notes = ref.watch(notesProvider);
    final research = ref.watch(researchProvider);

    // Search Filtering
    final matchedCourses = query.isEmpty
        ? []
        : courses.where((c) => c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query)).toList();

    final matchedSkills = query.isEmpty
        ? []
        : skills.where((s) => s.name.toLowerCase().contains(query) || s.category.toLowerCase().contains(query)).toList();

    final matchedProjects = query.isEmpty
        ? []
        : projects.where((p) => p.title.toLowerCase().contains(query) || p.description.toLowerCase().contains(query)).toList();

    final matchedNotes = query.isEmpty
        ? []
        : notes.where((n) => n.title.toLowerCase().contains(query) || n.content.toLowerCase().contains(query)).toList();

    final matchedResearch = query.isEmpty
        ? []
        : research.where((r) => r.title.toLowerCase().contains(query) || r.topic.toLowerCase().contains(query)).toList();

    final totalResults = matchedCourses.length +
        matchedSkills.length +
        matchedProjects.length +
        matchedNotes.length +
        matchedResearch.length;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: const InputDecoration(
            hintText: 'Global Search (e.g. Binary Tree, Flutter, ROS)...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textMutedDark),
          ),
          onChanged: (val) {
            ref.read(searchQueryProvider.notifier).state = val;
          },
        ),
      ),
      body: query.isEmpty
          ? const Center(
              child: Text(
                'Type above to search across Courses, Skills, Projects, Notes & Research Papers',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMutedDark),
              ),
            )
          : totalResults == 0
              ? Center(
                  child: Text(
                    'No matching records found for "$query"',
                    style: const TextStyle(color: AppColors.textMutedDark),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (matchedCourses.isNotEmpty) ...[
                      const Text('COURSES', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 6),
                      ...matchedCourses.map((c) => Card(
                            child: ListTile(
                              title: Text(c.name),
                              subtitle: Text(c.code),
                              trailing: BadgeChip(label: 'Course', color: AppColors.primary),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (matchedSkills.isNotEmpty) ...[
                      const Text('SKILLS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      const SizedBox(height: 6),
                      ...matchedSkills.map((s) => Card(
                            child: ListTile(
                              title: Text(s.name),
                              subtitle: Text(s.category),
                              trailing: BadgeChip(label: 'Skill', color: AppColors.secondary),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (matchedProjects.isNotEmpty) ...[
                      const Text('PROJECTS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentViolet)),
                      const SizedBox(height: 6),
                      ...matchedProjects.map((p) => Card(
                            child: ListTile(
                              title: Text(p.title),
                              subtitle: Text(p.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: BadgeChip(label: 'Project', color: AppColors.accentViolet),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (matchedNotes.isNotEmpty) ...[
                      const Text('NOTES & KNOWLEDGE BASE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentAmber)),
                      const SizedBox(height: 6),
                      ...matchedNotes.map((n) => Card(
                            child: ListTile(
                              title: Text(n.title),
                              subtitle: Text(n.category),
                              trailing: BadgeChip(label: 'Note', color: AppColors.accentAmber),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (matchedResearch.isNotEmpty) ...[
                      const Text('RESEARCH PAPERS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentRose)),
                      const SizedBox(height: 6),
                      ...matchedResearch.map((r) => Card(
                            child: ListTile(
                              title: Text(r.title),
                              subtitle: Text(r.authors),
                              trailing: BadgeChip(label: 'Research', color: AppColors.accentRose),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}
