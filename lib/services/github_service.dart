import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';

class GitHubService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'github_pat';
  static const _cacheKey = 'github_projects_cache_v2';
  static const username = 'muzan204';

  final http.Client _client = http.Client();

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
      'User-Agent': 'Coucou-Projects-Hub/Android',
      'Cache-Control': 'no-cache',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<List<ProjectRepo>> loadProjects() async {
    final token = await readToken();
    final hasToken = token != null && token.isNotEmpty;

    final uri = hasToken
        ? Uri.parse(
            'https://api.github.com/user/repos?per_page=100&sort=updated&affiliation=owner',
          )
        : Uri.parse(
            'https://api.github.com/users/$username/repos?per_page=100&sort=updated',
          );

    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final repos = _parseProjects(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, response.body);

        return repos;
      }

      if (hasToken &&
          (response.statusCode == 401 || response.statusCode == 403)) {
        throw Exception(
          'Token do GitHub sem acesso ou inválido. Revise o Fine-grained PAT em Ajustes.',
        );
      }

      if (response.statusCode == 403) {
        final remaining = response.headers['x-ratelimit-remaining'];
        if (remaining == '0') {
          return await _cachedOrFallback();
        }
      }

      return await _cachedOrFallback();
    } catch (_) {
      return await _cachedOrFallback();
    }
  }

  List<ProjectRepo> _parseProjects(List<dynamic> data) {
    return data
        .map(
          (item) => ProjectRepo.fromJson(
            (item as Map).cast<String, dynamic>(),
          ),
        )
        .where(
          (repo) =>
              repo.fullName.toLowerCase().startsWith('$username/'),
        )
        .toList();
  }

  Future<List<ProjectRepo>> _cachedOrFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);

    if (cached != null && cached.isNotEmpty) {
      try {
        final data = jsonDecode(cached) as List<dynamic>;
        final repos = _parseProjects(data);
        if (repos.isNotEmpty) return repos;
      } catch (_) {}
    }

    return _publicFallback();
  }

  List<ProjectRepo> _publicFallback() {
    const avatar =
        'https://avatars.githubusercontent.com/u/212942270?v=4';

    const repos = [
      ['1174886409','projeto-portifolio-basc','main'],
      ['1204316783','calculadora.basc','main'],
      ['1238086047','techgear-cart','master'],
      ['1238093171','carrinho','main'],
      ['1238406742','Ayumi','main'],
      ['1239180404','login-fullstack','main'],
      ['1239209082','framer-motion-demo','main'],
      ['1239230838','mini-loja-netflix-react','main'],
      ['1240161186','cruzadinha-tech','main'],
      ['1240231531','minha-primeira-linha-de-montagem','main'],
      ['1251661369','cyberquiz','main'],
      ['1265599639','Ecotech','main'],
      ['1270609885','klass-sistema-escolar','main'],
      ['1315500204','projeto-x','main'],
      ['1361989067','chatbot','main'],
      ['1362541597','Rpg-de_programa-o','main'],
      ['1380305696','chatflow','main'],
      ['1380463584','muzan204','main'],
      ['1394150691','coucou-android','main'],
    ];

    return repos.map((item) {
      final name = item[1];
      return ProjectRepo(
        id: int.tryParse(item[0]) ?? 0,
        name: name,
        fullName: '$username/$name',
        description:
            'Projeto público do GitHub. Conecte o GitHub para carregar descrição e metadados atualizados.',
        htmlUrl: 'https://github.com/$username/$name',
        cloneUrl: 'https://github.com/$username/$name.git',
        branch: item[2],
        language: 'Projeto',
        homepage: '',
        visibility: 'public',
        updatedAt: '',
        ownerAvatar: avatar,
      );
    }).toList();
  }

  Future<ApkRelease?> latestApk(ProjectRepo repo) async {
    final uri = Uri.parse(
      'https://api.github.com/repos/${repo.fullName}/releases/latest',
    );

    try {
      final response = await _client
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) return null;

      final data =
          (jsonDecode(response.body) as Map).cast<String, dynamic>();
      final assets = (data['assets'] as List? ?? const []);

      for (final raw in assets) {
        final item = (raw as Map).cast<String, dynamic>();
        final name = item['name']?.toString() ?? '';

        if (name.toLowerCase().endsWith('.apk')) {
          return ApkRelease(
            tag: data['tag_name']?.toString() ?? 'release',
            name: name,
            downloadUrl:
                item['browser_download_url']?.toString() ?? '',
            size: (item['size'] as num?)?.toInt() ?? 0,
          );
        }
      }
    } catch (_) {}

    return null;
  }

  void dispose() {
    _client.close();
  }
}
