import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_project_modal.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  void _showEditModal(BuildContext context, Project currentProject) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditProjectModal(project: currentProject),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project currentProject,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.cardBorder(ctx)),
        ),
        title: Text(
          'Delete Project',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(ctx),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${currentProject.title}"? All associated tasks and milestones will be removed.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary(ctx),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRose,
            ),
            onPressed: () {
              ref
                  .read(projectsProvider.notifier)
                  .deleteProject(currentProject.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppColors.isDark(context);
    final projects = ref.watch(projectsProvider);
    final currentProject = projects.firstWhere(
      (p) => p.id == project.id,
      orElse: () => project,
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentProject.title,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary(context),
              size: 20,
            ),
            onPressed: () => _showEditModal(context, currentProject),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.accentRose,
              size: 20,
            ),
            onPressed: () => _confirmDelete(context, ref, currentProject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2E1A11)
                    : AppColors.figmaOrangeCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFC2410C)
                      : const Color(0xFF333333),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentProject.status.toUpperCase().replaceAll(
                            '_',
                            ' ',
                          ),
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFFFEDD5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Started ${currentProject.startDate}',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFFE4D6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    currentProject.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentProject.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      currentProject.description,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (currentProject.githubUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.code_rounded,
                          color: Color(0xFFFFE4D6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentProject.githubUrl,
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFFFE4D6),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Completion',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFFE4D6),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${currentProject.progressPercentage}%',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(color: const Color(0xFF222222)),
                          FractionallySizedBox(
                            widthFactor:
                                currentProject.progressPercentage.clamp(
                                  0,
                                  100,
                                ) /
                                100.0,
                            child: Container(color: AppColors.figmaPink),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: currentProject.technologies.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tech,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Milestones Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project Milestones (${currentProject.milestones.where((m) => m.isCompleted).length}/${currentProject.milestones.length})',
                  style: GoogleFonts.inter(
                    color: isDark
                        ? const Color(0xFFF472B6)
                        : AppColors.figmaTextRed,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(
              color: isDark ? const Color(0xFF384358) : const Color(0xFFA69090),
              thickness: 1,
            ),
            const SizedBox(height: 12),

            if (currentProject.milestones.isNotEmpty) ...[
              ...currentProject.milestones.map((milestone) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(projectsProvider.notifier)
                          .toggleMilestone(currentProject.id, milestone.id);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: milestone.isCompleted
                            ? (isDark
                                  ? const Color(0xFF1E2822)
                                  : AppColors.figmaSprintSlate)
                            : (isDark
                                  ? const Color(0xFF1E2433)
                                  : AppColors.figmaSprintRust),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            milestone.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: milestone.isCompleted
                                ? const Color(0xFFA7F3D0)
                                : Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: milestone.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  milestone.targetDate.isNotEmpty
                                      ? 'Target: ${milestone.targetDate}'
                                      : 'Sprint Milestone',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
              }),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder(context)),
                ),
                child: Center(
                  child: Text(
                    'No milestones defined yet.\nTap edit in top bar to configure project deliverables.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
