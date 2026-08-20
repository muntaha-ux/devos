import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'add_edit_note_modal.dart';

class NoteDetailScreen extends ConsumerWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  void _showEditModal(BuildContext context, Note currentNote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditNoteModal(note: currentNote),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Note currentNote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${currentNote.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRose),
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(currentNote.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to notes list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final currentNote = notes.firstWhere(
      (n) => n.id == note.id,
      orElse: () => note,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentNote.title),
        actions: [
          IconButton(
            icon: Icon(
              currentNote.isFavorite ? Icons.star : Icons.star_border,
              color: currentNote.isFavorite ? AppColors.accentAmber : AppColors.textMutedDark,
            ),
            onPressed: () {
              ref.read(notesProvider.notifier).toggleFavorite(currentNote.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditModal(context, currentNote),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.accentRose),
            onPressed: () => _confirmDelete(context, ref, currentNote),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BadgeChip(
                  label: currentNote.category,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                ...currentNote.tags.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: BadgeChip(label: t, color: AppColors.accentViolet),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentNote.title,
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
                currentNote.content,
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
