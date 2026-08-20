import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/badge_chip.dart';
import 'note_detail_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailScreen(note: note),
                  ),
                );
              },
              title: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    note.content.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      BadgeChip(
                        label: note.category,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      ...note.tags.take(2).map((t) => Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: BadgeChip(label: t, color: AppColors.textMutedDark),
                          )),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  note.isFavorite ? Icons.star : Icons.star_border,
                  color: note.isFavorite ? AppColors.accentAmber : AppColors.textMutedDark,
                ),
                onPressed: () {
                  ref.read(notesProvider.notifier).toggleFavorite(note.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
