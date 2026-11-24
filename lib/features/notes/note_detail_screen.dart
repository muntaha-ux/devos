import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/app_providers.dart';
import 'widgets/markdown_renderer.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _isZenMode = false;
  late Note _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.figmaMetricCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        title: Text(
          'Delete Note',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${_currentNote.title}"? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              ref.read(notesProvider.notifier).deleteNote(_currentNote.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close detail screen
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Note deleted from Knowledge Base.'),
                  backgroundColor: AppColors.accentRose,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaTextRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor() async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: _currentNote),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentNote = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch notes provider to keep state fresh
    final notes = ref.watch(notesProvider);
    final freshNote = notes.firstWhere(
      (n) => n.id == _currentNote.id,
      orElse: () => _currentNote,
    );

    if (_isZenMode) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          freshNote.title,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                freshNote.category,
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF0369A1),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ZEN MODE ACTIVE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.black54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFCBD5E1), thickness: 1),
                        const SizedBox(height: 16),
                        MarkdownRenderer(
                          content: freshNote.content,
                          isZenMode: true,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              // Floating Exit Zen Mode Button
              Positioned(
                top: 14,
                right: 16,
                child: InkWell(
                  onTap: () => setState(() => _isZenMode = false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fullscreen_exit_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Exit Zen Mode',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.figmaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.figmaBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Knowledge Base',
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.figmaBlue,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          // Zen Mode Toggle
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded, color: Colors.black87),
            tooltip: 'Distraction-Free Zen Mode',
            onPressed: () => setState(() => _isZenMode = true),
          ),
          // Favorite Star Toggle
          IconButton(
            icon: Icon(
              freshNote.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: freshNote.isFavorite
                  ? const Color(0xFFF59E0B)
                  : Colors.black87,
            ),
            tooltip: freshNote.isFavorite ? 'Unstar Note' : 'Star Note',
            onPressed: () {
              ref.read(notesProvider.notifier).toggleFavorite(freshNote.id);
            },
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            tooltip: 'Edit Markdown',
            onPressed: _openEditor,
          ),
          // Delete
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.figmaTextRed,
            ),
            tooltip: 'Delete Note',
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Banner with Folder and Zen pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.figmaDarkPurpleBanner,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder_open_rounded,
                          color: Color(0xFFD6BCFA),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'FOLDER: ${freshNote.category.toUpperCase()}',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFD6BCFA),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _isZenMode = true),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 12,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ZEN READING',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Main Note Reader Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.figmaMetricCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note Title
                        Text(
                          freshNote.title,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tags & Metadata Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ...freshNote.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF333333),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  tag.startsWith('#') ? tag : '#$tag',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                            Text(
                              '• ${freshNote.createdAt.year}-${freshNote.createdAt.month.toString().padLeft(2, '0')}-${freshNote.createdAt.day.toString().padLeft(2, '0')}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFFA69090), thickness: 1),
                        const SizedBox(height: 10),

                        // Rendered Markdown Content
                        MarkdownRenderer(content: freshNote.content),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
