enum TaskStatus { toDo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get apiValue {
    switch (this) {
      case TaskStatus.toDo:
        return 'TO_DO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.toDo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromApi(String value) {
    return switch (value) {
      'TO_DO' => TaskStatus.toDo,
      'IN_PROGRESS' => TaskStatus.inProgress,
      'DONE' => TaskStatus.done,
      _ => TaskStatus.toDo,
    };
  }
}
