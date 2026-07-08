import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../providers/settings_provider.dart';
import '../../providers/about_provider.dart';

class AboutController {
  final Ref _ref;

  AboutController(this._ref);

  SettingsRepository get _repository => _ref.read(settingsRepositoryProvider);

  Future<void> refreshAppInfo() async {
    _ref.invalidate(appInformationProvider);
  }
}

final aboutControllerProvider = Provider<AboutController>((ref) => AboutController(ref));
