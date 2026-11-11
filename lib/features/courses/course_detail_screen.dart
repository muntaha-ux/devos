import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_course_modal.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  void _showEditModal(BuildContext context, Course currentCourse) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditCourseModal(course: currentCourse),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Course currentCourse,
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
          'Delete Course',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(ctx),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${currentCourse.name}"? This action cannot be undone.',
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
              ref.read(coursesProvider.notifier).deleteCourse(currentCourse.id);
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
    final courses = ref.watch(coursesProvider);
    final currentCourse = courses.firstWhere(
      (c) => c.id == course.id,
      orElse: () => course,
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
          currentCourse.code,
          style: GoogleFonts.jetBrainsMono(
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
            onPressed: () => _showEditModal(context, currentCourse),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.accentRose,
              size: 20,
            ),
            onPressed: () => _confirmDelete(context, ref, currentCourse),
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
                    ? const Color(0xFF2D1B4E)
                    : AppColors.figmaPurpleCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF6B21A8)
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
                          currentCourse.code,
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFD6BCFA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${currentCourse.creditHours} Credit Hours',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    currentCourse.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Color(0xFFEDE9FE),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentCourse.instructor.isNotEmpty
                            ? currentCourse.instructor
                            : 'Faculty Instructor',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFEDE9FE),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (currentCourse.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      currentCourse.description,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Syllabus Completion',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFEDE9FE),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${currentCourse.progressPercentage}%',
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
                                currentCourse.progressPercentage.clamp(0, 100) /
                                100.0,
                            child: Container(color: AppColors.figmaPink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Topics Outline Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Syllabus Topics (${currentCourse.topics.where((t) => t.isCompleted).length}/${currentCourse.topics.length})',
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

            if (currentCourse.topics.isNotEmpty) ...[
              ...currentCourse.topics.asMap().entries.map((entry) {
                final topic = entry.value;
                final index = entry.key;
                final isAlt = index % 2 == 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(coursesProvider.notifier)
                          .toggleTopic(currentCourse.id, topic.id);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isAlt
                                  ? const Color(0xFF1E2822)
                                  : const Color(0xFF26271A))
                            : (isAlt
                                  ? AppColors.figmaOliveTopic
                                  : AppColors.figmaGreenTopic),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? (isAlt
                                    ? const Color(0xFF3F6212)
                                    : const Color(0xFF065F46))
                              : const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            topic.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: topic.isCompleted
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
                                  topic.title,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: topic.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  topic.isCompleted
                                      ? 'COMPLETED'
                                      : 'IN PROGRESS',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: topic.isCompleted
                                        ? const Color(0xFFA7F3D0)
                                        : const Color(0xFFFEF08A),
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
                    'No syllabus topics added yet.\nTap edit in top bar to configure syllabus modules.',
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
