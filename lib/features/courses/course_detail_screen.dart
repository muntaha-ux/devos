import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_course_modal.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  void _showEditModal(BuildContext context, Course currentCourse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditCourseModal(course: currentCourse),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Course currentCourse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${currentCourse.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(coursesProvider.notifier).deleteCourse(currentCourse.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to courses list
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
    final currentCourse = courses.firstWhere(
      (c) => c.id == course.id,
      orElse: () => course,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCourse.code),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditModal(context, currentCourse),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRose),
            onPressed: () => _confirmDelete(context, ref, currentCourse),
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
                          label: currentCourse.code,
                          color: AppColors.primary,
                        ),
                        Text(
                          '${currentCourse.creditHours} Credit Hours',
                          style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentCourse.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondaryDark),
                        const SizedBox(width: 6),
                        Text(
                          currentCourse.instructor,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentCourse.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Course Syllabus Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${currentCourse.progressPercentage}%',
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
                      percent: currentCourse.topics.isEmpty ? 0 : currentCourse.progressPercentage / 100.0,
                      backgroundColor: AppColors.surfaceDark,
                      progressColor: AppColors.primary,
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Syllabus Topics (${currentCourse.topics.where((t) => t.isCompleted).length}/${currentCourse.topics.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...currentCourse.topics.map((topic) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    activeColor: AppColors.primary,
                    checkColor: Colors.black,
                    value: topic.isCompleted,
                    onChanged: (val) {
                      ref.read(coursesProvider.notifier).toggleTopic(currentCourse.id, topic.id);
                    },
                    title: Text(
                      topic.title,
                      style: TextStyle(
                        decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                        color: topic.isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
