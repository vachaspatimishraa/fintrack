class SecurityAudit {
  static bool verifySecurityPolicy({
    required bool hasRlsEnabled,
    required bool isPrivateBucketUsed,
    required bool isTokenMasked,
  }) {
    return hasRlsEnabled && isPrivateBucketUsed && isTokenMasked;
  }
}
