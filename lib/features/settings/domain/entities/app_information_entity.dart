class AppInformationEntity {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String releaseChannel; // Stable, Beta, Alpha
  final String environment;    // Production, Staging, Development
  final DateTime buildDate;
  final String minimumSupportedVersion;

  AppInformationEntity({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.releaseChannel = 'Stable',
    this.environment = 'Production',
    required this.buildDate,
    this.minimumSupportedVersion = '1.0.0',
  });
}
