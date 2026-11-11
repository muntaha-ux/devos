import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/course_model.dart';
import '../../providers/app_providers.dart';

class AddEditCourseModal extends ConsumerStatefulWidget {
  final Course? course;

  const AddEditCourseModal({super.key, this.course});

  @override
  ConsumerState<AddEditCourseModal> createState() => _AddEditCourseModalState();
}

class _AddEditCourseModalState extends ConsumerState<AddEditCourseModal> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late TextEditingController _creditHoursController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _topicControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _codeController = TextEditingController(text: widget.course?.code ?? '');
    _instructorController = TextEditingController(
      text: widget.course?.instructor ?? '',
    );
    _creditHoursController = TextEditingController(
      text: widget.course?.creditHours.toString() ?? '3.0',
    );
    _descriptionController = TextEditingController(
      text: widget.course?.description ?? '',
    );

    if (widget.course != null && widget.course!.topics.isNotEmpty) {
      _topicControllers = widget.course!.topics
          .map((t) => TextEditingController(text: t.title))
          .toList();
    } else {
      _topicControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _creditHoursController.dispose();
    _descriptionController.dispose();
    for (var c in _topicControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    if (name.isEmpty || code.isEmpty) return;

    final creditHours =
        double.tryParse(_creditHoursController.text.trim()) ?? 3.0;

    final topics = _topicControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map(
          (c) => CourseTopic(
            id: const Uuid().v4(),
            title: c.text.trim(),
            isCompleted: false,
          ),
        )
        .toList();

    if (widget.course == null) {
      final newCourse = Course(
        id: const Uuid().v4(),
        name: name,
        code: code,
        instructor: _instructorController.text.trim(),
        creditHours: creditHours,
        description: _descriptionController.text.trim(),
        colorHex: '#06B6D4',
        progressPercentage: 0,
        topics: topics,
      );
      ref.read(coursesProvider.notifier).addCourse(newCourse);
    } else {
      final updated = widget.course!.copyWith(
        name: name,
        code: code,
        instructor: _instructorController.text.trim(),
        creditHours: creditHours,
        description: _descriptionController.text.trim(),
        topics: topics.isNotEmpty ? topics : widget.course!.topics,
      );
      ref.read(coursesProvider.notifier).updateCourse(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Course' : 'Add New Course',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Code (e.g. CSE-401)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _creditHoursController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Credit Hours',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Course Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Topics / Modules',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _topicControllers.add(TextEditingController());
                    });
                  },
                ),
              ],
            ),
            ..._topicControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Topic ${index + 1}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_topicControllers.length > 1)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.accentRose,
                        ),
                        onPressed: () {
                          setState(() {
                            _topicControllers.removeAt(index);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Create Course',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
