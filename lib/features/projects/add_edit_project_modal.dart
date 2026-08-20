import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../providers/app_providers.dart';

class AddEditProjectModal extends ConsumerStatefulWidget {
  final Project? project;

  const AddEditProjectModal({super.key, this.project});

  @override
  ConsumerState<AddEditProjectModal> createState() => _AddEditProjectModalState();
}

class _AddEditProjectModalState extends ConsumerState<AddEditProjectModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _techController;
  late TextEditingController _githubController;
  late TextEditingController _liveUrlController;
  late List<TextEditingController> _milestoneControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _techController = TextEditingController(text: widget.project?.technologies.join(', ') ?? '');
    _githubController = TextEditingController(text: widget.project?.githubUrl ?? '');
    _liveUrlController = TextEditingController(text: widget.project?.liveUrl ?? '');

    if (widget.project != null && widget.project!.milestones.isNotEmpty) {
      _milestoneControllers = widget.project!.milestones
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
    _techController.dispose();
    _githubController.dispose();
    _liveUrlController.dispose();
    for (var c in _milestoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final tech = _techController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final milestones = _milestoneControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => ProjectMilestone(
              id: const Uuid().v4(),
              title: c.text.trim(),
              targetDate: '2026-10-01',
              isCompleted: false,
            ))
        .toList();

    if (widget.project == null) {
      final newProject = Project(
        id: const Uuid().v4(),
        title: title,
        description: _descriptionController.text.trim(),
        technologies: tech.isNotEmpty ? tech : ['Flutter'],
        githubUrl: _githubController.text.trim(),
        liveUrl: _liveUrlController.text.trim(),
        startDate: '2026-08-01',
        targetCompletionDate: '2026-12-01',
        status: 'in_progress',
        progressPercentage: 0,
        milestones: milestones,
      );
      ref.read(projectsProvider.notifier).addProject(newProject);
    } else {
      final updated = widget.project!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        technologies: tech,
        githubUrl: _githubController.text.trim(),
        liveUrl: _liveUrlController.text.trim(),
        milestones: milestones.isNotEmpty ? milestones : widget.project!.milestones,
      );
      ref.read(projectsProvider.notifier).updateProject(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

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
              isEditing ? 'Edit Project' : 'Create New Project',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Project Title',
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
            TextField(
              controller: _techController,
              decoration: const InputDecoration(
                labelText: 'Technologies (comma separated, e.g. Flutter, Supabase)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _githubController,
                    decoration: const InputDecoration(
                      labelText: 'GitHub Repository URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _liveUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Live Demo URL',
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
                const Text('Milestones', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Create Project',
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
