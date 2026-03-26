import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String searchQuery;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.searchQuery,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blocked = task.isBlocked;
    final mutedText = theme.colorScheme.onSurface.withValues(alpha: 0.72);
    final statusColor = _statusColor(task.status);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: blocked ? 0.76 : 1,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF14213A),
                const Color(0xFF0F1930),
              ],
            ),
            border: Border.all(
              color: blocked
                  ? theme.colorScheme.error.withValues(alpha: 0.55)
                  : theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildHighlightedTitle(theme)),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      color: const Color(0xFF141F35),
                      iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                const SizedBox(height: 10),
                Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: mutedText),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 16, color: mutedText),
                    const SizedBox(width: 7),
                    Text(
                      DateFormat.yMMMd().format(task.dueDate),
                      style: theme.textTheme.bodyMedium?.copyWith(color: mutedText),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        task.status.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (blocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Blocked by another task',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return const Color(0xFFA3B1CD);
      case TaskStatus.inProgress:
        return const Color(0xFFFFB454);
      case TaskStatus.done:
        return const Color(0xFF2EE6D6);
    }
  }

  Widget _buildHighlightedTitle(ThemeData theme) {
    final title = task.title;
    final query = searchQuery.trim();

    if (query.isEmpty) {
      return Text(title, style: theme.textTheme.titleMedium);
    }

    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerTitle.indexOf(lowerQuery);

    if (matchStart < 0) {
      return Text(title, style: theme.textTheme.titleMedium);
    }

    final matchEnd = matchStart + query.length;

    return RichText(
      text: TextSpan(
        style: theme.textTheme.titleMedium,
        children: [
          TextSpan(text: title.substring(0, matchStart)),
          TextSpan(
            text: title.substring(matchStart, matchEnd),
            style: TextStyle(
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.32),
              color: const Color(0xFFFFFFFF),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: title.substring(matchEnd)),
        ],
      ),
    );
  }
}
