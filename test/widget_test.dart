import 'package:flutter_test/flutter_test.dart';

import 'package:task_management_app/src/app.dart';

void main() {
  testWidgets('App shell renders task list screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagementApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('No tasks yet. Add your first task.'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}
