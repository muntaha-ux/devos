import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/app_providers.dart';
import 'note_detail_screen.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFolder = 'All';
  final Set<String> _selectedTags = <String>{};
  String _searchQuery = '';
  bool _starredOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor([Note? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          initialCategory: _selectedFolder != 'All' ? _selectedFolder : null,
        ),
      ),
    );
  }

  void _openDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
  }

  void _confirmDelete(BuildContext context, Note note) {
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
          'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
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
              ref.read(notesProvider.notifier).deleteNote(note.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final notesFromProvider = ref.watch(notesProvider);
    final notes = notesFromProvider.isEmpty
        ? _buildFallbackNotes()
        : notesFromProvider;

    // Extract all unique folders and all unique tags
    final allFolders = <String>{'All'};
    final allTags = <String>{};
    for (final note in notes) {
      if (note.category.isNotEmpty) allFolders.add(note.category);
      allTags.addAll(note.tags);
    }

    // Filter Notes
    final filteredNotes = notes.where((note) {
      // Starred Filter
      if (_starredOnly && !note.isFavorite) return false;

      // Folder Filter
      if (_selectedFolder != 'All' && note.category != _selectedFolder) {
        return false;
      }

      // Multi-Tag Filter (Must contain all selected tags)
      if (_selectedTags.isNotEmpty) {
        for (final tag in _selectedTags) {
          if (!note.tags.contains(tag)) return false;
        }
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = note.title.toLowerCase().contains(query);
        final matchContent = note.content.toLowerCase().contains(query);
        final matchTags = note.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchTitle && !matchContent && !matchTags) return false;
      }

      return true;
    }).toList();

    final totalNotes = notes.length;
    final totalFolders = allFolders.length - 1; // exclude 'All'
    final starredCount = notes.where((n) => n.isFavorite).length;
    final codeSnippetsCount = notes
        .where((n) => n.content.contains('```'))
        .length;

    return Container(
      color: AppColors.background(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(),
          backgroundColor: AppColors.figmaBottomNav,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.note_add_rounded),
          label: Text(
            'NEW NOTE',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 12,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Dark Purple Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.figmaDarkPurpleBanner,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (ctx) => InkWell(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF201633),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Knowledge Base',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'MARKDOWN NOTEBOOK & SNIPPET LIBRARY',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFD6BCFA),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '• $totalNotes NOTES',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2x2 Knowledge Metrics Grid with Green </> Code Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Total Notes',
                              value: '$totalNotes Articles',
                              valueColor: Colors.black,
                              onTap: () {
                                setState(() {
                                  _selectedFolder = 'All';
                                  _starredOnly = false;
                                  _selectedTags.clear();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Active Folders',
                              value: '$totalFolders Categorized',
                              valueColor: const Color(0xFF812DF2),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Code Snippets',
                              value: '$codeSnippetsCount Embedded',
                              valueColor: AppColors.figmaBlue,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              label: 'Starred Notes',
                              value: '$starredCount Bookmarked',
                              valueColor: const Color(0xFFF59E0B),
                              onTap: () {
                                setState(() => _starredOnly = !_starredOnly);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Green floating </> badge
                  Positioned(
                    bottom: -10,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.figmaCodeBadge,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '</>',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Search Bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search documentation, code, or tags...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF757575),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF333333),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 18,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Categorized Folders Horizontal Bar
              Row(
                children: [
                  const Icon(
                    Icons.folder_copy_outlined,
                    size: 16,
                    color: Color(0xFF333333),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Categorized Folders:',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...allFolders.map((folder) {
                      final count = folder == 'All'
                          ? totalNotes
                          : notes.where((n) => n.category == folder).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildFolderPill(folder, count),
                      );
                    }),
                    // Starred Quick Filter Pill
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () =>
                            setState(() => _starredOnly = !_starredOnly),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _starredOnly
                                ? const Color(0xFFB45309)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _starredOnly
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF333333),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: _starredOnly
                                    ? Colors.white
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Starred ($starredCount)',
                                style: GoogleFonts.jetBrainsMono(
                                  color: _starredOnly
                                      ? Colors.white
                                      : Colors.black87,
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
              const SizedBox(height: 14),

              // Multi-Tag Filter Bar
              if (allTags.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_outlined,
                          size: 16,
                          color: Color(0xFF333333),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Multi-Tag Filter:',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedTags.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _selectedTags.clear()),
                        child: Text(
                          'Clear Tags (${_selectedTags.length})',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppColors.figmaBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: allTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          label: Text(tag),
                          labelStyle: GoogleFonts.jetBrainsMono(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.figmaCodeBadge,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.figmaCodeBadge
                                  : const Color(0xFF333333),
                              width: 0.8,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Active Filters Notification Banner
              if (_selectedTags.isNotEmpty ||
                  _selectedFolder != 'All' ||
                  _starredOnly ||
                  _searchQuery.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF812DF2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Color(0xFF672EC9),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtered by: ${_selectedFolder != 'All' ? 'Folder: $_selectedFolder  ' : ''}${_selectedTags.isNotEmpty ? 'Tags: ${_selectedTags.join(", ")}  ' : ''}${_starredOnly ? 'Starred  ' : ''}${_searchQuery.isNotEmpty ? '"$_searchQuery"' : ''}',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF3B0764),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFolder = 'All';
                            _selectedTags.clear();
                            _starredOnly = false;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                    ],
                  ),
                ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Technical Notes (${filteredNotes.length})',
                    style: GoogleFonts.inter(
                      color: AppColors.figmaTextRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'FOLDER: ${_selectedFolder.toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Notes List or Empty State
              if (filteredNotes.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredNotes.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return _buildNoteCard(note);
                  },
                ),
              const SizedBox(height: 80), // FAB space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color valueColor,
    required VoidCallback onTap,
  }) {
    final isDark = AppColors.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: isDark ? const Color(0xFF8B949E) : Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderPill(String folder, int count) {
    final isSelected = _selectedFolder == folder && !_starredOnly;
    final isDark = AppColors.isDark(context);
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFolder = folder;
          _starredOnly = false;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.figmaBottomNav
              : (isDark ? const Color(0xFF21262D) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.figmaBottomNav
                : AppColors.cardBorder(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              folder == 'All'
                  ? Icons.folder_copy_rounded
                  : Icons.folder_outlined,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
            ),
            const SizedBox(width: 5),
            Text(
              folder,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFC9D1D9) : Colors.black87),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white24
                    : (isDark
                          ? const Color(0xFF30363D)
                          : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFE6EDF3) : Colors.black87),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final hasCode = note.content.contains('```');
    final isDark = AppColors.isDark(context);

    // Extract first non-heading preview line
    String previewText =
        note.content
            .split('\n')
            .where(
              (l) =>
                  !l.startsWith('#') &&
                  !l.startsWith('```') &&
                  l.trim().isNotEmpty,
            )
            .firstOrNull ??
        '';

    return InkWell(
      onTap: () => _openDetail(note),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Folder Badge, Star Toggle, Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.figmaDarkPurpleBanner,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '📁 ${note.category.toUpperCase()}',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFD6BCFA),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (hasCode) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF201633),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF672EC9),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.code_rounded,
                              size: 11,
                              color: Color(0xFFD6BCFA),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'CODE',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (ref.read(notesProvider).isEmpty) {
                          for (final n in _buildFallbackNotes()) {
                            ref.read(notesProvider.notifier).addNote(n);
                          }
                        }
                        ref
                            .read(notesProvider.notifier)
                            .toggleFavorite(note.id);
                      },
                      child: Icon(
                        note.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 20,
                        color: note.isFavorite
                            ? const Color(0xFFF59E0B)
                            : (isDark ? Colors.white38 : Colors.black45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Note Title
            Text(
              note.title,
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFFE6EDF3) : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Content Preview
            if (previewText.isNotEmpty)
              Text(
                previewText,
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF8B949E) : Colors.black87,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10),

            // Multi-tag chips
            if (note.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: note.tags.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF21262D)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF30363D)
                            : const Color(0xFF333333),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.jetBrainsMono(
                        color: isDark
                            ? const Color(0xFFC9D1D9)
                            : Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            Divider(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFD1D5DB),
              thickness: 0.8,
            ),
            const SizedBox(height: 6),

            // Bottom Actions: Read Button, Edit, Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _openDetail(note),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.figmaBottomNav,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'READ NOTEBOOK',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                      tooltip: 'Edit Note',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => _openEditor(note),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.figmaTextRed,
                      ),
                      tooltip: 'Delete Note',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => _confirmDelete(context, note),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.figmaMetricCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.figmaBackground,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF333333), width: 1),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 36,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No matching technical notes',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your folder selection, multi-tag filters, or search terms.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openEditor(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.figmaBottomNav,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
            ),
            child: Text(
              '+ CREATE FIRST NOTE',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Note> _buildFallbackNotes() {
    return [
      Note(
        id: 'fallback-note-1',
        title: 'SOLID Principles in Modern Flutter & Riverpod',
        content: '''# S.O.L.I.D. Architecture in Flutter

Understanding Single Responsibility and Dependency Inversion in Riverpod-driven state:

```dart
// Dependency Inversion: Depend on abstractions
abstract class IAuthRepository {
  Future<AuthResult> signIn({required String email, required String password});
}

// Low-level concrete provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository();
});
```

### Key Takeaways
1. Keep widgets pure and free of business logic.
2. Abstract cloud dependencies behind repository interfaces.
3. Use StateNotifier or AsyncNotifier for testable state mutations.
''',
        category: 'Architecture',
        tags: ['#Flutter', '#SOLID', '#Riverpod', '#CleanCode'],
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Note(
        id: 'fallback-note-2',
        title: 'Distributed Consensus: Raft Protocol Deep Dive',
        content: '''# Raft Consensus Protocol

Raft decomposes consensus into three independent subproblems:
1. **Leader Election**: Randomized timers prevent split votes.
2. **Log Replication**: The leader accepts log entries and replicates them across followers.
3. **Safety**: State Machine Safety guarantees uncommitted entries are never overwritten.

```go
type RequestVoteArgs struct {
    Term         int
    CandidateId  int
    LastLogIndex int
    LastLogTerm  int
}
```

> "In Search of an Understandable Consensus Algorithm" — Diego Ongaro and John Ousterhout.
''',
        category: 'Algorithms',
        tags: ['#DistributedSystems', '#Raft', '#Go', '#Consensus'],
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Note(
        id: 'fallback-note-3',
        title: 'PostgreSQL Index Optimization & Execution Plans',
        content: '''# Index Tuning for Relational Queries

When querying multi-column tables with high cardinality:

```sql
-- Create composite B-Tree index for tenant querying
CREATE INDEX idx_tasks_user_status ON tasks (user_id, status);

-- Verify execution plan avoids Sequential Scans
EXPLAIN ANALYZE
SELECT * FROM tasks
WHERE user_id = 'usr_123' AND status = 'pending';
```

- Prefer B-Tree for equality and range queries.
- Prefer GIN for full-text search and JSONB arrays.
''',
        category: 'Databases',
        tags: ['#PostgreSQL', '#SQL', '#Performance', '#Indexing'],
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
