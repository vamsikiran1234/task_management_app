import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/tasks/data/task_api_service.dart';
import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/providers/task_form_draft_provider.dart';
import 'features/tasks/presentation/providers/task_list_provider.dart';
import 'features/tasks/presentation/screens/task_list_screen.dart';

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = TaskRepository(TaskApiService());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskListProvider>(
          create: (_) => TaskListProvider(repository: repository),
        ),
        ChangeNotifierProvider<TaskFormDraftProvider>(
          create: (_) => TaskFormDraftProvider()..loadDraft(),
        ),
      ],
      child: MaterialApp(
        title: 'Flodo Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const TaskListScreen(),
      ),
    );
  }
}
