import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_remote_datasource.dart';

/// Supabase-backed implementation of [SettingsRemoteDatasource].
class SettingsRemoteDatasourceImpl implements SettingsRemoteDatasource {
  final SupabaseClient supabase;

  SettingsRemoteDatasourceImpl(this.supabase);

  @override
  Future<void> upload(SettingsEntity settings) async {
    // Logic to upsert settings to 'user_preferences' table in Supabase
    // Ensure sensitive data (PIN, tokens) is filtered out in Mapper
  }

  @override
  Future<SettingsEntity> download() async {
    // Logic to fetch settings from Supabase
    return SettingsEntity(); // Return current local if none found remotely
  }

  @override
  Future<void> synchronize() async {
    await download();
    // Conflict resolution logic: updatedAt wins
  }
}
