import 'task_status.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final int? blockedBy;
  final bool isBlocked;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.blockedBy,
    required this.isBlocked,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedBy,
    bool clearBlockedBy = false,
    bool? isBlocked,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: clearBlockedBy ? null : blockedBy ?? this.blockedBy,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: TaskStatusX.fromApi(json['status'] as String),
      blockedBy: json['blocked_by'] as int?,
      isBlocked: (json['is_blocked'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T').first,
      'status': status.apiValue,
      'blocked_by': blockedBy,
      'is_blocked': isBlocked,
    };
  }
}
