import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/app_providers.dart';
import 'widgets/markdown_renderer.dart';

enum NoteEditorTab { edit, preview, zen }

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final String? initialCategory;

  const NoteEditorScreen({super.key, this.note, this.initialCategory});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final TextEditingController _newTagController = TextEditingController();

  late String _category;
  late List<String> _tags;
  bool _isFavorite = false;
  bool _isSaving = false;

  NoteEditorTab _activeTab = NoteEditorTab.edit;

  final List<String> _folderOptions = [
    'Algorithms & DSA',
    'System Architecture',
    'DevOps & Cloud',
    'Robotics & Embedded',
    'Quick Cheatsheets',
    'General Notes',
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _category = n?.category ?? widget.initialCategory ?? _folderOptions.first;
    _tags = List<String>.from(n?.tags ?? ['#notes']);
    _isFavorite = n?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  void _insertMarkdownToken(String start, [String end = '']) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (selection.start < 0) {
      _contentController.text = text + start + end;
      return;
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$start${selection.textInside(text)}$end',
    );
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset:
          selection.start + start.length + selection.textInside(text).length,
    );
  }

  void _addTag(String rawTag) {
    var tag = rawTag.trim();
    if (tag.isEmpty) return;
    if (!tag.startsWith('#')) {
      tag = '#$tag';
    }
    if (!_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _newTagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _activeTab = NoteEditorTab.edit);
      return;
    }

    setState(() => _isSaving = true);

    final noteToSave = Note(
      id: widget.note?.id ?? 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
      isFavorite: _isFavorite,
      tags: _tags,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.note == null) {
        await ref.read(notesProvider.notifier).addNote(noteToSave);
      } else {
        await ref.read(notesProvider.notifier).updateNote(noteToSave);
      }

      if (mounted) {
        Navigator.pop(context, noteToSave);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.note == null
                  ? 'Note created in Knowledge Base!'
                  : 'Note updated!',
            ),
            backgroundColor: AppColors.figmaCodeBadge,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeTab == NoteEditorTab.zen) {
      return _buildZenEditor();
    }

    return Scaffold(
      backgroundColor: AppColors.figmaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.figmaBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.note == null ? 'New Markdown Note' : 'Edit Note',
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.figmaBlue,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          // Save Button
          Padding(
            padding: const EdgeInsets.only(right: 14.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 16),
              label: Text(
                'SAVE',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.figmaBottomNav,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode Switcher: [ Editor ] [ Preview ] [ Zen Mode ]
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.figmaCardDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeTab(
                              title: 'Editor',
                              icon: Icons.edit_note_rounded,
                              tab: NoteEditorTab.edit,
                            ),
                          ),
                          Expanded(
                            child: _buildModeTab(
                              title: 'Live Preview',
                              icon: Icons.remove_red_eye_rounded,
                              tab: NoteEditorTab.preview,
                            ),
                          ),
                          Expanded(
                            child: _buildModeTab(
                              title: 'Zen Focus',
                              icon: Icons.fullscreen_rounded,
                              tab: NoteEditorTab.zen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Note Title (e.g. Red-Black Tree Invariants)...',
                        hintStyle: GoogleFonts.inter(
                          color: Colors.black38,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.article_outlined,
                          color: Color(0xFF333333),
                          size: 20,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.figmaBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a note title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Folder & Star Selector Row
                    Row(
                      children: [
                        // Folder Selector
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _folderOptions.contains(_category)
                                ? _category
                                : _folderOptions.first,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.folder_open_rounded,
                                color: Color(0xFF333333),
                                size: 18,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF333333),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF333333),
                                  width: 1,
                                ),
                              ),
                            ),
                            items: _folderOptions.map((folder) {
                              return DropdownMenuItem<String>(
                                value: folder,
                                child: Text(
                                  '📁 $folder',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _category = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Favorite Star Toggle
                        InkWell(
                          onTap: () =>
                              setState(() => _isFavorite = !_isFavorite),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF333333),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isFavorite
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: _isFavorite
                                      ? const Color(0xFFF59E0B)
                                      : Colors.black54,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isFavorite ? 'STARRED' : 'STAR',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: _isFavorite
                                        ? const Color(0xFFB45309)
                                        : Colors.black87,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Multi-Tag Input & Chips
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.tag_rounded,
                                size: 16,
                                color: Color(0xFF333333),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tags for Multi-tag Filtering:',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.black87,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ..._tags.map(
                                (t) => Chip(
                                  label: Text(
                                    t,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                  onDeleted: () => _removeTag(t),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: const BorderSide(
                                      color: Color(0xFF333333),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                height: 32,
                                child: TextField(
                                  controller: _newTagController,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '+ Add tag',
                                    hintStyle: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: Colors.black45,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onSubmitted: _addTag,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Markdown Shortcut Toolbar
                    if (_activeTab == NoteEditorTab.edit) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.figmaCardDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildToolbarBtn(
                                'H1',
                                () => _insertMarkdownToken('# '),
                              ),
                              _buildToolbarBtn(
                                'H2',
                                () => _insertMarkdownToken('## '),
                              ),
                              _buildToolbarBtn(
                                'H3',
                                () => _insertMarkdownToken('### '),
                              ),
                              _buildToolbarDivider(),
                              _buildToolbarBtn(
                                'B',
                                () => _insertMarkdownToken('**', '**'),
                                isBold: true,
                              ),
                              _buildToolbarBtn(
                                'I',
                                () => _insertMarkdownToken('*', '*'),
                                isItalic: true,
                              ),
                              _buildToolbarBtn(
                                '`code`',
                                () => _insertMarkdownToken('`', '`'),
                              ),
                              _buildToolbarDivider(),
                              _buildToolbarBtn(
                                '```cpp',
                                () => _insertMarkdownToken(
                                  '\n```cpp\n',
                                  '\n```\n',
                                ),
                              ),
                              _buildToolbarBtn(
                                '```py',
                                () => _insertMarkdownToken(
                                  '\n```python\n',
                                  '\n```\n',
                                ),
                              ),
                              _buildToolbarBtn(
                                '```sql',
                                () => _insertMarkdownToken(
                                  '\n```sql\n',
                                  '\n```\n',
                                ),
                              ),
                              _buildToolbarBtn(
                                '```dart',
                                () => _insertMarkdownToken(
                                  '\n```dart\n',
                                  '\n```\n',
                                ),
                              ),
                              _buildToolbarDivider(),
                              _buildToolbarBtn(
                                '> quote',
                                () => _insertMarkdownToken('> '),
                              ),
                              _buildToolbarBtn(
                                '• list',
                                () => _insertMarkdownToken('* '),
                              ),
                              _buildToolbarBtn(
                                '1. list',
                                () => _insertMarkdownToken('1. '),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Main Editor or Live Preview
                    if (_activeTab == NoteEditorTab.edit)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1.2,
                          ),
                        ),
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: 20,
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write technical documentation in markdown...\n\n# Heading 1\n\n```cpp\n// Code snippet\n```',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              color: Colors.black26,
                              fontSize: 13,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.figmaMetricCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1.2,
                          ),
                        ),
                        child: MarkdownRenderer(
                          content: _contentController.text.isNotEmpty
                              ? _contentController.text
                              : '*No markdown content to preview.*',
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required NoteEditorTab tab,
  }) {
    final isSelected = _activeTab == tab;
    return InkWell(
      onTap: () => setState(() => _activeTab = tab),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.figmaBottomNav : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarBtn(
    String label,
    VoidCallback onTap, {
    bool isBold = false,
    bool isItalic = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF2B313E),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.white24,
    );
  }

  Widget _buildZenEditor() {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2026),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Note Title...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF3A3F4B), thickness: 1),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing in pure distraction-free zen mode...',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Exit Zen Button
            Positioned(
              top: 14,
              right: 16,
              child: InkWell(
                onTap: () => setState(() => _activeTab = NoteEditorTab.edit),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D323F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
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
                        'Exit Zen Focus',
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
}
