import '../entities/settings_entity.dart';

/// Contract for remote application preference synchronization.
/// 
/// Responsibilities include uploading/downloading non-sensitive preferences
/// and resolving conflicts between local and remote state.
abstract class SettingsRemoteDatasource {
  /// Uploads the current settings entity to the remote server.
  Future<void> upload(SettingsEntity settings);

  /// Downloads the current settings from the remote server.
  Future<SettingsEntity> download();

  /// Executes a full bidirectional synchronization.
  Future<void> synchronize();
}
