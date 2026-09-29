class ProjectRepo {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final String cloneUrl;
  final String branch;
  final String language;
  final String homepage;
  final String visibility;
  final String updatedAt;
  final String ownerAvatar;

  const ProjectRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.cloneUrl,
    required this.branch,
    required this.language,
    required this.homepage,
    required this.visibility,
    required this.updatedAt,
    required this.ownerAvatar,
  });

  bool get isPrivate => visibility == 'private';
  bool get hasSite => homepage.trim().isNotEmpty;
  String get socialPreview => 'https://opengraph.githubassets.com/coucou/$fullName';

  factory ProjectRepo.fromJson(Map<String, dynamic> json) {
    final owner = (json['owner'] as Map?)?.cast<String, dynamic>() ?? const {};
    return ProjectRepo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Projeto',
      fullName: json['full_name']?.toString() ?? '',
      description: json['description']?.toString() ?? 'Sem descrição.',
      htmlUrl: json['html_url']?.toString() ?? '',
      cloneUrl: json['clone_url']?.toString() ?? '',
      branch: json['default_branch']?.toString() ?? 'main',
      language: json['language']?.toString() ?? 'Projeto',
      homepage: json['homepage']?.toString() ?? '',
      visibility: json['visibility']?.toString() ??
          ((json['private'] == true) ? 'private' : 'public'),
      updatedAt: json['updated_at']?.toString() ?? '',
      ownerAvatar: owner['avatar_url']?.toString() ?? '',
    );
  }
}

class ApkRelease {
  final String tag;
  final String name;
  final String downloadUrl;
  final int size;

  const ApkRelease({
    required this.tag,
    required this.name,
    required this.downloadUrl,
    required this.size,
  });
}
