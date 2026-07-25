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
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';

class SplashController {
  final Ref _ref;

  SplashController(this._ref);

  Future<void> handleAppStartup(BuildContext context) async {
    String destinationRoute = AppRoutes.login;
    bool onboardingCompleted = false;
    bool isAuthenticated = false;
    bool hasWallets = false;

    try {
      final prefs = _ref.read(sharedPreferencesProvider);


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
          authState = await completer.future.timeout(
            const Duration(seconds: 3),
          );
        } catch (_) {
          authState = _ref.read(authProvider);
        } finally {
          subscription.close();
        }
      }
      final AuthStatus status = authState.status;
      isAuthenticated = status == AuthStatus.authenticated || status == AuthStatus.guest;

      final settings = await _ref.read(settingsRepositoryProvider).loadSettings().timeout(
        const Duration(seconds: 3),
        onTimeout: () => SettingsEntity(),
      );

      if (settings.appLockEnabled && isAuthenticated) {
        _ref.read(lockProvider.notifier).lock();
      }

      if (status == AuthStatus.authenticated) {
        try {
          await _ref.read(accountRepositoryProvider).syncAccounts().timeout(
            const Duration(seconds: 3),
          );
        } catch (_) {
          // Sync failure is non-fatal for startup
        }
      }

      onboardingCompleted = _ref.read(onboardingProvider);

      if (!onboardingCompleted) {
        final accounts = await _ref.read(accountRepositoryProvider).getAccounts().timeout(
          const Duration(seconds: 3),
          onTimeout: () => [],
        );
        if (accounts.isNotEmpty) {
          await _ref.read(onboardingProvider.notifier).completeOnboarding();
          onboardingCompleted = true;
        }
      }

      if (onboardingCompleted && isAuthenticated) {
        final finalAccounts = await _ref.read(accountRepositoryProvider).getAccounts().timeout(
          const Duration(seconds: 3),
          onTimeout: () => [],
        );
        hasWallets = finalAccounts.isNotEmpty;
      }

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
      if (context.mounted) {
        context.go(destinationRoute);
      } else {
        Future.microtask(() {
          if (context.mounted) {
            context.go(destinationRoute);
          }
        });
      }
    }
  }
}

final splashControllerProvider = Provider<SplashController>((ref) => SplashController(ref));
