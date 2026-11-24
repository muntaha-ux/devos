import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/semantic_search_service.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_task_modal.dart';

enum TaskStateFilter { all, pending, inProgress, completed }

enum TaskCategoryFilter { all, course, project, other }

class WorkloadScreen extends ConsumerStatefulWidget {
  const WorkloadScreen({super.key});

  @override
  ConsumerState<WorkloadScreen> createState() => _WorkloadScreenState();
}

class _WorkloadScreenState extends ConsumerState<WorkloadScreen> {
  final TextEditingController _searchController = TextEditingController();

  TaskStateFilter _stateFilter = TaskStateFilter.all;
  TaskCategoryFilter _categoryFilter = TaskCategoryFilter.all;
  TaskPriority? _priorityFilter;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditModal([DevTask? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTaskModal(task: task),
    );
  }

  void _confirmDelete(BuildContext context, DevTask task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.figmaMetricCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        title: Text(
          'Delete Task',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task removed from Workload.'),
                  backgroundColor: AppColors.accentRose,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaTextRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksFromProvider = ref.watch(tasksProvider);
    final tasks = tasksFromProvider.isEmpty
        ? _buildFallbackTasks()
        : tasksFromProvider;

    // Compute Metrics for Workload Summary
    final totalTasks = tasks.length;
    final urgentTasks = tasks
        .where(
          (t) =>
              t.priority == TaskPriority.urgent &&
              t.status != TaskStatus.completed,
        )
        .length;
    final courseTasks = tasks.where((t) => t.category == 'course').length;
    final projectTasks = tasks.where((t) => t.category == 'project').length;
    final completedTasks = tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final completionRate = totalTasks > 0
        ? ((completedTasks / totalTasks) * 100).round()
        : 0;
    final activeTasks = tasks
        .where((t) => t.status != TaskStatus.completed)
        .length;

    // Filter Tasks by state, category, and priority
    final baseFilteredTasks = tasks.where((task) {
      // State Filter
      switch (_stateFilter) {
        case TaskStateFilter.pending:
          if (task.status != TaskStatus.pending) return false;
          break;
        case TaskStateFilter.inProgress:
          if (task.status != TaskStatus.inProgress) return false;
          break;
        case TaskStateFilter.completed:
          if (task.status != TaskStatus.completed) return false;
          break;
        case TaskStateFilter.all:
          break;
      }

      // Category Filter
      switch (_categoryFilter) {
        case TaskCategoryFilter.course:
          if (task.category != 'course') return false;
          break;
        case TaskCategoryFilter.project:
          if (task.category != 'project') return false;
          break;
        case TaskCategoryFilter.other:
          if (task.category == 'course' || task.category == 'project') {
            return false;
          }
          break;
        case TaskCategoryFilter.all:
          break;
      }

      // Priority Filter
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }

      return true;
    }).toList();

    // Apply Domain-Aware Semantic Search Engine
    final filteredTasks = _searchQuery.isEmpty
        ? baseFilteredTasks
        : SemanticSearchService.filterTasks(baseFilteredTasks, _searchQuery);

    return Container(
      color: AppColors.background(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditModal(),
          backgroundColor: AppColors.figmaBottomNav,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_task_rounded),
          label: Text(
            'NEW TASK',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 12,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Dark Purple Banner (Projects Style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.figmaDarkPurpleBanner,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => InkWell(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF201633),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workload & Tasks',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ACADEMIC COURSES & SOFTWARE SPRINT BOARD',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFD6BCFA),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '• $activeTasks ACTIVE',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Workload Overview 2x2 Matrix with Green Code Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Urgent Deadlines',
                              value: '$urgentTasks Tasks',
                              valueColor: AppColors.figmaTextRed,
                              onTap: () {
                                setState(() {
                                  _priorityFilter = TaskPriority.urgent;
                                  _stateFilter = TaskStateFilter.pending;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Course Workload',
                              value: '$courseTasks Items',
                              valueColor: const Color(0xFF2E805F),
                              onTap: () {
                                setState(() {
                                  _categoryFilter = TaskCategoryFilter.course;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Project Issues',
                              value: '$projectTasks Repos',
                              valueColor: const Color(0xFF812DF2),
                              onTap: () {
                                setState(() {
                                  _categoryFilter = TaskCategoryFilter.project;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Sprint Progress',
                              value: '$completionRate% Done',
                              valueColor: AppColors.figmaCodeBadge,
                              onTap: () {
                                setState(() {
                                  _stateFilter = TaskStateFilter.completed;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Green floating </> badge (Dashboard signature)
                  Positioned(
                    bottom: -10,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.figmaCodeBadge,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '</>',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search tasks, courses, or projects...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF757575),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF333333),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
              ),
              const SizedBox(height: 14),

              // State Filter Tabs (All, Pending, In Progress, Completed)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatePill(
                      label: 'All',
                      count: totalTasks,
                      filter: TaskStateFilter.all,
                    ),
                    const SizedBox(width: 8),
                    _buildStatePill(
                      label: 'To Do',
                      count: tasks
                          .where((t) => t.status == TaskStatus.pending)
                          .length,
                      filter: TaskStateFilter.pending,
                    ),
                    const SizedBox(width: 8),
                    _buildStatePill(
                      label: 'In Progress',
                      count: tasks
                          .where((t) => t.status == TaskStatus.inProgress)
                          .length,
                      filter: TaskStateFilter.inProgress,
                    ),
                    const SizedBox(width: 8),
                    _buildStatePill(
                      label: 'Done',
                      count: completedTasks,
                      filter: TaskStateFilter.completed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Category & Priority Filters Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryFilterChip(
                      label: 'All Categories',
                      filter: TaskCategoryFilter.all,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryFilterChip(
                      label: 'Academic Courses',
                      filter: TaskCategoryFilter.course,
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryFilterChip(
                      label: 'Software Projects',
                      filter: TaskCategoryFilter.project,
                      icon: Icons.alt_route_rounded,
                    ),
                    const SizedBox(width: 6),
                    _buildCategoryFilterChip(
                      label: 'Skills / Other',
                      filter: TaskCategoryFilter.other,
                      icon: Icons.code_rounded,
                    ),
                    const SizedBox(width: 12),
                    // Priority Filter Pill
                    _buildPriorityFilterChip(),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tasks Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Categorized Tasks (${filteredTasks.length})',
                      style: GoogleFonts.inter(
                        color: AppColors.figmaTextRed,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_stateFilter != TaskStateFilter.all ||
                      _categoryFilter != TaskCategoryFilter.all ||
                      _priorityFilter != null ||
                      _searchQuery.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _stateFilter = TaskStateFilter.all;
                          _categoryFilter = TaskCategoryFilter.all;
                          _priorityFilter = null;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Text(
                        'Reset Filters',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.figmaBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Task List or Empty State
              if (filteredTasks.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTasks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color valueColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.figmaMetricCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF333333),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatePill({
    required String label,
    required int count,
    required TaskStateFilter filter,
  }) {
    final isSelected = _stateFilter == filter;
    return InkWell(
      onTap: () => setState(() => _stateFilter = filter),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaBottomNav : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.figmaBottomNav
                : const Color(0xFF333333),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required TaskCategoryFilter filter,
    IconData? icon,
  }) {
    final isSelected = _categoryFilter == filter;
    return InkWell(
      onTap: () => setState(() => _categoryFilter = filter),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaCardDark : Colors.white70,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.figmaCardDark : const Color(0xFF777777),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityFilterChip() {
    return PopupMenuButton<TaskPriority?>(
      onSelected: (p) => setState(() => _priorityFilter = p),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: null,
          child: Text(
            'All Priorities',
            style: GoogleFonts.jetBrainsMono(fontSize: 12),
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.urgent,
          child: Text(
            'Urgent Only',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.figmaTextRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.high,
          child: Text(
            'High Priority',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFFD97706),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.medium,
          child: Text(
            'Medium Priority',
            style: GoogleFonts.jetBrainsMono(
              color: AppColors.figmaBlue,
              fontSize: 12,
            ),
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.low,
          child: Text(
            'Low Priority',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF059669),
              fontSize: 12,
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _priorityFilter != null
              ? AppColors.figmaCardDark
              : Colors.white70,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _priorityFilter != null
                ? AppColors.figmaCardDark
                : const Color(0xFF777777),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 13,
              color: _priorityFilter != null ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              _priorityFilter != null
                  ? _priorityFilter!.name.toUpperCase()
                  : 'Priority',
              style: GoogleFonts.jetBrainsMono(
                color: _priorityFilter != null ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: _priorityFilter != null
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: _priorityFilter != null ? Colors.white : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(DevTask task) {
    final isDone = task.status == TaskStatus.completed;
    final isUrgent = task.priority == TaskPriority.urgent;

    Color priorityColor;
    String priorityText;
    IconData priorityIcon;

    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = AppColors.figmaTextRed;
        priorityText = 'URGENT';
        priorityIcon = Icons.priority_high_rounded;
        break;
      case TaskPriority.high:
        priorityColor = const Color(0xFFD97706);
        priorityText = 'HIGH';
        priorityIcon = Icons.arrow_upward_rounded;
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.figmaBlue;
        priorityText = 'MEDIUM';
        priorityIcon = Icons.remove_rounded;
        break;
      case TaskPriority.low:
        priorityColor = const Color(0xFF059669);
        priorityText = 'LOW';
        priorityIcon = Icons.arrow_downward_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isUrgent && !isDone
            ? AppColors.figmaUrgentCard
            : AppColors.figmaMetricCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent && !isDone
              ? const Color(0xFFC72836)
              : const Color(0xFF333333),
          width: isUrgent && !isDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Priority Badge, Status Pill, Due Date
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Priority Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(priorityIcon, size: 12, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      priorityText,
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // State Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.figmaCodeBadge
                      : (task.status == TaskStatus.inProgress
                            ? AppColors.figmaPurpleCard
                            : Colors.white),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isDone
                      ? 'DONE'
                      : (task.status == TaskStatus.inProgress
                            ? 'IN PROGRESS'
                            : 'TO DO'),
                  style: GoogleFonts.jetBrainsMono(
                    color: isDone || task.status == TaskStatus.inProgress
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Due Date indicator
              if (task.dueDate != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 270),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: isUrgent && !isDone
                            ? AppColors.figmaTextRed
                            : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _formatDueText(task.dueDate!),
                          style: GoogleFonts.jetBrainsMono(
                            color: isUrgent && !isDone
                                ? AppColors.figmaTextRed
                                : Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            task.title,
            style: GoogleFonts.inter(
              color: isDone ? Colors.black45 : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),

          // Description (if present)
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              style: GoogleFonts.inter(
                color: isDone ? Colors.black38 : Colors.black87,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),

          // Direct Course or Project Linkage Badge
          if (task.relatedCourseName != null &&
              task.relatedCourseName!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E805F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFF2E805F),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 14,
                    color: Color(0xFF1B5E20),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Course: ${task.relatedCourseName}',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF1B5E20),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else if (task.relatedProjectName != null &&
              task.relatedProjectName!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF672EC9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFF672EC9),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.alt_route_rounded,
                    size: 14,
                    color: Color(0xFF4A148C),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Project: ${task.relatedProjectName}',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF4A148C),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFD1D5DB), thickness: 0.8),
          const SizedBox(height: 6),

          // Action Row: Toggle Status, Edit, Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Toggle Done/Pending Button
              Flexible(
                child: InkWell(
                  onTap: () {
                    if (ref.read(tasksProvider).isEmpty) {
                      final fallbacks = _buildFallbackTasks();
                      for (final t in fallbacks) {
                        ref.read(tasksProvider.notifier).addTask(t);
                      }
                    }
                    ref.read(tasksProvider.notifier).toggleTaskStatus(task.id);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.white : AppColors.figmaCodeBadge,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone
                              ? Icons.replay_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 15,
                          color: isDone ? Colors.black87 : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            isDone ? 'Reopen' : 'Mark Done',
                            style: GoogleFonts.jetBrainsMono(
                              color: isDone ? Colors.black87 : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Edit and Delete Buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.black87,
                    ),
                    tooltip: 'Edit Task',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => _showAddEditModal(task),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.figmaTextRed,
                    ),
                    tooltip: 'Delete Task',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => _confirmDelete(context, task),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.figmaMetricCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.figmaBackground,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF333333), width: 1),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 36,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No matching workload tasks',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your state filters, category filters, or search terms.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddEditModal(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaBottomNav,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Text(
              '+ CREATE FIRST TASK',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueText(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      if (difference.inHours.abs() < 24) {
        return 'Overdue by ${difference.inHours.abs()}h';
      }
      return 'Overdue by ${difference.inDays.abs()}d';
    }

    if (difference.inHours < 24) {
      return 'Due in ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays}d';
    }

    return 'Due: ${date.month}/${date.day}';
  }

  List<DevTask> _buildFallbackTasks() {
    return [
      DevTask(
        id: 'task-fallback-1',
        title: 'Distributed Consensus: Raft Log Replication Lab',
        description: 'Implement election timer jitter, appendEntries RPC, and committed entry verification.',
        priority: TaskPriority.urgent,
        status: TaskStatus.inProgress,
        category: 'course',
        relatedCourseId: 'course-2',
        relatedCourseName: 'CSE 4105: Distributed Systems',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      DevTask(
        id: 'task-fallback-2',
        title: 'Dynamic Programming: 0/1 Knapsack & Subset Sum',
        description: 'Complete problem set 4 on LeetCode / Codeforces and write complexity analysis.',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        category: 'course',
        relatedCourseId: 'course-1',
        relatedCourseName: 'CSE 2201: Data Structures',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      DevTask(
        id: 'task-fallback-3',
        title: 'DevOS: Wire Workload & Task System with Riverpod State',
        description: 'Ensure filter pills (Urgent, High, Medium, Done) update reactive state smoothly.',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        category: 'project',
        relatedProjectId: 'proj-1',
        relatedProjectName: 'DevOS Core Platform',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DevTask(
        id: 'task-fallback-4',
        title: 'Design Obsidian Dark Mode Color Tokens & WCAG Contrast',
        description: 'Audit all screen cards, metric containers, and text styles against WCAG AAA standards.',
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        category: 'project',
        relatedProjectId: 'proj-1',
        relatedProjectName: 'DevOS Core Platform',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DevTask(
        id: 'task-fallback-5',
        title: 'Review Raft Consensus Whitepaper by Ongaro & Ousterhout',
        description: 'Annotate Sections 5.1 through 5.4 in Technical Notes and link to research module.',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: 'course',
        relatedCourseId: 'course-2',
        relatedCourseName: 'CSE 4105: Distributed Systems',
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ];
  }
}
