import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

enum AnalyticsPeriod {
  weekly,
  monthly,
}

/// Comprehensive Productivity & Analytics Screen for DevOS.
/// Features:
/// 1. Daily Coding Activity (GitHub-style contribution matrix & active days tracker)
/// 2. Learning Streak Tracking (Current/best streak, shield, and daily checkpoints)
/// 3. Weekly & Monthly Statistics across all workspace domains (Tasks, Courses, Projects, Skills, Notes)
/// 4. Productivity Visualizations (Focus hours bar chart, category distribution bar, velocity index)
class AnalyticsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackToDashboard;
  final void Function(int tabIndex)? onNavigateToTab;

  const AnalyticsScreen({
    super.key,
    this.onBackToDashboard,
    this.onNavigateToTab,
  });

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.weekly;
  int _selectedDayIndex = 6; // Sunday by default (today)
  int _selectedMatrixDayOffset = 0; // Today in matrix

  // Local daily streak checkpoints state (interactive checkboxes for today)
  bool _taskGoalCompleted = true;
  bool _courseGoalCompleted = true;
  bool _codeGoalCompleted = true;
  bool _focusGoalCompleted = false;

  // Local logged sessions to demonstrate dynamic reactivity
  int _extraLoggedCommits = 0;
  double _extraLoggedHours = 0.0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final tasks = ref.watch(tasksProvider);
    final courses = ref.watch(coursesProvider);
    final projects = ref.watch(projectsProvider);
    final skills = ref.watch(skillsProvider);
    final notes = ref.watch(notesProvider);

    final isWeekly = _selectedPeriod == AnalyticsPeriod.weekly;

    // Derived workspace data
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final totalTasks = tasks.length;
    final taskRate = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;

    final totalCourseTopics = courses.fold<int>(0, (acc, c) => acc + c.topics.length);
    final completedCourseTopics = courses.fold<int>(
      0,
      (acc, c) => acc + c.topics.where((t) => t.isCompleted).length,
    );

    final totalProjectMilestones = projects.fold<int>(0, (acc, p) => acc + p.milestones.length);
    final completedMilestones = projects.fold<int>(
      0,
      (acc, p) => acc + p.milestones.where((m) => m.isCompleted).length,
    );

    final totalSkillTopics = skills.fold<int>(0, (acc, s) => acc + s.topics.length);
    final completedSkillTopics = skills.fold<int>(
      0,
      (acc, s) => acc + s.topics.where((t) => t.isCompleted).length,
    );

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.onBackToDashboard != null || Navigator.of(context).canPop())
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textPrimaryLight,
                        tooltip: 'Back to Dashboard',
                        onPressed: () {
                          if (widget.onBackToDashboard != null) {
                            widget.onBackToDashboard!();
                          } else if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    Text(
                      'Productivity & Analytics',
                      style: GoogleFonts.inter(
                        color: AppColors.textHeading(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.figmaCodeBadge.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.figmaCodeBadge, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 14, color: AppColors.figmaCodeBadge),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE METRICS',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.figmaCodeBadge,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Period Selector Toggle (Weekly vs Monthly)
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // ================= FEATURE 2: LEARNING STREAK TRACKING =================
            _buildStreakTrackingCard(profile.learningStreak),
            const SizedBox(height: 16),

            // ================= FEATURE 1: DAILY CODING ACTIVITY =================
            _buildCodingActivityHeatmapCard(),
            const SizedBox(height: 16),

            // ================= FEATURE 4: PRODUCTIVITY VISUALIZATION =================
            _buildProductivityVisualizationCard(isWeekly),
            const SizedBox(height: 16),

            // ================= FEATURE 3: WEEKLY & MONTHLY STATISTICS =================
            _buildDomainStatisticsMatrix(
              isWeekly: isWeekly,
              completedTasks: completedTasks,
              totalTasks: totalTasks,
              taskRate: taskRate,
              completedTopics: completedCourseTopics,
              totalTopics: totalCourseTopics,
              completedMilestones: completedMilestones,
              totalMilestones: totalProjectMilestones,
              completedSkills: completedSkillTopics,
              totalSkills: totalSkillTopics,
              totalNotes: notes.length,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===================== PERIOD SELECTOR =====================
  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.figmaMetricCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(
              period: AnalyticsPeriod.weekly,
              label: 'WEEKLY VIEW (LAST 7 DAYS)',
              icon: Icons.calendar_view_week_rounded,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildPeriodButton(
              period: AnalyticsPeriod.monthly,
              label: 'MONTHLY VIEW (LAST 30 DAYS)',
              icon: Icons.calendar_month_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required AnalyticsPeriod period,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandDarkBanner : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FEATURE 2: LEARNING STREAK TRACKING =====================
  Widget _buildStreakTrackingCard(int streakDays) {
    final effectiveStreak = streakDays;
    const longestStreak = 28;
    final streakShieldActive = effectiveStreak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandDarkBanner,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222222), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentRose.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🔥', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LEARNING STREAK TRACKING',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFF3C7D4),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '$effectiveStreak Days Active Streak',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Shield badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: streakShieldActive
                      ? AppColors.figmaCodeBadge.withValues(alpha: 0.25)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: streakShieldActive ? AppColors.figmaCodeBadge : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      streakShieldActive ? Icons.shield_rounded : Icons.shield_outlined,
                      color: streakShieldActive ? const Color(0xFF4ADE80) : Colors.white60,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streakShieldActive ? 'SHIELD READY' : 'NO SHIELD',
                      style: GoogleFonts.jetBrainsMono(
                        color: streakShieldActive ? const Color(0xFF4ADE80) : Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak Milestone Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Milestone: 30 Days Target',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Best: $longestStreak Days',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFFACC15),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: (effectiveStreak / 30.0).clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFACC15)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daily Checkpoints (Today's Streak Requirements)
          Text(
            'TODAY\'S STREAK CHECKPOINTS',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFF3C7D4),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          _buildStreakCheckpointItem(
            title: 'Complete 1 Workspace Task',
            subtitle: 'Verified through task runner',
            isCompleted: _taskGoalCompleted,
            onToggle: () => setState(() => _taskGoalCompleted = !_taskGoalCompleted),
          ),
          _buildStreakCheckpointItem(
            title: 'Review 1 Course Syllabus Topic',
            subtitle: 'Distributed Systems & Robotics',
            isCompleted: _courseGoalCompleted,
            onToggle: () => setState(() => _courseGoalCompleted = !_courseGoalCompleted),
          ),
          _buildStreakCheckpointItem(
            title: 'Push 1 Git Commit / Code Session',
            subtitle: 'Main repository or feature branch',
            isCompleted: _codeGoalCompleted,
            onToggle: () => setState(() => _codeGoalCompleted = !_codeGoalCompleted),
          ),
          _buildStreakCheckpointItem(
            title: 'Log 45m+ Deep Focus Time',
            subtitle: 'Interactive focus timer logged',
            isCompleted: _focusGoalCompleted,
            onToggle: () => setState(() => _focusGoalCompleted = !_focusGoalCompleted),
          ),
          const SizedBox(height: 14),

          // Increment Streak & Check-in Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaBottomNav,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref.read(profileProvider.notifier).incrementStreak();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Streak Check-In Recorded! Current streak: ${effectiveStreak + 1} Days!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.figmaCodeBadge,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_fire_department_rounded, size: 18),
                  label: Text(
                    'CLAIM TODAY\'S STREAK CHECK-IN (+1 DAY)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCheckpointItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCompleted ? AppColors.figmaCodeBadge.withValues(alpha: 0.6) : Colors.white12,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isCompleted ? const Color(0xFF4ADE80) : Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          color: isCompleted ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF4ADE80),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== FEATURE 1: DAILY CODING ACTIVITY =====================
  Widget _buildCodingActivityHeatmapCard() {
    // Generate 12 weeks of historical commit intensity data
    final matrixData = _generateHeatmapMatrix();
    final totalContributions = 168 + _extraLoggedCommits;
    final activeDays = 26 + (_extraLoggedCommits > 0 ? 1 : 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.figmaMetricCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY CODING ACTIVITY',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.figmaTextRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalContributions Contributions',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Active on $activeDays of the last 30 days',
                    style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showLogActivityDialog,
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.black),
                label: Text(
                  'Log Activity',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // GitHub-style contribution matrix grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Labels + Matrix Rows
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day of week labels (M, W, F)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDayLabel('Mon'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Tue'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Wed'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Thu'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Fri'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Sat'),
                          const SizedBox(height: 2),
                          _buildDayLabel('Sun'),
                        ],
                      ),
                    ),
                    // 12 Weeks Columns
                    Row(
                      children: List.generate(matrixData.length, (colIdx) {
                        final weekDays = matrixData[colIdx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Column(
                            children: List.generate(weekDays.length, (rowIdx) {
                              final count = weekDays[rowIdx];
                              final isSelected = colIdx == (matrixData.length - 1) &&
                                  rowIdx == (7 - 1 - _selectedMatrixDayOffset);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedMatrixDayOffset = 6 - rowIdx;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(3),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: _getHeatmapColor(count),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.black.withValues(alpha: 0.1),
                                        width: isSelected ? 1.5 : 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Heatmap Legend and Selected Day Inspector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day details inspector
              Expanded(
                child: Text(
                  _getSelectedDayDetail(),
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Intensity legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Less', style: GoogleFonts.inter(fontSize: 10, color: Colors.black54)),
                  const SizedBox(width: 4),
                  _buildLegendBox(const Color(0xFFE2D5D5)),
                  _buildLegendBox(const Color(0xFF86EFAC)),
                  _buildLegendBox(const Color(0xFF22C55E)),
                  _buildLegendBox(AppColors.figmaCodeBadge),
                  const SizedBox(width: 4),
                  Text('More', style: GoogleFonts.inter(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: 14,
      child: Text(
        label[0],
        style: GoogleFonts.jetBrainsMono(
          color: Colors.black54,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
    );
  }

  Color _getHeatmapColor(int count) {
    if (count == 0) return const Color(0xFFE2D5D5);
    if (count <= 2) return const Color(0xFF86EFAC);
    if (count <= 4) return const Color(0xFF22C55E);
    return AppColors.figmaCodeBadge;
  }

  List<List<int>> _generateHeatmapMatrix() {
    // 12 weeks of deterministic realistic commit patterns
    final basePatterns = [
      [1, 0, 3, 2, 5, 0, 0],
      [2, 4, 1, 3, 4, 1, 0],
      [0, 2, 4, 5, 2, 0, 1],
      [3, 5, 2, 4, 6, 2, 0],
      [1, 3, 0, 2, 3, 0, 0],
      [4, 2, 5, 3, 4, 1, 1],
      [2, 4, 3, 6, 5, 2, 0],
      [3, 1, 4, 2, 3, 0, 1],
      [5, 4, 6, 3, 7, 3, 2],
      [2, 3, 1, 4, 2, 0, 0],
      [4, 5, 3, 6, 4, 2, 1],
      [3, 6, 4, 5, 7 + _extraLoggedCommits, 2, 3], // Current week
    ];
    return basePatterns;
  }

  String _getSelectedDayDetail() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedDayName = days[6 - (_selectedMatrixDayOffset % 7)];
    final commits = 4 + (_selectedMatrixDayOffset == 0 ? _extraLoggedCommits : 2);
    final hours = (commits * 0.8 + 1.2).toStringAsFixed(1);
    return '$selectedDayName: $commits commits • ${hours}h deep focus';
  }

  void _showLogActivityDialog() {
    final commitController = TextEditingController(text: '3');
    final hoursController = TextEditingController(text: '2.5');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: Text(
          'Log Coding & Focus Session',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add completed commits and focus hours for today:',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Commits pushed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.commit_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hoursController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Focus Hours',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaCodeBadge,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final commits = int.tryParse(commitController.text) ?? 2;
              final hours = double.tryParse(hoursController.text) ?? 1.5;
              setState(() {
                _extraLoggedCommits += commits;
                _extraLoggedHours += hours;
                _codeGoalCompleted = true;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged $commits commits & ${hours}h focus time!'),
                  backgroundColor: AppColors.figmaCodeBadge,
                ),
              );
            },
            child: const Text('Save Session'),
          ),
        ],
      ),
    );
  }

  // ===================== FEATURE 4: PRODUCTIVITY VISUALIZATION =====================
  Widget _buildProductivityVisualizationCard(bool isWeekly) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.figmaLavenderCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRODUCTIVITY VISUALIZATION',
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.figmaTextRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black26),
                ),
                child: Text(
                  isWeekly ? 'WEEKLY VELOCITY' : 'MONTHLY VELOCITY',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Daily Focus Hours & Engineering Velocity',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Daily Focus Hours Bar Chart (Mon through Sun)
          _buildFocusHoursBarChart(),
          const SizedBox(height: 20),

          // Category Focus Distribution Progress Breakdown
          Text(
            'DOMAIN FOCUS DISTRIBUTION',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.figmaTextRed,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategoryDistributionBar(),
          const SizedBox(height: 12),
          _buildCategoryDistributionLegend(),
          const SizedBox(height: 16),

          // Productivity Velocity Index
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF333333), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.figmaCodeBadge.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.figmaCodeBadge),
                  ),
                  child: Center(
                    child: Text(
                      '94',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.figmaCodeBadge,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Optimal Velocity Score',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Top 5% Consistency',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.figmaCodeBadge,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'High code output in Systems Architecture and Flutter mobile engineering.',
                        style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusHoursBarChart() {
    final dailyHours = [4.5, 6.0, 3.8, 5.2, 7.0 + _extraLoggedHours, 4.0, 5.5];
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const maxBarHeight = 128.0;
    const maxHour = 8.0;
    const baselineHour = 4.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        children: [
          // Target baseline guideline indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Target: 4.0h / day',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.figmaCodeBadge,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Target Met',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bars container
          SizedBox(
            height: maxBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final hours = dailyHours[index];
                final normalizedHeight = ((hours / maxHour) * 65.0).clamp(10.0, 65.0);
                final isSelected = index == _selectedDayIndex;
                final meetsTarget = hours >= baselineHour;

                return InkWell(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Hours label above bar
                        Text(
                          '${hours.toStringAsFixed(1)}h',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 26,
                          height: normalizedHeight,
                          decoration: BoxDecoration(
                            color: meetsTarget
                                ? (isSelected ? AppColors.figmaCodeBadge : const Color(0xFF22C55E))
                                : (isSelected ? AppColors.figmaBlue : const Color(0xFF93C5FD)),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Day Name
                        Text(
                          dayNames[index],
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? Colors.black : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionBar() {
    // Proportions: Courses 35%, Projects 30%, Skills 20%, Notes 15%
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(flex: 35, child: Container(color: AppColors.figmaPurpleCard)),
            Expanded(flex: 30, child: Container(color: AppColors.figmaOrangeCard)),
            Expanded(flex: 20, child: Container(color: AppColors.figmaCodeBadge)),
            Expanded(flex: 15, child: Container(color: AppColors.figmaCyanCard)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _buildLegendChip('Courses (35%)', AppColors.figmaPurpleCard),
        _buildLegendChip('Projects (30%)', AppColors.figmaOrangeCard),
        _buildLegendChip('Skills & DSA (20%)', AppColors.figmaCodeBadge),
        _buildLegendChip('Notes & Docs (15%)', AppColors.figmaCyanCard),
      ],
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ===================== FEATURE 3: WEEKLY & MONTHLY STATISTICS =====================
  Widget _buildDomainStatisticsMatrix({
    required bool isWeekly,
    required int completedTasks,
    required int totalTasks,
    required int taskRate,
    required int completedTopics,
    required int totalTopics,
    required int completedMilestones,
    required int totalMilestones,
    required int completedSkills,
    required int totalSkills,
    required int totalNotes,
  }) {
    // Time multiplier based on period
    final multiplier = isWeekly ? 1.0 : 4.2;
    final totalHours = ((28.5 + _extraLoggedHours) * (isWeekly ? 1.0 : 3.8)).toStringAsFixed(1);
    final commitsCount = ((34 + _extraLoggedCommits) * (isWeekly ? 1 : 4)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isWeekly ? 'WEEKLY STATISTICAL MATRIX' : 'MONTHLY STATISTICAL MATRIX',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.figmaTextRed,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '$totalHours Focus Hours Total',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.brandDarkBanner,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Domain 1: Workload & Tasks
        _buildDomainStatCard(
          domainTitle: 'Workload & Engineering Tasks',
          badgeText: '$completedTasks / $totalTasks TASKS ($taskRate%)',
          badgeColor: AppColors.figmaCodeBadge,
          primaryMetric: '$completedTasks Completed',
          primaryLabel: 'Active: ${totalTasks - completedTasks} Remaining',
          secondaryMetric: isWeekly ? '1.2d' : '1.4d',
          secondaryLabel: 'Avg Turnaround',
          icon: Icons.assignment_turned_in_rounded,
          onTap: () => widget.onNavigateToTab?.call(2),
        ),
        const SizedBox(height: 10),

        // Domain 2: Courses & Academics
        _buildDomainStatCard(
          domainTitle: 'Courses & Academic Syllabus',
          badgeText: '$completedTopics / $totalTopics TOPICS',
          badgeColor: AppColors.figmaPurpleCard,
          primaryMetric: isWeekly ? '14.5 hrs' : '58.0 hrs',
          primaryLabel: 'Study Time Logged',
          secondaryMetric: '+${(12 * multiplier).round()}%',
          secondaryLabel: 'Syllabus Velocity',
          icon: Icons.school_outlined,
          onTap: () => widget.onNavigateToTab?.call(1),
        ),
        const SizedBox(height: 10),

        // Domain 3: Software Projects & Commits
        _buildDomainStatCard(
          domainTitle: 'Software Projects & Git Repositories',
          badgeText: '$completedMilestones / $totalMilestones MILESTONES',
          badgeColor: AppColors.figmaOrangeCard,
          primaryMetric: '$commitsCount Commits',
          primaryLabel: 'Pushed to Repos',
          secondaryMetric: isWeekly ? '3 PRs' : '11 PRs',
          secondaryLabel: 'Code Reviews',
          icon: Icons.rocket_launch_outlined,
          onTap: () => widget.onNavigateToTab?.call(4),
        ),
        const SizedBox(height: 10),

        // Domain 4: Skill Competency
        _buildDomainStatCard(
          domainTitle: 'Skill Competencies & Engineering Modules',
          badgeText: '$completedSkills / $totalSkills SUBTOPICS',
          badgeColor: AppColors.figmaGreenSubtopic,
          primaryMetric: '${(completedSkills * 1.5).round()} Mastery Pts',
          primaryLabel: 'DSA & Systems',
          secondaryMetric: isWeekly ? '+4 Skills' : '+14 Skills',
          secondaryLabel: 'Growth Momentum',
          icon: Icons.terminal_rounded,
          onTap: () => widget.onNavigateToTab?.call(3),
        ),
        const SizedBox(height: 10),

        // Domain 5: Notes & Knowledge Base
        _buildDomainStatCard(
          domainTitle: 'Notes & Technical Research Docs',
          badgeText: '$totalNotes ARTICLES',
          badgeColor: AppColors.figmaCyanCard,
          primaryMetric: '${totalNotes * (isWeekly ? 2 : 7)} Refs',
          primaryLabel: 'Knowledge Cross-Refs',
          secondaryMetric: isWeekly ? '3 New' : '12 New',
          secondaryLabel: 'Knowledge Articles',
          icon: Icons.menu_book_rounded,
          onTap: () => widget.onNavigateToTab?.call(5),
        ),
      ],
    );
  }

  Widget _buildDomainStatCard({
    required String domainTitle,
    required String badgeText,
    required Color badgeColor,
    required String primaryMetric,
    required String primaryLabel,
    required String secondaryMetric,
    required String secondaryLabel,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.figmaMetricCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      domainTitle,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: badgeColor, width: 1),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.jetBrainsMono(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryMetric,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        primaryLabel,
                        style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        secondaryMetric,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.figmaTextRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        secondaryLabel,
                        style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
