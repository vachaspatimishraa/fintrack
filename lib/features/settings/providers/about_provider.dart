import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/app_information_entity.dart';
import 'settings_provider.dart';

final appInformationProvider = FutureProvider<AppInformationEntity>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.loadAppInformation();
});

final privacyPolicyProvider = FutureProvider<String>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.loadPrivacyPolicy();
});

final termsOfServiceProvider = FutureProvider<String>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.loadTermsOfService();
});

final releaseNotesProvider = FutureProvider<List<Map<String, String>>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.loadReleaseNotes();
});
