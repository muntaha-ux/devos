import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papers = ref.watch(researchProvider);

    return Scaffold(
      body: ListView.builder(
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
                      BadgeChip(
                        label: paper.status.toUpperCase(),
                        color: _getStatusColor(paper.status),
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
    );
  }
}
