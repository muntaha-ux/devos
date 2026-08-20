import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/task_model.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/badge_chip.dart';
import '../../widgets/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigateToTab;

  const DashboardScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final courses = ref.watch(coursesProvider);
    final skills = ref.watch(skillsProvider);
    final projects = ref.watch(projectsProvider);
    final tasks = ref.watch(tasksProvider);

    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pendingTasks = tasks.length - completedTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Profile & Streak
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      profile.fullName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${profile.fullName}!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.major} • ${profile.academicYear}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StreakBadge(streakDays: profile.learningStreak),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Today's Workload Metrics Grid
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 20),
                            BadgeChip(
                              label: '$completedTasks done',
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$pendingTasks Pending Tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Today\'s Workload',
                          style: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.rocket_launch_outlined, color: AppColors.primary, size: 20),
                            BadgeChip(
                              label: '${projects.length} Active',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${courses.length} Courses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enrolled Term 6',
                          style: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Action Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.accentViolet.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learn → Practice → Build → Research',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Keep up your 12-day streak! Check off topics or finish tasks today.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Projects Section
          SectionHeader(
            title: 'Active Projects',
            subtitle: 'Software development & hardware initiatives',
            trailing: TextButton(
              onPressed: () => onNavigateToTab(3), // Navigate to Projects tab
              child: const Text('View All'),
            ),
          ),
          ...projects.map((proj) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              proj.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          BadgeChip(
                            label: '${proj.progressPercentage}%',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        proj.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      LinearPercentIndicator(
                        lineHeight: 6.0,
                        percent: proj.progressPercentage / 100.0,
                        backgroundColor: AppColors.surfaceDark,
                        progressColor: AppColors.primary,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: proj.technologies
                            .map((tech) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.cardBorderDark),
                                  ),
                                  child: Text(
                                    tech,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),

          // Technical Skill Progress Section
          SectionHeader(
            title: 'Skill Matrix',
            subtitle: 'Real-time topic mastery tracker',
            trailing: TextButton(
              onPressed: () => onNavigateToTab(2), // Skills tab
              child: const Text('View All'),
            ),
          ),
          ...skills.map((skill) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: LinearPercentIndicator(
                      lineHeight: 6.0,
                      percent: skill.progressPercentage / 100.0,
                      backgroundColor: AppColors.surfaceDark,
                      progressColor: AppColors.secondary,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  trailing: Text(
                    '${skill.progressPercentage}%',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
