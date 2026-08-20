import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/section_header.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final courses = ref.watch(coursesProvider);
    final skills = ref.watch(skillsProvider);
    final projects = ref.watch(projectsProvider);

    final avgCourseProgress = courses.isEmpty
        ? 0
        : (courses.fold<int>(0, (sum, c) => sum + c.progressPercentage) / courses.length).round();
    final avgSkillProgress = skills.isEmpty
        ? 0
        : (skills.fold<int>(0, (sum, s) => sum + s.progressPercentage) / skills.length).round();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Academic & Engineering Overview',
              subtitle: 'Performance metrics and completion rates',
            ),
            const SizedBox(height: 10),

            // Top Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  context,
                  title: 'Learning Streak',
                  value: '${profile.learningStreak} Days',
                  icon: Icons.local_fire_department,
                  color: AppColors.accentAmber,
                ),
                _buildMetricCard(
                  context,
                  title: 'Avg Course Progress',
                  value: '$avgCourseProgress%',
                  icon: Icons.school_outlined,
                  color: AppColors.primary,
                ),
                _buildMetricCard(
                  context,
                  title: 'Avg Skill Mastery',
                  value: '$avgSkillProgress%',
                  icon: Icons.code,
                  color: AppColors.secondary,
                ),
                _buildMetricCard(
                  context,
                  title: 'Active Projects',
                  value: '${projects.length}',
                  icon: Icons.rocket_launch_outlined,
                  color: AppColors.accentViolet,
                ),
              ],
            ),

            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Weekly Study & Development Hours',
              subtitle: 'Hours spent coding, reading, and attending lectures',
            ),
            const SizedBox(height: 12),

            // Weekly Learning Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 2,
                            getTitlesWidget: (val, meta) => Text(
                              '${val.toInt()}h',
                              style: const TextStyle(color: AppColors.textMutedDark, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 4.5, color: AppColors.primary, width: 14)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6.0, color: AppColors.primary, width: 14)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3.5, color: AppColors.primary, width: 14)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7.5, color: AppColors.secondary, width: 14)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 5.0, color: AppColors.primary, width: 14)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 8.0, color: AppColors.accentViolet, width: 14)]),
                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 6.5, color: AppColors.primary, width: 14)]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMutedDark,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
