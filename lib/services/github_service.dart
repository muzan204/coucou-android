import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/project.dart';

class GitHubService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'github_pat';
  static const username = 'muzan204';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) async {
    final clean = token.trim();
    if (clean.isEmpty) {
      await _storage.delete(key: _tokenKey);
    } else {
      await _storage.write(key: _tokenKey, value: clean);
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await readToken();
    return {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProjectRepo>> loadProjects() async {
    final token = await readToken();
    final uri = token == null || token.isEmpty
        ? Uri.parse('https://api.github.com/users/$username/repos?per_page=100&sort=updated')
        : Uri.parse('https://api.github.com/user/repos?per_page=100&sort=updated&affiliation=owner');
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode != 200) {
      throw Exception('GitHub respondeu ${response.statusCode}. Verifique sua conexão/token.');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ProjectRepo.fromJson((e as Map).cast<String, dynamic>()))
        .where((e) => e.fullName.toLowerCase().startsWith('$username/'))
        .toList();
  }

  Future<ApkRelease?> latestApk(ProjectRepo repo) async {
    final uri = Uri.parse('https://api.github.com/repos/${repo.fullName}/releases/latest');
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) return null;
    final data = (jsonDecode(response.body) as Map).cast<String, dynamic>();
    final assets = (data['assets'] as List? ?? const []);
    for (final raw in assets) {
      final item = (raw as Map).cast<String, dynamic>();
      final name = item['name']?.toString() ?? '';
      if (name.toLowerCase().endsWith('.apk')) {
        return ApkRelease(
          tag: data['tag_name']?.toString() ?? 'release',
          name: name,
          downloadUrl: item['browser_download_url']?.toString() ?? '',
          size: (item['size'] as num?)?.toInt() ?? 0,
        );
      }
    }
    return null;
  }
}
