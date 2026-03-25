import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';
import '../providers/task_form_draft_provider.dart';
import '../providers/task_list_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? initialTask;
  final List<Task> allTasks;

  const TaskFormScreen({
    super.key,
    required this.initialTask,
    required this.allTasks,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final DateFormat _dateFormat = DateFormat.yMMMd();

  DateTime? _dueDate;
  late TaskStatus _status;
  int? _blockedBy;
  bool _isSaving = false;

  bool get _isEdit => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final draftProvider = context.read<TaskFormDraftProvider>();

    if (_isEdit) {
      final task = widget.initialTask!;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description);
      _dueDate = task.dueDate;
      _status = task.status;
      _blockedBy = task.blockedBy;
    } else {
      _titleController = TextEditingController(text: draftProvider.title);
      _descriptionController = TextEditingController(text: draftProvider.description);
      _dueDate = draftProvider.dueDate;
      _status = draftProvider.status;
      _blockedBy = draftProvider.blockedBy;
      _wireDraftListeners(draftProvider);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _wireDraftListeners(TaskFormDraftProvider draftProvider) {
    _titleController.addListener(() {
      draftProvider.setTitle(_titleController.text);
    });
    _descriptionController.addListener(() {
      draftProvider.setDescription(_descriptionController.text);
    });
  }

  List<Task> get _blockedByOptions {
    final selfId = widget.initialTask?.id;
    return widget.allTasks.where((task) => task.id != selfId).toList();
  }

  Future<void> _pickDueDate() async {
    final draftProvider = context.read<TaskFormDraftProvider>();
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, 1, 1);
    final initialDate = _dueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 10, 12, 31),
      initialDate: initialDate,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dueDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });

    if (!_isEdit) {
      await draftProvider.setDueDate(_dueDate);
    }
  }

  Future<void> _onSave() async {
    if (_isSaving) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<TaskListProvider>();
    final draftProvider = context.read<TaskFormDraftProvider>();

    final payload = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'due_date': _dueDate!.toIso8601String().split('T').first,
      'status': _status.apiValue,
      'blocked_by': _blockedBy,
    };

    try {
      if (_isEdit) {
        await provider.updateTask(widget.initialTask!.id, payload);
      } else {
        await provider.createTask(payload);
        await draftProvider.clearDraft();
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'Create Task'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _dueDate == null ? 'Select a date' : _dateFormat.format(_dueDate!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: TaskStatus.values
                    .map(
                      (status) => DropdownMenuItem<TaskStatus>(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = value;
                  });
                  if (!_isEdit) {
                    await context.read<TaskFormDraftProvider>().setStatus(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _blockedBy,
                decoration: const InputDecoration(labelText: 'Blocked By (Optional)'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._blockedByOptions.map(
                    (task) => DropdownMenuItem<int?>(
                      value: task.id,
                      child: Text('#${task.id} - ${task.title}'),
                    ),
                  ),
                ],
                onChanged: (value) async {
                  setState(() {
                    _blockedBy = value;
                  });
                  if (!_isEdit) {
                    await context.read<TaskFormDraftProvider>().setBlockedBy(value);
                  }
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSaving ? null : _onSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save'),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          await context.read<TaskFormDraftProvider>().clearDraft();
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _titleController.clear();
                            _descriptionController.clear();
                            _dueDate = null;
                            _status = TaskStatus.toDo;
                            _blockedBy = null;
                          });
                        },
                  child: const Text('Clear Draft'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
