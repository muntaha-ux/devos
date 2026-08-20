import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_project_modal.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  void _showEditModal(BuildContext context, Project currentProject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditProjectModal(project: currentProject),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Project currentProject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${currentProject.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(currentProject.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to projects list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final currentProject = projects.firstWhere(
      (p) => p.id == project.id,
      orElse: () => project,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentProject.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditModal(context, currentProject),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRose),
            onPressed: () => _confirmDelete(context, ref, currentProject),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BadgeChip(
                          label: currentProject.status.toUpperCase().replaceAll('_', ' '),
                          color: currentProject.progressPercentage == 100
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                        Text(
                          'Started ${currentProject.startDate}',
                          style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentProject.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentProject.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Project Completion',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${currentProject.progressPercentage}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: currentProject.milestones.isEmpty ? 0 : currentProject.progressPercentage / 100.0,
                      backgroundColor: AppColors.surfaceDark,
                      progressColor: AppColors.primary,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tech Stack',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: currentProject.technologies
                          .map((tech) => BadgeChip(
                                label: tech,
                                color: AppColors.accentViolet,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Project Milestones (${currentProject.milestones.where((m) => m.isCompleted).length}/${currentProject.milestones.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...currentProject.milestones.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    activeColor: AppColors.primary,
                    checkColor: Colors.black,
                    value: m.isCompleted,
                    onChanged: (val) {
                      ref.read(projectsProvider.notifier).toggleMilestone(currentProject.id, m.id);
                    },
                    title: Text(
                      m.title,
                      style: TextStyle(
                        decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                        color: m.isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Target Date: ${m.targetDate}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
