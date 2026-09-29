import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdate {
  final int build;
  final String version;
  final String apkUrl;
  final String notes;

  const AppUpdate({
    required this.build,
    required this.version,
    required this.apkUrl,
    required this.notes,
  });
}

class UpdateService {
  static const repo = 'muzan204/coucou-android';
  static const releaseApi = 'https://api.github.com/repos/$repo/releases/tags/coucou-latest';

  Future<AppUpdate?> check() async {
    final current = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(current.buildNumber) ?? 0;

    final release = await http.get(
      Uri.parse(releaseApi),
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (release.statusCode != 200) return null;
    final data = (jsonDecode(release.body) as Map).cast<String, dynamic>();
    final assets = (data['assets'] as List? ?? const []);

    String? metadataUrl;
    String? apkUrl;

    for (final raw in assets) {
      final asset = (raw as Map).cast<String, dynamic>();
      final name = asset['name']?.toString() ?? '';
      if (name == 'version.json') {
        metadataUrl = asset['browser_download_url']?.toString();
      } else if (name == 'coucou-latest.apk') {
        apkUrl = asset['browser_download_url']?.toString();
      }
    }

    if (metadataUrl == null || apkUrl == null) return null;

    final metadata = await http.get(Uri.parse(metadataUrl));
    if (metadata.statusCode != 200) return null;

    final meta = (jsonDecode(metadata.body) as Map).cast<String, dynamic>();
    final latestBuild = (meta['build'] as num?)?.toInt() ?? 0;
    if (latestBuild <= currentBuild) return null;

    return AppUpdate(
      build: latestBuild,
      version: meta['version']?.toString() ?? 'nova',
      apkUrl: apkUrl,
      notes: meta['notes']?.toString() ?? 'Nova versão disponível.',
    );
  }

  Future<void> downloadAndInstall(
    AppUpdate update, {
    void Function(double value)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(update.apkUrl));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Falha ao baixar APK: HTTP ${response.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/coucou-update.apk');
    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    var received = 0;

    await for (final chunk in response.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (total > 0 && onProgress != null) {
        onProgress(received / total);
      }
    }

    await sink.flush();
    await sink.close();

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type.name != 'done') {
      throw Exception('Não foi possível abrir o instalador: ${result.message}');
    }
  }
}
