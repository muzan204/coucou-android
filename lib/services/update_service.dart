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
  final String currentVersion;
  final int currentBuild;

  const AppUpdate({
    required this.build,
    required this.version,
    required this.apkUrl,
    required this.notes,
    required this.currentVersion,
    required this.currentBuild,
  });
}

class UpdateStatus {
  final String currentVersion;
  final int currentBuild;
  final String latestVersion;
  final int latestBuild;
  final AppUpdate? update;
  final String message;

  const UpdateStatus({
    required this.currentVersion,
    required this.currentBuild,
    required this.latestVersion,
    required this.latestBuild,
    required this.update,
    required this.message,
  });
}

class UpdateService {
  static const repo = 'muzan204/coucou-android';
  static const releaseApi =
      'https://api.github.com/repos/$repo/releases/tags/coucou-latest';

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      };

  Future<AppUpdate?> check() async {
    return (await checkDetailed()).update;
  }

  Future<UpdateStatus> checkDetailed() async {
    final current = await PackageInfo.fromPlatform();
    final currentVersion = current.version;
    final currentBuild = int.tryParse(current.buildNumber) ?? 0;

    final releaseUri = Uri.parse(releaseApi).replace(
      queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    final release = await _client.get(
      releaseUri,
      headers: _headers,
    );

    if (release.statusCode != 200) {
      throw Exception(
        'Não consegui consultar a atualização no GitHub. HTTP ${release.statusCode}',
      );
    }

    final data = (jsonDecode(release.body) as Map).cast<String, dynamic>();
    final releaseName = data['name']?.toString() ?? '';
    final tag = data['tag_name']?.toString() ?? '';
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

    if (apkUrl == null || apkUrl.isEmpty) {
      throw Exception('A Release não possui coucou-latest.apk.');
    }

    var latestVersion = _versionFromReleaseName(releaseName);
    var latestBuild = _buildFromVersion(latestVersion);
    var notes = 'Nova versão do Coucou disponível.';

    if (metadataUrl != null && metadataUrl.isNotEmpty) {
      try {
        final metadataUri = Uri.parse(metadataUrl).replace(
          queryParameters: {
            't': DateTime.now().millisecondsSinceEpoch.toString(),
          },
        );

        final metadata = await _client.get(
          metadataUri,
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        );

        if (metadata.statusCode == 200) {
          final meta =
              (jsonDecode(metadata.body) as Map).cast<String, dynamic>();

          final jsonVersion = meta['version']?.toString();
          final jsonBuild = (meta['build'] as num?)?.toInt();

          if (jsonVersion != null && jsonVersion.isNotEmpty) {
            latestVersion = jsonVersion;
          }

          if (jsonBuild != null && jsonBuild > 0) {
            latestBuild = jsonBuild;
          } else {
            latestBuild = _buildFromVersion(latestVersion);
          }

          notes = meta['notes']?.toString() ?? notes;
        }
      } catch (_) {
        // Fallback para o nome da Release.
      }
    }

    if (latestVersion.isEmpty) {
      latestVersion = tag == 'coucou-latest' ? 'desconhecida' : tag;
    }

    final newerByBuild = latestBuild > currentBuild;
    final newerByVersion = _compareVersions(
          latestVersion,
          currentVersion,
        ) >
        0;

    final hasUpdate = newerByBuild || newerByVersion;

    final update = hasUpdate
        ? AppUpdate(
            build: latestBuild,
            version: latestVersion,
            apkUrl: Uri.parse(apkUrl).replace(
              queryParameters: {
                'build': latestBuild.toString(),
                't': DateTime.now().millisecondsSinceEpoch.toString(),
              },
            ).toString(),
            notes: notes,
            currentVersion: currentVersion,
            currentBuild: currentBuild,
          )
        : null;

    return UpdateStatus(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      latestVersion: latestVersion,
      latestBuild: latestBuild,
      update: update,
      message: hasUpdate
          ? 'Nova versão $latestVersion disponível.'
          : 'Você já está na versão mais recente.',
    );
  }

  String _versionFromReleaseName(String name) {
    final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(name);
    return match?.group(1) ?? '';
  }

  int _buildFromVersion(String version) {
    final parts = version.split('.');
    if (parts.length < 3) return 0;
    return int.tryParse(parts.last) ?? 0;
  }

  int _compareVersions(String a, String b) {
    final aa = a
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList(growable: true);
    final bb = b
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList(growable: true);

    while (aa.length < 3) {
      aa.add(0);
    }

    while (bb.length < 3) {
      bb.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (aa[i] != bb[i]) return aa[i].compareTo(bb[i]);
    }

    return 0;
  }

  Future<void> downloadAndInstall(
    AppUpdate update, {
    void Function(double value)? onProgress,
  }) async {
    final request = http.Request(
      'GET',
      Uri.parse(update.apkUrl),
    );

    request.headers.addAll({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
    });

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao baixar APK: HTTP ${response.statusCode}',
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/coucou-update-${update.build}.apk',
    );

    if (await file.exists()) {
      await file.delete();
    }

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

    if (!await file.exists() || await file.length() == 0) {
      throw Exception('O APK baixado ficou vazio.');
    }

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type.name != 'done') {
      throw Exception(
        'Não foi possível abrir o instalador: ${result.message}',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
