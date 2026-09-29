import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';

class TermuxService {
  static const base = 'http://127.0.0.1:8766';

  Future<bool> ping() async {
    try {
      final response = await http.get(Uri.parse('$base/ping')).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> status(ProjectRepo repo) => _post('/project/status', {
        'name': repo.name,
        'cloneUrl': repo.cloneUrl,
        'branch': repo.branch,
      });

  Future<Map<String, dynamic>> clone(ProjectRepo repo) => _post('/project/clone', {
        'name': repo.name,
        'cloneUrl': repo.cloneUrl,
        'branch': repo.branch,
      });

  Future<Map<String, dynamic>> pull(ProjectRepo repo) => _post('/project/pull', {
        'name': repo.name,
        'cloneUrl': repo.cloneUrl,
        'branch': repo.branch,
      });

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse('$base$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 60));
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : (jsonDecode(response.body) as Map).cast<String, dynamic>();
    if (response.statusCode >= 400) {
      throw Exception(body['error'] ?? 'Falha no Termux (${response.statusCode})');
    }
    return body;
  }
}
