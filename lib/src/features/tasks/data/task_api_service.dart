import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';

class TaskApiService {
  final http.Client _client;

  TaskApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Task>> fetchTasks({String query = '', TaskStatus? status}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/tasks/').replace(
      queryParameters: {
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (status != null) 'status': status.apiValue,
      },
    );

    final response = await _send(() => _client.get(uri).timeout(ApiConstants.requestTimeout));
    final decoded = _decodeResponse(response);

    final rawList = decoded is List
        ? decoded
        : (decoded['results'] as List<dynamic>? ?? <dynamic>[]);

    return rawList
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Task> createTask(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/tasks/');
    final response = await _send(
      () => _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    final decoded = _decodeResponse(response);
    return Task.fromJson(decoded as Map<String, dynamic>);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/tasks/$id/');
    final response = await _send(
      () => _client
          .patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(ApiConstants.requestTimeout),
    );

    final decoded = _decodeResponse(response);
    return Task.fromJson(decoded as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/tasks/$id/');
    final response = await _send(() => _client.delete(uri).timeout(ApiConstants.requestTimeout));

    if (response.statusCode != 204) {
      final decoded = _tryDecodeBody(response.body);
      final detail = decoded is Map<String, dynamic>
          ? (decoded['detail'] as String? ?? 'Delete request failed')
          : 'Delete request failed';
      throw ApiException(detail, statusCode: response.statusCode);
    }
  }

  dynamic _decodeResponse(http.Response response) {
    final decoded = _tryDecodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed';
      if (decoded is Map<String, dynamic>) {
        message = (decoded['detail'] as String?) ??
            (decoded['message'] as String?) ??
            'Request failed';
      }
      throw ApiException(message, statusCode: response.statusCode);
    }

    return decoded;
  }

  dynamic _tryDecodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(body);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw ApiException(
        'Request timed out. Verify backend is running and API_BASE_URL points to a reachable host.',
      );
    } on SocketException {
      throw ApiException(
        'Unable to connect to backend at ${ApiConstants.baseUrl}. '
        'If running on a real device, pass --dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:8000/api.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('HTTP client error: ${error.message}');
    }
  }
}
