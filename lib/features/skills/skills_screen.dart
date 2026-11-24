import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/skill_model.dart';
import '../../providers/app_providers.dart';
import 'add_edit_skill_modal.dart';

class SkillsScreen extends ConsumerStatefulWidget {
  const SkillsScreen({super.key});

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  int _selectedSkillIndex = 0;

  void _showAddEditModal(BuildContext context, [Skill? skill]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditSkillModal(skill: skill),
    );
  }

  void _showAddSubTopicDialog(BuildContext context, WidgetRef ref, Skill? skill) {
    if (skill == null) return;
    final titleController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.cardBorder(ctx)),
        ),
        title: Text(
          'Add Sub-topic to ${skill.name}',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(ctx),
          ),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary(ctx)),
          decoration: InputDecoration(
            labelText: 'Sub-topic Title',
            hintText: 'e.g. Asynchronous Streams, Memory Profiling',
            labelStyle: TextStyle(color: AppColors.textSecondary(ctx)),
            hintStyle: TextStyle(color: AppColors.textSecondary(ctx)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaForestBanner,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newTopic = SkillTopic(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  isCompleted: false,
                );
                final updated = skill.copyWith(topics: [...skill.topics, newTopic]);
                ref.read(skillsProvider.notifier).updateSkill(updated);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add Topic'),
          ),
        ],
      ),
    );
  }

  String _formatLevel(int progress) {
    if (progress < 25) return 'LVL 1';
    if (progress < 50) return 'LVL 2';
    if (progress < 75) return 'LVL 3';
    if (progress < 90) return 'LVL 4';
    return 'LVL 5';
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(skillsProvider);

    if (_selectedSkillIndex >= skills.length && skills.isNotEmpty) {
      _selectedSkillIndex = 0;
    }

    final activeSkill = skills.isNotEmpty ? skills[_selectedSkillIndex] : null;

    return Container(
      color: AppColors.background(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Green Banner: Skill Matrix + Add Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: AppColors.figmaForestBanner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF333333),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skill Matrix',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ENGINEERING PROFICIENCY',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFFBBF7D0),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Add Skill',
                    button: true,
                    child: InkWell(
                      onTap: () => _showAddEditModal(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.figmaPlusBtn,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Skill Selector Horizontal Pills
            if (skills.length > 1) ...[
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    final s = skills[index];
                    final isSelected = index == _selectedSkillIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedSkillIndex = index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.figmaCyanCard : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s.name,
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

            // Active Skill Mastery Card
            if (activeSkill != null) ...[
              _buildSkillMasteryCard(
                context: context,
                title: activeSkill.name,
                level: _formatLevel(activeSkill.progressPercentage),
                percentage: activeSkill.progressPercentage,
                category: activeSkill.category,
                backgroundColor: AppColors.figmaPurpleCard,
                onEdit: () => _showAddEditModal(context, activeSkill),
              ),
            ] else ...[
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
                    const Icon(Icons.code_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'No Skills Added Yet',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add technical languages, frameworks, or system tools to track your mastery.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Section Header: Active Skill Sub-topics
            if (activeSkill != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${activeSkill.name} Modules',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFD12631),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${activeSkill.topics.where((t) => t.isCompleted).length}/${activeSkill.topics.length} Done',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xFFA69090), thickness: 1),
              const SizedBox(height: 14),

              // Dynamic Sub-topics List
              if (activeSkill.topics.isNotEmpty) ...[
                ...activeSkill.topics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topic = entry.value;
                  final isAlt = index % 2 == 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () {
                        ref.read(skillsProvider.notifier).toggleSkillTopic(activeSkill.id, topic.id);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isAlt ? AppColors.figmaGreenSubtopic : AppColors.figmaPurpleCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              topic.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: topic.isCompleted ? const Color(0xFFA7F3D0) : Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.title,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    topic.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: topic.isCompleted ? const Color(0xFFA7F3D0) : const Color(0xFFFEF08A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ] else ...[
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
                      'No sub-topics added for ${activeSkill.name} yet.\nTap "+ Add Sub-topic" below to build your curriculum.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.textSecondary(context), fontSize: 13),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // + Add Sub-topic Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.figmaAddBtn,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF333333)),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _showAddSubTopicDialog(context, ref, activeSkill),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'Add Sub-topic',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillMasteryCard({
    required BuildContext context,
    required String title,
    required String level,
    required int percentage,
    required String category,
    required Color backgroundColor,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        level,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFDBA74),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skill Mastery',
                style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 11),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(color: const Color(0xFF222222)),
                  FractionallySizedBox(
                    widthFactor: percentage.clamp(0, 100) / 100.0,
                    child: Container(color: AppColors.figmaPink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
