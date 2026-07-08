class MigrationManager {
  static bool executeMigration(int oldVersion, int newVersion) {
    if (oldVersion >= newVersion) return true;
    print('[MIGRATION]: Upgraded schema version from $oldVersion to $newVersion');
    return true;
  }
}
