import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/developer_repository.dart';
import '../../providers/developer_provider.dart';

class DeveloperController {
  final Ref _ref;

  DeveloperController(this._ref);

  DeveloperRepository get _repository => _ref.read(developerRepositoryProvider);

  Future<void> clearCache() async {
    await _repository.clearAllCaches();
  }

  Future<void> resetSyncQueue() async {
    await _repository.resetSyncQueue();
  }

  Future<void> toggleFlag(String flag, bool enabled) async {
    await _repository.toggleFeatureFlag(flag, enabled);
  }

  Future<void> enableDevMode() async {
    await _repository.enableDeveloperMode();
  }
}

final developerControllerProvider = Provider<DeveloperController>((ref) => DeveloperController(ref));
