import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/system_bridge.g.dart',
  javaOut: '../app/src/main/java/com/termux/bridge/SystemBridgeApi.java',
  javaOptions: JavaOptions(package: 'com.termux.bridge'),
))

/// Device hardware and OS information.
class DeviceInfo {
  DeviceInfo({
    required this.manufacturer,
    required this.model,
    required this.androidVersion,
    required this.sdkInt,
  });

  final String manufacturer;
  final String model;
  final String androidVersion;
  final int sdkInt;
}

/// App package and build information.
class PackageInfo {
  PackageInfo({
    required this.packageName,
    required this.versionName,
    required this.versionCode,
  });

  final String packageName;
  final String versionName;
  final int versionCode;
}

/// Host API: Flutter calls these methods, Java implements them.
/// Provides device and app metadata.
@HostApi()
abstract class SystemBridgeApi {
  /// Get device hardware and OS information.
  DeviceInfo getDeviceInfo();

  /// Get app package and version information.
  PackageInfo getPackageInfo();
}
