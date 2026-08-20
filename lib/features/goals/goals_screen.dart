import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final completedMilestones = goal.milestones.where((m) => m.isCompleted).length;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BadgeChip(
                        label: goal.category,
                        color: AppColors.accentViolet,
                      ),
                      BadgeChip(
                        label: '${goal.progressPercentage}% Complete',
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: goal.progressPercentage / 100.0,
                    backgroundColor: AppColors.surfaceDark,
                    progressColor: AppColors.secondary,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Roadmap Milestones ($completedMilestones/${goal.milestones.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ...goal.milestones.map((m) => CheckboxListTile(
                        dense: true,
                        activeColor: AppColors.secondary,
                        checkColor: Colors.black,
                        contentPadding: EdgeInsets.zero,
                        value: m.isCompleted,
                        onChanged: (val) {
                          ref.read(goalsProvider.notifier).toggleGoalMilestone(goal.id, m.id);
                        },
                        title: Text(
                          m.title,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                            color: m.isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
