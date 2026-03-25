import '../domain/task.dart';
import '../domain/task_status.dart';
import 'task_api_service.dart';

class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository(this._apiService);

  Future<List<Task>> getTasks({String query = '', TaskStatus? status}) {
    return _apiService.fetchTasks(query: query, status: status);
  }

  Future<Task> createTask(Map<String, dynamic> payload) {
    return _apiService.createTask(payload);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> payload) {
    return _apiService.updateTask(id, payload);
  }

  Future<void> deleteTask(int id) {
    return _apiService.deleteTask(id);
  }
}
