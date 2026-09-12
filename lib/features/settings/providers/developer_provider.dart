import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/splash/providers/initialization_provider.dart';
import 'package:fintrack/features/settings/data/repositories/developer_repository_impl.dart';
import 'package:fintrack/features/settings/domain/repositories/developer_repository.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';

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
