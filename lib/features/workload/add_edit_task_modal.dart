import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

class AddEditTaskModal extends ConsumerStatefulWidget {
  final DevTask? task;

  const AddEditTaskModal({super.key, this.task});

  @override
  ConsumerState<AddEditTaskModal> createState() => _AddEditTaskModalState();
}

class _AddEditTaskModalState extends ConsumerState<AddEditTaskModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _customLinkController;

  late String _category;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;

  String? _selectedCourseId;
  String? _selectedCourseName;
  String? _selectedProjectId;
  String? _selectedProjectName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _customLinkController = TextEditingController();

    _category = t?.category ?? 'course';
    _priority = t?.priority ?? TaskPriority.urgent;
    _status = t?.status ?? TaskStatus.pending;
    _dueDate = t?.dueDate ?? DateTime.now().add(const Duration(hours: 12));

    _selectedCourseId = t?.relatedCourseId;
    _selectedCourseName = t?.relatedCourseName;
    _selectedProjectId = t?.relatedProjectId;
    _selectedProjectName = t?.relatedProjectName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.figmaBottomNav,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.figmaBottomNav,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _dueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    } else {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String? finalCourseName = _selectedCourseName;
    String? finalProjectName = _selectedProjectName;

    if (_category == 'course' && _customLinkController.text.trim().isNotEmpty) {
      finalCourseName = _customLinkController.text.trim();
    } else if (_category == 'project' &&
        _customLinkController.text.trim().isNotEmpty) {
      finalProjectName = _customLinkController.text.trim();
    }

    final taskToSave = DevTask(
      id: widget.task?.id ?? 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _category,
      priority: _priority,
      status: _status,
      dueDate: _dueDate,
      relatedCourseId: _category == 'course' ? _selectedCourseId : null,
      relatedCourseName: _category == 'course' ? finalCourseName : null,
      relatedProjectId: _category == 'project' ? _selectedProjectId : null,
      relatedProjectName: _category == 'project' ? finalProjectName : null,
    );

    try {
      if (widget.task == null) {
        await ref.read(tasksProvider.notifier).addTask(taskToSave);
      } else {
        await ref.read(tasksProvider.notifier).updateTask(taskToSave);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.task == null
                  ? 'Task "${taskToSave.title}" added to Workload!'
                  : 'Task updated successfully!',
            ),
            backgroundColor: AppColors.figmaCodeBadge,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider);
    final projects = ref.watch(projectsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.figmaMetricCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.figmaBottomNav,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task == null
                                ? 'New Workload Task'
                                : 'Edit Task',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'LINKED ACADEMIC & SOFTWARE SPRINT ITEM',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.figmaMaroonText,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFA69090), thickness: 1),
              const SizedBox(height: 14),

              // Title Field
              _buildLabel('Task Title *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
                decoration: _buildInputDecoration(
                  hint: 'e.g. DSA Assignment 2: Binary Search Trees',
                  icon: Icons.title_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description Field
              _buildLabel('Description / Requirements'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                decoration: _buildInputDecoration(
                  hint: 'Key deliverable specifications or test cases...',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 16),

              // Category Selector
              _buildLabel('Task Category & Direct Linkage'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip(
                    label: 'Academic Course',
                    categoryValue: 'course',
                    icon: Icons.school_outlined,
                  ),
                  _buildCategoryChip(
                    label: 'Software Project',
                    categoryValue: 'project',
                    icon: Icons.alt_route_rounded,
                  ),
                  _buildCategoryChip(
                    label: 'Skill Matrix',
                    categoryValue: 'skill',
                    icon: Icons.code_rounded,
                  ),
                  _buildCategoryChip(
                    label: 'General',
                    categoryValue: 'general',
                    icon: Icons.task_alt_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Dynamic Direct Linkage to Course or Project
              if (_category == 'course') ...[
                _buildLabel('Direct Academic Course Link:'),
                const SizedBox(height: 6),
                if (courses.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue:
                        courses.any((c) => c.name == _selectedCourseName)
                        ? _selectedCourseName
                        : null,
                    hint: Text(
                      'Select enrolled course',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                    decoration: _buildInputDecoration(
                      hint: '',
                      icon: Icons.school_rounded,
                    ),
                    items: courses.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(
                          '${c.code}: ${c.name}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCourseName = val;
                        final match = courses.firstWhere(
                          (c) => c.name == val,
                          orElse: () => courses.first,
                        );
                        _selectedCourseId = match.id;
                      });
                    },
                  )
                else
                  TextFormField(
                    controller: _customLinkController,
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                    decoration: _buildInputDecoration(
                      hint: 'e.g. CSE-301 Data Structures',
                      icon: Icons.school_rounded,
                    ),
                  ),
                const SizedBox(height: 14),
              ] else if (_category == 'project') ...[
                _buildLabel('Direct Software Project Link:'),
                const SizedBox(height: 6),
                if (projects.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue:
                        projects.any((p) => p.title == _selectedProjectName)
                        ? _selectedProjectName
                        : null,
                    hint: Text(
                      'Select active project repository',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                    decoration: _buildInputDecoration(
                      hint: '',
                      icon: Icons.alt_route_rounded,
                    ),
                    items: projects.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.title,
                        child: Text(
                          p.title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProjectName = val;
                        final match = projects.firstWhere(
                          (p) => p.title == val,
                          orElse: () => projects.first,
                        );
                        _selectedProjectId = match.id;
                      });
                    },
                  )
                else
                  TextFormField(
                    controller: _customLinkController,
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                    decoration: _buildInputDecoration(
                      hint: 'e.g. DevOS Mobile App',
                      icon: Icons.alt_route_rounded,
                    ),
                  ),
                const SizedBox(height: 14),
              ],

              // Priority Selector
              _buildLabel('Priority Indicator *'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityButton(
                    TaskPriority.urgent,
                    'Urgent',
                    AppColors.figmaTextRed,
                    Icons.priority_high_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityButton(
                    TaskPriority.high,
                    'High',
                    const Color(0xFFD97706),
                    Icons.arrow_upward_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityButton(
                    TaskPriority.medium,
                    'Medium',
                    AppColors.figmaBlue,
                    Icons.remove_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityButton(
                    TaskPriority.low,
                    'Low',
                    const Color(0xFF059669),
                    Icons.arrow_downward_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status & Due Date Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('State / Status'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _status,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          decoration: _buildInputDecoration(
                            hint: '',
                            icon: Icons.flag_outlined,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TaskStatus.pending,
                              child: Text(
                                'To Do',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: TaskStatus.inProgress,
                              child: Text(
                                'In Progress',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: TaskStatus.completed,
                              child: Text(
                                'Done',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _status = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Due Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Deadline / Due Date'),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF333333),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: Color(0xFF333333),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _dueDate != null
                                        ? '${_dueDate!.month}/${_dueDate!.day} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                                        : 'Set deadline',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(
                          color: Color(0xFF333333),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.figmaBottomNav,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.task == null
                                  ? 'ADD TO WORKLOAD'
                                  : 'UPDATE TASK',
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String categoryValue,
    required IconData icon,
  }) {
    final isSelected = _category == categoryValue;
    return InkWell(
      onTap: () => setState(() => _category = categoryValue),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
    TaskPriority p,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _priority == p;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = p),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFF333333),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : color),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF757575),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF333333)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.figmaBlue, width: 2),
      ),
    );
  }
}
