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
}
