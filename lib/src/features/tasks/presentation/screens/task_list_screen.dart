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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.22),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.14),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              const _SearchAndFilterRow(),
              const SizedBox(height: 8),
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
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 108),
                        itemCount: provider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = provider.tasks[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 180 + (index * 35)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TaskCard(
                                task: task,
                                searchQuery: provider.searchQuery,
                                onEdit: () => _openEditTask(task),
                                onDelete: () => _confirmDelete(task),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : _openCreateTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w700)),
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
    final theme = Theme.of(context);
    _controller.value = TextEditingValue(
      text: provider.searchQuery,
      selection: TextSelection.collapsed(offset: provider.searchQuery.length),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search by title',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  suffixIcon: provider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onChanged: (value) {
                  provider.setSearchQuery(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF121C30),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
              ),
              child: DropdownButton<TaskStatus?>(
                value: provider.statusFilter,
                underline: const SizedBox.shrink(),
                dropdownColor: const Color(0xFF121C30),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
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
            ),
          ],
        ),
      ),
    );
  }
}
