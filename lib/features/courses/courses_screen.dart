import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_course_modal.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  int _selectedCourseIndex = 0;

  void _showAddEditModal(BuildContext context, [Course? course]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditCourseModal(course: course),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);

    // Safeguard index
    if (_selectedCourseIndex >= courses.length && courses.isNotEmpty) {
      _selectedCourseIndex = 0;
    }

    final activeCourse = courses.isNotEmpty ? courses[_selectedCourseIndex] : null;

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title & Term
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Syllabus',
                        style: GoogleFonts.inter(
                          color: AppColors.textHeading(context),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Academic Term 2026',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaForestBanner,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => _showAddEditModal(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'Add Course',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Course Selector Pills (Multi-Course Support)
            if (courses.length > 1) ...[
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final c = courses[index];
                    final isSelected = index == _selectedCourseIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCourseIndex = index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.figmaPurpleCard : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              c.code,
                              style: GoogleFonts.jetBrainsMono(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Featured / Active Course Card
            if (activeCourse != null)
              InkWell(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => CourseDetailScreen(course: activeCourse),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: AppColors.figmaPurpleCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF333333),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Course Code & Test Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeCourse.code,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFD6BCFA),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                const Text('• ', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 10)),
                                Text(
                                  '${activeCourse.creditHours} Credits',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Course Title
                      Text(
                        activeCourse.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Instructor
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFFDDD6FE)),
                          const SizedBox(width: 6),
                          Text(
                            activeCourse.instructor.isNotEmpty ? activeCourse.instructor : 'Instructor Assigned',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFEDE9FE),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 80,
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 14),
                      // Progress Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Syllabus Completed',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFEDE9FE),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${activeCourse.progressPercentage}%',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 5,
                          child: Stack(
                            children: [
                              Container(color: const Color(0xFF222222)),
                              FractionallySizedBox(
                                widthFactor: activeCourse.progressPercentage.clamp(0, 100) / 100.0,
                                child: Container(color: AppColors.figmaPink),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder(context)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No Courses Enrolled',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add your university syllabus to track topics and exams.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
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
                Expanded(
                  child: Text(
                    'Topics Outline',
                    style: GoogleFonts.inter(
                      color: AppColors.figmaTextRed,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (activeCourse != null)
                  Text(
                    '${activeCourse.topics.where((t) => t.isCompleted).length}/${activeCourse.topics.length} Done',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(color: Color(0xFFA69090), thickness: 1),
            const SizedBox(height: 12),

            // Real dynamic topic checklist
            if (activeCourse != null && activeCourse.topics.isNotEmpty) ...[
              ...activeCourse.topics.asMap().entries.map((entry) {
                final index = entry.key;
                final topic = entry.value;
                final isAlt = index % 2 == 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      ref.read(coursesProvider.notifier).toggleTopic(activeCourse.id, topic.id);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: _buildTopicCard(
                      context: context,
                      title: topic.title,
                      isCompleted: topic.isCompleted,
                      backgroundColor: isAlt ? AppColors.figmaOliveTopic : AppColors.figmaGreenTopic,
                      borderColor: const Color(0xFF333333),
                    ),
                  ),
                );
              }),
            ] else if (activeCourse != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder(context)),
                ),
                child: Center(
                  child: Text(
                    'No topics outlined yet for ${activeCourse.code}.\nEdit course to add syllabus topics.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.textSecondary(context), fontSize: 13),
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

  Widget _buildTopicCard({
    required BuildContext context,
    required String title,
    required bool isCompleted,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? const Color(0xFFA7F3D0) : Colors.white70,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? '• COMPLETED' : '• IN PROGRESS',
                  style: GoogleFonts.jetBrainsMono(
                    color: isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFFEF08A),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
