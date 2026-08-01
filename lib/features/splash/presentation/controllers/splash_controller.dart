import 'dart:async';
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
import 'package:fintrack/features/sync/providers/sync_provider.dart';

class SplashController {
  final Ref _ref;

  SplashController(this._ref);

  Future<void> handleAppStartup(BuildContext context) async {
    final stopwatch = Stopwatch()..start();
    debugPrint('[STARTUP LOG] App Started');

    String destinationRoute = AppRoutes.login;
    bool onboardingCompleted = false;
    bool isAuthenticated = false;
    bool hasWallets = false;

    try {
      _ref.read(sharedPreferencesProvider);
      debugPrint('[STARTUP LOG] Preferences Loaded');

      AuthState authState = _ref.read(authProvider);
      if (authState.status == AuthStatus.loading) {
        final completer = Completer<AuthState>();
        final subscription = _ref.listen<AuthState>(
          authProvider,
          (previous, next) {
            if (next.status != AuthStatus.loading && !completer.isCompleted) {
              completer.complete(next);
            }
          },
          fireImmediately: true,
        );
        try {
          authState = await completer.future;
        } catch (_) {
          authState = _ref.read(authProvider);
        } finally {
          subscription.close();
        }
      }
      final AuthStatus status = authState.status;
      isAuthenticated = status == AuthStatus.authenticated || status == AuthStatus.guest;
      debugPrint('[STARTUP LOG] Auth Restored');

      onboardingCompleted = _ref.read(onboardingProvider);

      if (!onboardingCompleted) {
        final accounts = await _ref.read(accountRepositoryProvider).getAccounts();
        if (accounts.isNotEmpty) {
          await _ref.read(onboardingProvider.notifier).completeOnboarding();
          onboardingCompleted = true;
        }
      }

      if (onboardingCompleted && isAuthenticated) {
        final finalAccounts = await _ref.read(accountRepositoryProvider).getAccounts();
        hasWallets = finalAccounts.isNotEmpty;
      }
      debugPrint('[STARTUP LOG] Wallet Checked');

      if (!onboardingCompleted) {
        destinationRoute = AppRoutes.onboarding;
      } else if (!isAuthenticated) {
        destinationRoute = AppRoutes.login;
      } else if (!hasWallets) {
        destinationRoute = AppRoutes.createWallet;
      } else {
        destinationRoute = AppRoutes.home;
      }
    } catch (e) {
      debugPrint('[SPLASH ERROR] Startup error: $e');
      destinationRoute = AppRoutes.login;
    } finally {
      stopwatch.stop();
      debugPrint('[STARTUP LOG] Navigation -> $destinationRoute');
      debugPrint('[STARTUP LOG] Splash Duration: ${stopwatch.elapsedMilliseconds} ms');

      if (context.mounted) {
        context.go(destinationRoute);
      } else {
        Future.microtask(() {
          if (context.mounted) {
            context.go(destinationRoute);
          }
        });
      }

      unawaited(_triggerBackgroundSync(isAuthenticated));
    }
  }

  Future<void> _triggerBackgroundSync(bool isAuthenticated) async {
    debugPrint('[STARTUP LOG] Background Sync Started');
    try {
      final settings = await _ref.read(settingsRepositoryProvider).loadSettings();
      if (settings.appLockEnabled && isAuthenticated) {
        _ref.read(lockProvider.notifier).lock();
      }

      if (isAuthenticated) {
        try {
          await _ref.read(accountRepositoryProvider).syncAccounts();
        } catch (_) {}

        try {
          final syncService = _ref.read(syncServiceProvider);
          await syncService.triggerSync();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[STARTUP LOG] Background sync error: $e');
    } finally {
      debugPrint('[STARTUP LOG] Background Sync Finished');
    }
  }
}

final splashControllerProvider = Provider<SplashController>((ref) => SplashController(ref));
