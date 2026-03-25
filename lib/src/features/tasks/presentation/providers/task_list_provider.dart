import 'package:flutter/material.dart';

import '../../data/task_repository.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskListProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskListProvider({required TaskRepository repository}) : _repository = repository;

  final List<Task> _tasks = <Task>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  bool _isMutating = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  bool get isMutating => _isMutating;

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTasks(
        query: _searchQuery,
        status: _statusFilter,
      );
      _tasks
        ..clear()
        ..addAll(result);
    } catch (error) {
      _errorMessage = _extractErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String value) async {
    _searchQuery = value;
    await loadTasks();
  }

  Future<void> setStatusFilter(TaskStatus? value) async {
    _statusFilter = value;
    await loadTasks();
  }

  Future<void> createTask(Map<String, dynamic> payload) async {
    _isMutating = true;
    notifyListeners();

    try {
      await _repository.createTask(payload);
      await loadTasks();
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> payload) async {
    _isMutating = true;
    notifyListeners();

    try {
      await _repository.updateTask(id, payload);
      await loadTasks();
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    _isMutating = true;
    notifyListeners();

    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  String _extractErrorMessage(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
