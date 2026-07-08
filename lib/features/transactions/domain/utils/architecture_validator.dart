class ArchitectureValidator {
  static bool validateImportDependency(String currentFilePath, String importedFilePath) {
    // Presentation layer should never import datasources directly
    if (currentFilePath.contains('presentation') && importedFilePath.contains('datasources')) {
      return false;
    }
    return true;
  }
}
