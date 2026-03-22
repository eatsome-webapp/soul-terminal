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

  /// Compare two version strings in format "YYYY.MM.DD-rN".
  /// Returns negative if a < b, zero if equal, positive if a > b.
  /// Handles: 2026.03.22-r1 < 2026.03.22-r2 < 2026.03.22-r10 < 2026.04.01-r1
  static int compareVersions(String a, String b) {
    final partsA = a.split('-r');
    final partsB = b.split('-r');

    // Compare date portion (string compare works for YYYY.MM.DD with zero-padding)
    final dateCompare = partsA[0].compareTo(partsB[0]);
    if (dateCompare != 0) return dateCompare;

    // Compare revision number numerically
    final revA = partsA.length > 1 ? int.tryParse(partsA[1]) ?? 0 : 0;
    final revB = partsB.length > 1 ? int.tryParse(partsB[1]) ?? 0 : 0;
    return revA.compareTo(revB);
  }

  /// Returns true if [remoteVersion] is newer than [localVersion].
  static bool isNewer(String remoteVersion, String localVersion) {
    return compareVersions(remoteVersion, localVersion) > 0;
  }
}
