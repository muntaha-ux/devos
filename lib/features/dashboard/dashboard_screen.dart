import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  final void Function(int) onNavigateToTab;

  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppColors.isDark(context);
    final tasks = ref.watch(tasksProvider);
    final projects = ref.watch(projectsProvider);
    final courses = ref.watch(coursesProvider);
    final skills = ref.watch(skillsProvider);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final activeTasksCount = tasks.where((t) => t.status != TaskStatus.completed).length;

    // Calculate dynamic Learning Pulse from actual course and skill completions
    final allProgress = [
      ...courses.map((c) => c.progressPercentage),
      ...skills.map((s) => s.progressPercentage),
    ];
    final learningPulse = allProgress.isNotEmpty
        ? (allProgress.reduce((a, b) => a + b) / allProgress.length).round()
        : 0;

    // Estimated focused study time
    final hoursToday = (completedTasks * 1.25 + 1.0).toStringAsFixed(1);

    // Urgent task selection
    final urgentTask = tasks.where((t) => t.priority == TaskPriority.urgent && t.status != TaskStatus.completed).firstOrNull ??
        tasks.where((t) => t.status != TaskStatus.completed).firstOrNull;

    final featuredProject = projects.firstOrNull;

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgent Deadline Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2433) : AppColors.figmaUrgentCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.accentRose.withValues(alpha: 0.6) : const Color(0xFFB8B8B8),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.accentRose.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentRose,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            urgentTask?.priority == TaskPriority.urgent ? 'URGENT DEADLINE' : 'TOP PRIORITY TASK',
                            style: GoogleFonts.jetBrainsMono(
                              color: isDark ? const Color(0xFFF87171) : AppColors.figmaTextRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      if (urgentTask != null && urgentTask.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black45 : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Due in ${urgentTask.dueDate!.difference(DateTime.now()).inHours.abs()}h',
                            style: GoogleFonts.jetBrainsMono(
                              color: isDark ? const Color(0xFFF472B6) : const Color(0xFFE11D48),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    urgentTask?.title ?? 'All current tasks completed!',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (urgentTask != null && urgentTask.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      urgentTask.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (urgentTask != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await ref.read(tasksProvider.notifier).toggleTaskStatus(urgentTask.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Task "${urgentTask.title}" marked as completed!'),
                              backgroundColor: AppColors.figmaCodeBadge,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        'Mark Completed',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? Colors.white30 : Colors.black26),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => onNavigateToTab(2),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        'Create New Task',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Metrics Grid with Green Code Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Tasks Done',
                            value: '$completedTasks/$totalTasks',
                            onTap: () => onNavigateToTab(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Learning Pulse',
                            value: '$learningPulse%',
                            onTap: () => onNavigateToTab(3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Active Tasks',
                            value: '$activeTasksCount',
                            onTap: () => onNavigateToTab(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            label: 'Hours Today',
                            value: '$hoursToday Hours',
                            onTap: () => onNavigateToTab(0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Green floating </> badge at the bottom-right corner
                Positioned(
                  bottom: -10,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.figmaCodeBadge,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '</>',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Current Learning
            Text(
              'Current Learning Project',
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFFF472B6) : AppColors.figmaTextRed,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Current Learning Card
            InkWell(
              onTap: () => onNavigateToTab(4), // Projects tab
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B2E) : AppColors.figmaLavenderCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF382F54) : const Color(0xFF333333),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            featuredProject?.title ?? 'DevOS Mobile & Architecture',
                            style: GoogleFonts.inter(
                              color: isDark ? const Color(0xFFE9D5FF) : AppColors.figmaTextRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${featuredProject != null ? featuredProject.progressPercentage : 43}%',
                          style: GoogleFonts.jetBrainsMono(
                            color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7A0C16),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      featuredProject != null
                          ? 'STATUS: ${featuredProject.status.toUpperCase().replaceAll('_', ' ')}'
                          : 'STAGE: Software & Architecture QA',
                      style: GoogleFonts.jetBrainsMono(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: (featuredProject != null && featuredProject.technologies.isNotEmpty
                              ? featuredProject.technologies
                              : ['Flutter', 'Riverpod', 'Supabase'])
                          .map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF28233C) : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isDark ? const Color(0xFF581C87) : const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.jetBrainsMono(
                              color: isDark ? const Color(0xFFE9D5FF) : Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Adaptive progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 5,
                        child: Stack(
                          children: [
                            Container(color: isDark ? const Color(0xFF28233C) : const Color(0xFF222222)),
                            FractionallySizedBox(
                              widthFactor: ((featuredProject != null ? featuredProject.progressPercentage : 43).clamp(0, 100)) / 100.0,
                              child: Container(color: AppColors.figmaPink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : AppColors.figmaMetricCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFF333333),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isDark ? const Color(0xFFF87171) : AppColors.figmaTextRed,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
