import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../widgets/badge_chip.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BadgeChip(
                  label: note.category,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                ...note.tags.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: BadgeChip(label: t, color: AppColors.accentViolet),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorderDark),
              ),
              child: SelectableText(
                note.content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
