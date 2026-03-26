import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:task_management_app/src/features/tasks/data/task_api_service.dart';
import 'package:task_management_app/src/features/tasks/data/task_repository.dart';
import 'package:task_management_app/src/features/tasks/domain/task.dart';
import 'package:task_management_app/src/features/tasks/domain/task_status.dart';
import 'package:task_management_app/src/features/tasks/presentation/providers/task_form_draft_provider.dart';
import 'package:task_management_app/src/features/tasks/presentation/providers/task_list_provider.dart';
import 'package:task_management_app/src/features/tasks/presentation/screens/task_list_screen.dart';

class _FakeTaskRepository extends TaskRepository {
  _FakeTaskRepository() : super(TaskApiService());

  @override
  Future<List<Task>> getTasks({String query = '', TaskStatus? status}) async {
    return <Task>[];
  }

  @override
  Future<Task> createTask(Map<String, dynamic> payload) {
    throw UnimplementedError();
  }

  @override
  Future<Task> updateTask(int id, Map<String, dynamic> payload) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTask(int id) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('App shell renders task list screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskListProvider>(
            create: (_) => TaskListProvider(repository: _FakeTaskRepository()),
          ),
          ChangeNotifierProvider<TaskFormDraftProvider>(
            create: (_) => TaskFormDraftProvider(),
          ),
        ],
        child: const MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('No tasks yet. Add your first task.'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}
