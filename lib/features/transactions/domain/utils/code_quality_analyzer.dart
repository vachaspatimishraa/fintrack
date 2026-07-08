class CodeQualityAnalyzer {
  static List<String> analyzeFile(String filePath, String content) {
    final List<String> warnings = [];
    final lines = content.split('\n');

    if (filePath.contains('controller') && lines.length > 300) {
      warnings.add('Controller file exceeds 300 lines limit: ${lines.length} lines.');
    }
    if (filePath.contains('repository') && lines.length > 500) {
      warnings.add('Repository file exceeds 500 lines limit: ${lines.length} lines.');
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('TODO')) {
        warnings.add('Found TODO on line ${i + 1}');
      }
    }
    return warnings;
  }
}
