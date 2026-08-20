import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_course_modal.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  void _showAddEditModal(BuildContext context, [Course? course]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditCourseModal(course: course),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(coursesProvider.notifier).deleteCourse(course.id);
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
    final courses = ref.watch(coursesProvider);

    return Scaffold(
      body: courses.isEmpty
          ? const Center(child: Text('No courses added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final completedTopics = course.topics.where((t) => t.isCompleted).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(course: course),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BadgeChip(
                                label: course.code,
                                color: AppColors.primary,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${course.creditHours} Credits',
                                    style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMutedDark),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showAddEditModal(context, course);
                                      } else if (val == 'delete') {
                                        _confirmDelete(context, ref, course);
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
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            course.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Instructor: ${course.instructor}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedTopics / ${course.topics.length} Topics Completed',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                              ),
                              Text(
                                '${course.progressPercentage}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearPercentIndicator(
                            lineHeight: 6.0,
                            percent: course.topics.isEmpty ? 0 : course.progressPercentage / 100.0,
                            backgroundColor: AppColors.surfaceDark,
                            progressColor: AppColors.primary,
                            barRadius: const Radius.circular(4),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
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
