import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocked = task.isBlocked;

    return Opacity(
      opacity: blocked ? 0.65 : 1,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          title: Text(task.title, style: theme.textTheme.titleMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task.description),
                const SizedBox(height: 8),
                Text('Due: ${DateFormat.yMMMd().format(task.dueDate)}'),
                if (blocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Blocked by another task'),
                  ),
              ],
            ),
          ),
          trailing: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text(task.status.label)),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                    return;
                  }
                  onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
