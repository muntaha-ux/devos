import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/research_model.dart';
import '../../providers/app_providers.dart';

class AddEditResearchModal extends ConsumerStatefulWidget {
  final ResearchPaper? paper;

  const AddEditResearchModal({super.key, this.paper});

  @override
  ConsumerState<AddEditResearchModal> createState() => _AddEditResearchModalState();
}

class _AddEditResearchModalState extends ConsumerState<AddEditResearchModal> {
  late TextEditingController _titleController;
  late TextEditingController _authorsController;
  late TextEditingController _yearController;
  late TextEditingController _topicController;
  late TextEditingController _paperLinkController;
  late TextEditingController _keyFindingsController;
  late TextEditingController _personalNotesController;
  late TextEditingController _attachmentController;
  String _status = 'saved';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.paper?.title ?? '');
    _authorsController = TextEditingController(text: widget.paper?.authors ?? '');
    _yearController = TextEditingController(
        text: widget.paper?.publicationYear.toString() ?? DateTime.now().year.toString());
    _topicController = TextEditingController(text: widget.paper?.topic ?? '');
    _paperLinkController = TextEditingController(text: widget.paper?.paperLink ?? '');
    _keyFindingsController = TextEditingController(text: widget.paper?.keyFindings ?? '');
    _personalNotesController = TextEditingController(text: widget.paper?.personalNotes ?? '');
    _attachmentController = TextEditingController(text: widget.paper?.attachmentUrl ?? '');
    _status = widget.paper?.status ?? 'saved';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorsController.dispose();
    _yearController.dispose();
    _topicController.dispose();
    _paperLinkController.dispose();
    _keyFindingsController.dispose();
    _personalNotesController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;

    if (widget.paper == null) {
      final newPaper = ResearchPaper(
        id: const Uuid().v4(),
        title: title,
        authors: _authorsController.text.trim(),
        publicationYear: year,
        topic: _topicController.text.trim().isNotEmpty ? _topicController.text.trim() : 'AI/ML',
        paperLink: _paperLinkController.text.trim(),
        keyFindings: _keyFindingsController.text.trim(),
        personalNotes: _personalNotesController.text.trim(),
        status: _status,
        attachmentUrl: _attachmentController.text.trim().isNotEmpty
            ? _attachmentController.text.trim()
            : null,
      );
      ref.read(researchProvider.notifier).addPaper(newPaper);
    } else {
      final updated = widget.paper!.copyWith(
        title: title,
        authors: _authorsController.text.trim(),
        publicationYear: year,
        topic: _topicController.text.trim().isNotEmpty ? _topicController.text.trim() : widget.paper!.topic,
        paperLink: _paperLinkController.text.trim(),
        keyFindings: _keyFindingsController.text.trim(),
        personalNotes: _personalNotesController.text.trim(),
        status: _status,
        attachmentUrl: _attachmentController.text.trim().isNotEmpty
            ? _attachmentController.text.trim()
            : null,
      );
      ref.read(researchProvider.notifier).updatePaper(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paper != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Edit Research Paper' : 'Add Research Paper',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Paper Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _authorsController,
                    decoration: const InputDecoration(
                      labelText: 'Authors',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(
                      labelText: 'Topic / Field',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'saved', child: Text('Saved')),
                      DropdownMenuItem(value: 'reading', child: Text('Reading')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'important', child: Text('Important')),
                    ],
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyFindingsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Key Findings Summary',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paperLinkController,
              decoration: const InputDecoration(
                labelText: 'ArXiv / DOI Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _attachmentController,
              decoration: const InputDecoration(
                labelText: 'Cloudflare R2 Attachment Key/URL (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEditing ? 'Save Changes' : 'Add Paper',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
