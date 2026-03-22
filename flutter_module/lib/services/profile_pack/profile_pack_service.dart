import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../generated/profile_pack_bridge.g.dart';
import 'profile_manifest.dart';

/// Service for downloading and installing profile packs.
class ProfilePackService {
  static const _manifestUrl =
      'https://raw.githubusercontent.com/eatsome-webapp/soul-terminal/master/profile-packs/manifest.json';
  static const _downloadDir = '/data/data/com.soul.terminal/cache/profile-packs';
  static const _manifestCachePath = '/data/data/com.soul.terminal/cache/profile-packs/manifest-cache.json';

  final _logger = Logger();
  final _bridge = ProfilePackBridgeApi();

  /// Fetch the profile manifest from GitHub.
  Future<ProfileManifest> fetchManifest() async {
    final response = await http.get(Uri.parse(_manifestUrl));
    if (response.statusCode != 200) {
      throw Exception('Manifest ophalen mislukt (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ProfileManifest.fromJson(json);
  }

  /// Download a profile pack zip with progress callback.
  /// Returns the local file path of the downloaded zip.
  Future<String> downloadPack(
    ProfileEntry profile,
    void Function(double progress) onProgress,
  ) async {
    final dir = Directory(_downloadDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final filePath = '$_downloadDir/${profile.id}-${profile.version}.zip';
    final file = File(filePath);

    final request = http.Request('GET', Uri.parse(profile.url));
    final streamedResponse = await request.send();

    if (streamedResponse.statusCode != 200) {
      throw Exception('Download mislukt (${streamedResponse.statusCode})');
    }

    final totalBytes = streamedResponse.contentLength ?? profile.sizeBytes;
    var receivedBytes = 0;

    final sink = file.openWrite();
    await for (final chunk in streamedResponse.stream) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress(receivedBytes / totalBytes);
      }
    }
    await sink.close();

    _logger.i('Downloaded ${profile.id} pack: ${receivedBytes ~/ 1024} KB');
    return filePath;
  }

  /// Full install flow: verify SHA-256 + extract over $PREFIX.
  Future<void> installPack(ProfileEntry profile, String zipPath) async {
    // Verify checksum
    final valid = await _bridge.verifySha256(zipPath, profile.sha256);
    if (!valid) {
      // Clean up bad download
      File(zipPath).deleteSync();
      throw Exception('SHA-256 verificatie mislukt — download is corrupt');
    }

    // Extract over $PREFIX
    final error = await _bridge.extractProfilePack(
      zipPath,
      profile.id,
      profile.version,
    );
    if (error != null) {
      throw Exception(error);
    }
  }

  /// Check if a profile is already installed.
  Future<String?> getInstalledVersion(String profileId) async {
    return _bridge.getInstalledProfileVersion(profileId);
  }

  /// Check for interrupted installation (crash recovery).
  Future<String?> getInterruptedInstallation() async {
    return _bridge.getInterruptedInstallation();
  }

  /// Cache manifest to local file for offline/background access.
  Future<void> cacheManifest(ProfileManifest manifest) async {
    try {
      final file = File(_manifestCachePath);
      final dir = file.parent;
      if (!dir.existsSync()) dir.createSync(recursive: true);
      // Re-serialize from the parsed model
      final json = {
        'schemaVersion': manifest.schemaVersion,
        'profiles': manifest.profiles.map((p) => <String, dynamic>{
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'icon': p.icon,
          'version': p.version,
          'minBootstrapVersion': p.minBootstrapVersion,
          'arch': p.arch,
          'sizeBytes': p.sizeBytes,
          'sha256': p.sha256,
          'url': p.url,
        }).toList(),
      };
      await file.writeAsString(jsonEncode(json));
      _logger.i('Manifest cached to $_manifestCachePath');
    } catch (e) {
      _logger.e('Failed to cache manifest: $e');
    }
  }

  /// Load manifest from local cache. Returns null if no cache exists.
  Future<ProfileManifest?> loadCachedManifest() async {
    try {
      final file = File(_manifestCachePath);
      if (!file.existsSync()) return null;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ProfileManifest.fromJson(json);
    } catch (e) {
      _logger.e('Failed to load cached manifest: $e');
      return null;
    }
  }

  /// Check which installed profiles have updates available.
  /// Returns a map of profileId -> remoteVersion for profiles with updates.
  Future<Map<String, String>> checkForUpdates() async {
    final manifest = await fetchManifest();
    await cacheManifest(manifest);

    final updates = <String, String>{};
    for (final profile in manifest.profiles) {
      if (!profile.isAvailable) continue;
      final localVersion = await getInstalledVersion(profile.id);
      if (localVersion == null) continue; // Not installed, skip
      if (ProfileEntry.isNewer(profile.version, localVersion)) {
        updates[profile.id] = profile.version;
        _logger.i('Update available for ${profile.id}: $localVersion -> ${profile.version}');
      }
    }
    return updates;
  }

  /// Read installed profile version directly from marker file.
  /// Works in any isolate (no Pigeon bridge needed).
  static String? readInstalledVersionFromFile(String profileId) {
    try {
      final markerPath = '/data/data/com.soul.terminal/files/usr/.soul-profile-$profileId';
      final file = File(markerPath);
      if (!file.existsSync()) return null;
      return file.readAsStringSync().trim();
    } catch (e) {
      return null;
    }
  }
}
