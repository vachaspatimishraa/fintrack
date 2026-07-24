import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/initialization_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../settings/providers/security_provider.dart';
import 'package:fintrack/features/onboarding/providers/onboarding_provider.dart';
import 'package:fintrack/features/accounts/providers/account_provider.dart';

class SplashController {
  final Ref _ref;

  SplashController(this._ref);

  Future<void> handleAppStartup(BuildContext context) async {
    try {
      // 1. Wait for foundation initialization (SharedPreferences, Supabase, Isar)
      final prefs = await _ref.read(appInitializationProvider.future);

      // 2. Load last selected account
      final lastAccountId = prefs.getString('last_selected_account_id');
      debugPrint('Loaded last selected account ID: $lastAccountId');

      // 3. Wait for the authentication status to resolve with a timeout (5 seconds max)
      int retryCount = 0;
      AuthStatus status = _ref.read(authProvider).status;
      while (status == AuthStatus.loading && retryCount < 100) {
        await Future.delayed(const Duration(milliseconds: 50));
        status = _ref.read(authProvider).status;
        retryCount++;
      }

      // Read settings and check if app lock is enabled
      final settings = await _ref.read(settingsRepositoryProvider).loadSettings();
      final isAuthenticated = status == AuthStatus.authenticated || status == AuthStatus.guest;
      if (settings.appLockEnabled && isAuthenticated) {
        _ref.read(lockProvider.notifier).lock();
      }

      // 4. Perform automatic navigation
      if (context.mounted) {
        // 1. Is the user authenticated (or using guest mode)?
        if (!isAuthenticated) {
          context.go(AppRoutes.login);
          return;
        }

        // 2. Has onboarding been completed?
        final onboardingCompleted = _ref.read(onboardingProvider);
        if (!onboardingCompleted) {
          context.go(AppRoutes.onboarding);
          return;
        }

        // 3. Has the user created at least one Wallet?
        final accounts = await _ref.read(accountRepositoryProvider).getAccounts();
        if (!context.mounted) return;
        if (accounts.isEmpty) {
          context.go(AppRoutes.createWallet);
          return;
        }

        // 4. Otherwise
        context.go(AppRoutes.home);
      }
    } catch (e, stackTrace) {
      debugPrint('Startup navigation error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

final splashControllerProvider = Provider<SplashController>((ref) => SplashController(ref));
