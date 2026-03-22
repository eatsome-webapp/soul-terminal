/// Data model for profile pack manifest.
class ProfileManifest {
  final int schemaVersion;
  final List<ProfileEntry> profiles;

  const ProfileManifest({required this.schemaVersion, required this.profiles});

  factory ProfileManifest.fromJson(Map<String, dynamic> json) {
    return ProfileManifest(
      schemaVersion: json['schemaVersion'] as int,
      profiles: (json['profiles'] as List)
          .map((entry) => ProfileEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileEntry {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String version;
  final String minBootstrapVersion;
  final String arch;
  final int sizeBytes;
  final String sha256;
  final String url;

  const ProfileEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.version,
    required this.minBootstrapVersion,
    required this.arch,
    required this.sizeBytes,
    required this.sha256,
    required this.url,
  });

  factory ProfileEntry.fromJson(Map<String, dynamic> json) {
    return ProfileEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? 'terminal',
      version: json['version'] as String,
      minBootstrapVersion: json['minBootstrapVersion'] as String? ?? '1',
      arch: json['arch'] as String? ?? 'aarch64',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      sha256: json['sha256'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  bool get isAvailable => url.isNotEmpty && sha256.isNotEmpty;

  String get sizeMb => (sizeBytes / 1024 / 1024).toStringAsFixed(0);
}
