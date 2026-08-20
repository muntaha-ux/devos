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

  void _showAddEditModal(BuildContext context, [DevTask? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTaskModal(task: task),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DevTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          activeColor: AppColors.primary,
                          checkColor: Colors.black,
                          value: isCompleted,
                          onChanged: (val) {
                            ref.read(tasksProvider.notifier).toggleTaskStatus(task.id);
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                                ),
                              ),
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
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMutedDark),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showAddEditModal(context, task);
                            } else if (val == 'delete') {
                              _confirmDelete(context, ref, task);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: AppColors.accentRose),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.accentRose)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
