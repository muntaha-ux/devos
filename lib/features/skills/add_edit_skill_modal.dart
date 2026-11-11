import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/skill_model.dart';
import '../../providers/app_providers.dart';

class AddEditSkillModal extends ConsumerStatefulWidget {
  final Skill? skill;

  const AddEditSkillModal({super.key, this.skill});

  @override
  ConsumerState<AddEditSkillModal> createState() => _AddEditSkillModalState();
}

class _AddEditSkillModalState extends ConsumerState<AddEditSkillModal> {
  late TextEditingController _nameController;
  String _category = 'Development';
  String _proficiencyLevel = 'Intermediate';
  late List<TextEditingController> _topicControllers;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.skill?.name ?? '');
    _category = widget.skill?.category ?? 'Development';
    _proficiencyLevel = widget.skill?.proficiencyLevel ?? 'Intermediate';

    if (widget.skill != null && widget.skill!.topics.isNotEmpty) {
      _topicControllers = widget.skill!.topics
          .map((t) => TextEditingController(text: t.title))
          .toList();
    } else {
      _topicControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _topicControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final topics = _topicControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map(
          (c) => SkillTopic(
            id: const Uuid().v4(),
            title: c.text.trim(),
            isCompleted: false,
          ),
        )
        .toList();

    if (widget.skill == null) {
      final newSkill = Skill(
        id: const Uuid().v4(),
        name: name,
        category: _category,
        proficiencyLevel: _proficiencyLevel,
        progressPercentage: 0,
        topics: topics,
      );
      ref.read(skillsProvider.notifier).addSkill(newSkill);
    } else {
      final updated = widget.skill!.copyWith(
        name: name,
        category: _category,
        proficiencyLevel: _proficiencyLevel,
        topics: topics.isNotEmpty ? topics : widget.skill!.topics,
      );
      ref.read(skillsProvider.notifier).updateSkill(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.skill != null;

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
              isEditing ? 'Edit Skill' : 'Add New Skill',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name (e.g. Flutter, Rust, PyTorch)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Development',
                        child: Text('Development'),
                      ),
                      DropdownMenuItem(
                        value: 'AI / ML',
                        child: Text('AI / ML'),
                      ),
                      DropdownMenuItem(
                        value: 'Systems',
                        child: Text('Systems'),
                      ),
                      DropdownMenuItem(value: 'Design', child: Text('Design')),
                      DropdownMenuItem(value: 'DevOps', child: Text('DevOps')),
                    ],
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _proficiencyLevel,
                    decoration: const InputDecoration(
                      labelText: 'Proficiency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Beginner',
                        child: Text('Beginner'),
                      ),
                      DropdownMenuItem(
                        value: 'Intermediate',
                        child: Text('Intermediate'),
                      ),
                      DropdownMenuItem(
                        value: 'Advanced',
                        child: Text('Advanced'),
                      ),
                      DropdownMenuItem(value: 'Expert', child: Text('Expert')),
                    ],
                    onChanged: (val) =>
                        setState(() => _proficiencyLevel = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Core Topics & Competencies',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.secondary,
                  ),
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
                          hintText: 'Competency ${index + 1}',
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
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Save Skill' : 'Create Skill',
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
