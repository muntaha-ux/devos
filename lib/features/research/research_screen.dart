import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/research_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_research_modal.dart';

class ResearchScreen extends ConsumerWidget {
  const ResearchScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.secondary;
      case 'reading':
        return AppColors.primary;
      case 'important':
        return AppColors.accentRose;
      case 'saved':
      default:
        return AppColors.accentAmber;
    }
  }

  void _showAddEditModal(BuildContext context, [ResearchPaper? paper]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditResearchModal(paper: paper),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ResearchPaper paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Research Paper'),
        content: Text('Are you sure you want to delete "${paper.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(researchProvider.notifier).deletePaper(paper.id);
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
    final papers = ref.watch(researchProvider);

    return Scaffold(
      body: papers.isEmpty
          ? const Center(child: Text('No research papers added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: papers.length,
              itemBuilder: (context, index) {
                final paper = papers[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BadgeChip(
                              label: paper.topic,
                              color: AppColors.accentViolet,
                            ),
                            Row(
                              children: [
                                BadgeChip(
                                  label: paper.status.toUpperCase(),
                                  color: _getStatusColor(paper.status),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMutedDark),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditModal(context, paper);
                                    } else if (val == 'delete') {
                                      _confirmDelete(context, ref, paper);
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
                        const SizedBox(height: 10),
                        Text(
                          paper.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${paper.authors} (${paper.publicationYear})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorderDark),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Key Findings:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paper.keyFindings,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ],
                          ),
                        ),
                        if (paper.attachmentUrl != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: AppColors.accentRose, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Cloudflare R2 PDF: ${paper.attachmentUrl}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
