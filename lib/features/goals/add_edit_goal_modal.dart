import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/goal_model.dart';
import '../../providers/app_providers.dart';

class AddEditGoalModal extends ConsumerStatefulWidget {
  final Goal? goal;

  const AddEditGoalModal({super.key, this.goal});

  @override
  ConsumerState<AddEditGoalModal> createState() => _AddEditGoalModalState();
}

class _AddEditGoalModalState extends ConsumerState<AddEditGoalModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetDateController;
  String _category = 'Career';
  late List<TextEditingController> _milestoneControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _targetDateController = TextEditingController(text: widget.goal?.targetDate ?? 'Q4 2026');
    _category = widget.goal?.category ?? 'Career';

    if (widget.goal != null && widget.goal!.milestones.isNotEmpty) {
      _milestoneControllers = widget.goal!.milestones
          .map((m) => TextEditingController(text: m.title))
          .toList();
    } else {
      _milestoneControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetDateController.dispose();
    for (var c in _milestoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final milestones = _milestoneControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => GoalMilestone(
              id: const Uuid().v4(),
              title: c.text.trim(),
              isCompleted: false,
            ))
        .toList();

    if (widget.goal == null) {
      final newGoal = Goal(
        id: const Uuid().v4(),
        title: title,
        description: _descriptionController.text.trim(),
        category: _category,
        targetDate: _targetDateController.text.trim(),
        progressPercentage: 0,
        status: 'active',
        milestones: milestones,
      );
      ref.read(goalsProvider.notifier).addGoal(newGoal);
    } else {
      final updated = widget.goal!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        category: _category,
        targetDate: _targetDateController.text.trim(),
        milestones: milestones.isNotEmpty ? milestones : widget.goal!.milestones,
      );
      ref.read(goalsProvider.notifier).updateGoal(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;

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
              isEditing ? 'Edit Goal' : 'Create Goal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'Career', child: Text('Career')),
                      DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                      DropdownMenuItem(value: 'Skill Mastery', child: Text('Skill Mastery')),
                      DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                    ],
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _targetDateController,
                    decoration: const InputDecoration(
                      labelText: 'Target Date (e.g. Q4 2026)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Roadmap Milestones', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.secondary),
                  onPressed: () {
                    setState(() {
                      _milestoneControllers.add(TextEditingController());
                    });
                  },
                ),
              ],
            ),
            ..._milestoneControllers.asMap().entries.map((entry) {
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
                          hintText: 'Milestone ${index + 1}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_milestoneControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.accentRose),
                        onPressed: () {
                          setState(() {
                            _milestoneControllers.removeAt(index);
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
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Create Goal',
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
