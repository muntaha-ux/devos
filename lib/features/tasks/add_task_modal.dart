import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/app_providers.dart';

class AddTaskModal extends ConsumerStatefulWidget {
  final DevTask? task;

  const AddTaskModal({super.key, this.task});

  @override
  ConsumerState<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<AddTaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _category;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _category = widget.task?.category ?? 'general';
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    if (widget.task == null) {
      final newTask = DevTask(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        status: TaskStatus.pending,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );
      ref.read(tasksProvider.notifier).addTask(newTask);
    } else {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
      );
      ref.read(tasksProvider.notifier).updateTask(updatedTask);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit Task' : 'Create New Task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'course', child: Text('Course')),
                    DropdownMenuItem(value: 'project', child: Text('Project')),
                    DropdownMenuItem(value: 'skill', child: Text('Skill')),
                    DropdownMenuItem(value: 'research', child: Text('Research')),
                    DropdownMenuItem(value: 'general', child: Text('General')),
                  ],
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                    DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                    DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
                    DropdownMenuItem(value: TaskPriority.urgent, child: Text('Urgent')),
                  ],
                  onChanged: (val) => setState(() => _priority = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              isEditing ? 'Save Changes' : 'Add Task',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
