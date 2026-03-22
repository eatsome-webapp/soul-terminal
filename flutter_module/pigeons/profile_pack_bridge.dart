import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/profile_pack_bridge.g.dart',
  javaOut: '../app/src/main/java/com/termux/bridge/ProfilePackBridgeApi.java',
  javaOptions: JavaOptions(package: 'com.termux.bridge'),
))

/// Host API: Flutter calls these methods, Java implements them.
/// Handles profile pack extraction and verification.
@HostApi()
abstract class ProfilePackBridgeApi {
  /// Extract a profile pack zip over $PREFIX.
  /// Returns null on success, error message on failure.
  String? extractProfilePack(String zipFilePath, String profileId, String version);

  /// Verify SHA-256 checksum of a downloaded file.
  bool verifySha256(String filePath, String expectedHash);

  /// Get installed profile pack version, or null if not installed.
  String? getInstalledProfileVersion(String profileId);

  /// Check if a profile pack installation was interrupted (crash recovery).
  String? getInterruptedInstallation();
}
