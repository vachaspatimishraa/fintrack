class AIContractValidator {
  static bool verifyNoForbiddenPatterns(String fileContent) {
    final lower = fileContent.toLowerCase();
    // Controllers must never use raw setState or raw database queries
    if (lower.contains('setstate(') && lower.contains('controller')) {
      return false;
    }
    if (lower.contains('raw_sql') || lower.contains('select * from')) {
      return false;
    }
    return true;
  }
}
