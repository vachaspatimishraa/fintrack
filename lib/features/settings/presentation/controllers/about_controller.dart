import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/settings/domain/repositories/settings_repository.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';
import 'package:fintrack/features/settings/providers/about_provider.dart';

class AboutController {
  final Ref _ref;

  AboutController(this._ref);

  SettingsRepository get repository => _ref.read(settingsRepositoryProvider);

  Future<void> refreshAppInfo() async {
    _ref.invalidate(appInformationProvider);
  }
}

final aboutControllerProvider = Provider<AboutController>(AboutController.new);
