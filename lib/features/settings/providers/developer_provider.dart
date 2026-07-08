import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../splash/providers/initialization_provider.dart';
import '../data/repositories/developer_repository_impl.dart';
import '../domain/repositories/developer_repository.dart';
import 'settings_provider.dart';

final developerRepositoryProvider = Provider<DeveloperRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return DeveloperRepositoryImpl(isarService.isar, settingsRepo);
});

final appDiagnosticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(developerRepositoryProvider).getAppDiagnostics();
});

final dbDiagnosticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(developerRepositoryProvider).getDatabaseDiagnostics();
});

final repoDiagnosticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(developerRepositoryProvider).getRepositoryDiagnostics();
});
