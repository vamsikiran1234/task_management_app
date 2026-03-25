import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';
import '../providers/task_form_draft_provider.dart';
import '../providers/task_list_provider.dart';
import 'task_form_screen.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListProvider>().loadTasks();
    });
  }

  Future<void> _openCreateTask() async {
    final provider = context.read<TaskListProvider>();
    final draftProvider = context.read<TaskFormDraftProvider>();
    await draftProvider.loadDraft();

    if (!mounted) {
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskFormScreen(
          initialTask: null,
          allTasks: provider.tasks,
        ),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task created successfully.')),
    );
  }

  Future<void> _openEditTask(Task task) async {
    final provider = context.read<TaskListProvider>();

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TaskFormScreen(
          initialTask: task,
          allTasks: provider.tasks,
        ),
      ),
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully.')),
    );
  }

  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Delete "${task.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await context.read<TaskListProvider>().deleteTask(task.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Column(
        children: [
          const _SearchAndFilterRow(),
          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(provider.errorMessage!),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: provider.loadTasks,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet. Add your first task.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return TaskCard(
                        task: task,
                        onEdit: () => _openEditTask(task),
                        onDelete: () => _confirmDelete(task),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : _openCreateTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _SearchAndFilterRow extends StatefulWidget {
  const _SearchAndFilterRow();

  @override
  State<_SearchAndFilterRow> createState() => _SearchAndFilterRowState();
}

class _SearchAndFilterRowState extends State<_SearchAndFilterRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskListProvider>();
    _controller.value = TextEditingValue(
      text: provider.searchQuery,
      selection: TextSelection.collapsed(offset: provider.searchQuery.length),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search by title',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<TaskStatus?>(
            value: provider.statusFilter,
            items: const [
              DropdownMenuItem<TaskStatus?>(
                value: null,
                child: Text('All'),
              ),
              DropdownMenuItem<TaskStatus?>(
                value: TaskStatus.toDo,
                child: Text('To-Do'),
              ),
              DropdownMenuItem<TaskStatus?>(
                value: TaskStatus.inProgress,
                child: Text('In Progress'),
              ),
              DropdownMenuItem<TaskStatus?>(
                value: TaskStatus.done,
                child: Text('Done'),
              ),
            ],
            onChanged: (value) {
              provider.setStatusFilter(value);
            },
          ),
        ],
      ),
    );
  }
}
