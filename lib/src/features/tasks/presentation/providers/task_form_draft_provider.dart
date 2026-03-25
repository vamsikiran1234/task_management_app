import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/task_status.dart';

class TaskFormDraftProvider extends ChangeNotifier {
  static const String _titleKey = 'draft_title';
  static const String _descriptionKey = 'draft_description';
  static const String _dueDateKey = 'draft_due_date';
  static const String _statusKey = 'draft_status';
  static const String _blockedByKey = 'draft_blocked_by';

  String title = '';
  String description = '';
  DateTime? dueDate;
  TaskStatus status = TaskStatus.toDo;
  int? blockedBy;

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    title = prefs.getString(_titleKey) ?? '';
    description = prefs.getString(_descriptionKey) ?? '';
    final rawDate = prefs.getString(_dueDateKey);
    dueDate = rawDate == null ? null : DateTime.tryParse(rawDate);
    final rawStatus = prefs.getString(_statusKey);
    if (rawStatus != null) {
      status = TaskStatusX.fromApi(rawStatus);
    }
    blockedBy = prefs.getInt(_blockedByKey);
    notifyListeners();
  }

  Future<void> setTitle(String value) async {
    title = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_titleKey, value);
  }

  Future<void> setDescription(String value) async {
    description = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_descriptionKey, value);
  }

  Future<void> setDueDate(DateTime? value) async {
    dueDate = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_dueDateKey);
      return;
    }
    await prefs.setString(_dueDateKey, value.toIso8601String());
  }

  Future<void> setStatus(TaskStatus value) async {
    status = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, value.apiValue);
  }

  Future<void> setBlockedBy(int? value) async {
    blockedBy = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_blockedByKey);
      return;
    }
    await prefs.setInt(_blockedByKey, value);
  }

  Future<void> clearDraft() async {
    title = '';
    description = '';
    dueDate = null;
    status = TaskStatus.toDo;
    blockedBy = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_titleKey);
    await prefs.remove(_descriptionKey);
    await prefs.remove(_dueDateKey);
    await prefs.remove(_statusKey);
    await prefs.remove(_blockedByKey);
  }
}
