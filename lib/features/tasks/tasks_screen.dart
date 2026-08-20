import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_task_modal.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isCompleted = task.status == TaskStatus.completed;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CheckboxListTile(
                    activeColor: AppColors.primary,
                    checkColor: Colors.black,
                    value: isCompleted,
                    onChanged: (val) {
                      ref.read(tasksProvider.notifier).toggleTaskStatus(task.id);
                    },
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isCompleted ? AppColors.textMutedDark : AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            BadgeChip(
                              label: task.priority.name.toUpperCase(),
                              color: _getPriorityColor(task.priority),
                            ),
                            const SizedBox(width: 6),
                            BadgeChip(
                              label: task.category,
                              color: AppColors.accentViolet,
                            ),
                            if (task.dueDate != null) ...[
                              const Spacer(),
                              Text(
                                DateFormat('MMM d').format(task.dueDate!),
                                style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTaskModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
