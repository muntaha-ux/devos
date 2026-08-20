import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../models/skill_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_skill_modal.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  void _showAddEditModal(BuildContext context, [Skill? skill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditSkillModal(skill: skill),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(skillsProvider.notifier).deleteSkill(skill.id);
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
    final skills = ref.watch(skillsProvider);

    return Scaffold(
      body: skills.isEmpty
          ? const Center(child: Text('No skills added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                final completedCount = skill.topics.where((t) => t.isCompleted).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              skill.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                BadgeChip(
                                  label: '${skill.progressPercentage}%',
                                  color: AppColors.secondary,
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMutedDark),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditModal(context, skill);
                                    } else if (val == 'delete') {
                                      _confirmDelete(context, ref, skill);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: AppColors.accentRose),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: AppColors.accentRose)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            BadgeChip(
                              label: skill.category,
                              color: AppColors.accentViolet,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Level: ${skill.proficiencyLevel}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: skill.topics.isEmpty ? 0 : skill.progressPercentage / 100.0,
                          backgroundColor: AppColors.surfaceDark,
                          progressColor: AppColors.secondary,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Topics & Core Competencies ($completedCount/${skill.topics.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        ...skill.topics.map((topic) => CheckboxListTile(
                              dense: true,
                              activeColor: AppColors.secondary,
                              checkColor: Colors.black,
                              contentPadding: EdgeInsets.zero,
                              value: topic.isCompleted,
                              onChanged: (val) {
                                ref.read(skillsProvider.notifier).toggleSkillTopic(skill.id, topic.id);
                              },
                              title: Text(
                                topic.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                                  color: topic.isCompleted ? AppColors.textMutedDark : AppColors.textPrimaryDark,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
