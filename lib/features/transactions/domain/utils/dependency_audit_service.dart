class DependencyAuditService {
  static const Set<String> allowedDependencies = {
    'flutter',
    'isar',
    'supabase_flutter',
    'flutter_riverpod',
    'go_router',
    'flutter_secure_storage',
    'image_picker',
    'permission_handler',
    'connectivity_plus',
  };

  static bool verifyDependencies(List<String> packagesUsed) {
    for (final pkg in packagesUsed) {
      if (!allowedDependencies.contains(pkg)) {
        print('[DEPS WARNING]: Package $pkg is not in the whitelist.');
        return false;
      }
    }
    return true;
  }
}
