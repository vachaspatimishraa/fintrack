class SchemaVersionManager {
  static const int currentSchemaVersion = 1;

  static bool checkSchemaMatch(int modelVersion) {
    return modelVersion == currentSchemaVersion;
  }
}
