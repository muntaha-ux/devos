import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../providers/app_providers.dart';

class AddEditEventModal extends ConsumerStatefulWidget {
  final CalendarEvent? event;

  const AddEditEventModal({super.key, this.event});

  @override
  ConsumerState<AddEditEventModal> createState() => _AddEditEventModalState();
}

class _AddEditEventModalState extends ConsumerState<AddEditEventModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _eventType = 'general';
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _eventType = widget.event?.eventType ?? 'general';
    _startTime = widget.event?.startTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (widget.event == null) {
      final newEvent = CalendarEvent(
        id: const Uuid().v4(),
        title: title,
        description: _descriptionController.text.trim(),
        eventType: _eventType,
        startTime: _startTime,
      );
      ref.read(eventsProvider.notifier).addEvent(newEvent);
    } else {
      final updated = widget.event!.copyWith(
        title: title,
        description: _descriptionController.text.trim(),
        eventType: _eventType,
        startTime: _startTime,
      );
      ref.read(eventsProvider.notifier).updateEvent(updated);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

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
              isEditing ? 'Edit Calendar Event' : 'Add Calendar Event',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'exam', child: Text('Exam')),
                DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                DropdownMenuItem(value: 'project_deadline', child: Text('Project Deadline')),
                DropdownMenuItem(value: 'learning_session', child: Text('Learning Session')),
                DropdownMenuItem(value: 'general', child: Text('General Event')),
              ],
              onChanged: (val) => setState(() => _eventType = val!),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date & Time'),
              subtitle: Text(_startTime.toString().substring(0, 16)),
              trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startTime,
                  firstDate: DateTime(2025),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startTime),
                  );
                  if (time != null) {
                    if (!mounted) return;
                    setState(() {
                      _startTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
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
                isEditing ? 'Save Changes' : 'Create Event',
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
