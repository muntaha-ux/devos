import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_project_modal.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  int _selectedProjectIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;

  void _showAddEditModal(BuildContext context, [Project? project]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditProjectModal(project: project),
    );
  }

  int _calculateActiveStep(int progress) {
    if (progress < 20) return 0; // Spec
    if (progress < 40) return 1; // Design
    if (progress < 70) return 2; // Dev
    if (progress < 95) return 3; // QA
    return 4; // Ship
  }

  @override
  Widget build(BuildContext context) {
    final allProjects = ref.watch(projectsProvider);
    final allTasks = ref.watch(tasksProvider);

    // Filter projects by search query
    final projects = _searchQuery.isEmpty
        ? allProjects
        : allProjects.where((p) {
            final query = _searchQuery.toLowerCase();
            return p.title.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                p.technologies.any((t) => t.toLowerCase().contains(query));
          }).toList();

    if (_selectedProjectIndex >= projects.length && projects.isNotEmpty) {
      _selectedProjectIndex = 0;
    }

    final activeProject = projects.isNotEmpty
        ? projects[_selectedProjectIndex]
        : null;

    // Real project tasks from tasksProvider
    final projectTasks = allTasks.where(
      (t) =>
          t.category == 'project' ||
          (activeProject != null &&
              (t.relatedProjectId == activeProject.id ||
                  t.relatedProjectName == activeProject.title)),
    );

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Dark Banner with Interactive Search
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.figmaDarkPurpleBanner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF333333),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF201633),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.rocket_launch_outlined,
                            color: Color(0xFFE9D5FF),
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Software Projects',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'REPOS & SPRINT PIPELINES',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFD6BCFA),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE: ${allProjects.length}',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Toggle Search Filter',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) _searchQuery = '';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            child: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isSearching) ...[
                    const SizedBox(height: 10),
                    TextField(
                      autofocus: true,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by title, stack, or tech...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.black38,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Multi-Project Selector Pills
            if (projects.length > 1) ...[
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final p = projects[index];
                    final isSelected = index == _selectedProjectIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () =>
                            setState(() => _selectedProjectIndex = index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.figmaOrangeCard
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.title,
                              style: GoogleFonts.jetBrainsMono(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Featured Project Hero Card
            if (activeProject != null) ...[
              InkWell(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          ProjectDetailScreen(project: activeProject),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: AppColors.figmaOrangeCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF333333),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              activeProject.title,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.alt_route_rounded,
                            color: Color(0xFFFFE4D6),
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.code_rounded,
                            color: Color(0xFFFFE4D6),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              activeProject.githubUrl.isNotEmpty
                                  ? 'Github: ${activeProject.githubUrl.replaceAll("https://github.com/", "")}'
                                  : 'Repository Linked',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFFFE4D6),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dynamic Pipeline Stepper
                      Builder(
                        builder: (context) {
                          final currentStep = _calculateActiveStep(
                            activeProject.progressPercentage,
                          );
                          final steps = ['Spec', 'Design', 'Dev', 'QA', 'Ship'];

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.figmaPipelineGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    for (int i = 0; i < steps.length; i++) ...[
                                      _buildStepNode(
                                        isFilled: i <= currentStep,
                                        isGlowing: i == currentStep,
                                      ),
                                      if (i < steps.length - 1)
                                        Expanded(
                                          child: Container(
                                            height: 2,
                                            color: i < currentStep
                                                ? Colors.white70
                                                : const Color(0xFF223015),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (int i = 0; i < steps.length; i++)
                                      Text(
                                        steps[i],
                                        style: GoogleFonts.jetBrainsMono(
                                          color: i == currentStep
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 10,
                                          fontWeight: i == currentStep
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Technologies Wrap
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children:
                            (activeProject.technologies.isNotEmpty
                                    ? activeProject.technologies
                                    : ['#Flutter', '#Dart', '#PostgreSQL'])
                                .map(
                                  (tech) => _buildTagBadge(
                                    tech.startsWith('#') ? tech : '#$tech',
                                    const Color(0xFF6B21A8),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder(context)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.rocket_launch_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Projects Found',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a software project to track repositories, milestones, and deployments.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            // Section: Sprint Workload / Active Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Milestones',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9E1724),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${projectTasks.length} Tasks',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(
              color: Color(0xFFA69090),
              thickness: 1,
            ),
            const SizedBox(height: 12),

            // Dynamic Sprint Tasks
            if (projectTasks.isNotEmpty) ...[
              ...projectTasks.map((task) {
                final isDone = task.status == TaskStatus.completed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(tasksProvider.notifier)
                          .toggleTaskStatus(task.id);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: _buildSprintCard(
                      context: context,
                      tag: isDone
                          ? '✓ Done'
                          : (task.priority == TaskPriority.urgent
                                ? 'Urgent'
                                : (task.priority == TaskPriority.high
                                      ? 'High'
                                      : 'Normal')),
                      tagBg: isDone
                          ? const Color(0xFF065F46)
                          : (task.priority == TaskPriority.urgent
                                ? const Color(0xFF991B1B)
                                : const Color(0xFF854D0E)),
                      tagColor: isDone ? const Color(0xFFA7F3D0) : Colors.white,
                      title: task.title,
                      repo: task.relatedProjectName != null
                          ? 'project: ${task.relatedProjectName}'
                          : 'general engineering',
                      repoColor: const Color(0xFFEDE9FE),
                      backgroundColor: isDone
                          ? AppColors.figmaSprintSlate
                          : AppColors.figmaSprintPurple,
                      isCrossed: isDone,
                    ),
                  ),
                );
              }),
            ] else ...[
              // Milestones from active project if available
              if (activeProject != null &&
                  activeProject.milestones.isNotEmpty) ...[
                ...activeProject.milestones.map((m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(projectsProvider.notifier)
                            .toggleMilestone(activeProject.id, m.id);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: _buildSprintCard(
                        context: context,
                        tag: m.isCompleted ? '✓ Done' : 'Milestone',
                        tagBg: m.isCompleted
                            ? const Color(0xFF065F46)
                            : const Color(0xFF1E3A8A),
                        tagColor: Colors.white,
                        title: m.title,
                        repo: 'Target: ${m.targetDate}',
                        repoColor: Colors.white70,
                        backgroundColor: m.isCompleted
                            ? AppColors.figmaSprintSlate
                            : AppColors.figmaSprintRust,
                        isCrossed: m.isCompleted,
                      ),
                    ),
                  );
                }),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder(context)),
                  ),
                  child: Center(
                    child: Text(
                      'No ongoing tasks or milestones for this project.\nCreate a task or add milestones to track progress.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 16),

            // Add Project Button
            Center(
              child: TextButton.icon(
                onPressed: () => _showAddEditModal(context),
                icon: Icon(Icons.add, color: AppColors.textHeading(context)),
                label: Text(
                  'Add New Project',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textHeading(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNode({required bool isFilled, required bool isGlowing}) {
    return Container(
      width: isGlowing ? 16 : 12,
      height: isGlowing ? 16 : 12,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFFFCE7F3) : const Color(0xFF202A16),
        shape: BoxShape.circle,
        border: isGlowing ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildTagBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSprintCard({
    required BuildContext context,
    required String tag,
    required Color tagBg,
    required Color tagColor,
    required String title,
    required String repo,
    required Color repoColor,
    required Color backgroundColor,
    bool isCrossed = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.jetBrainsMono(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isCrossed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isCrossed ? const Color(0xFFA7F3D0) : Colors.white60,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              color: isCrossed
                  ? Colors.white.withValues(alpha: 0.65)
                  : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              decoration: isCrossed ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            repo,
            style: GoogleFonts.jetBrainsMono(
              color: repoColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
