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

    debugPrint('[SPLASH] START Splash');

    String destinationRoute = AppRoutes.login;
    bool onboardingCompleted = false;
    bool isAuthenticated = false;
    bool hasWallets = false;

    try {
      // 1. Wait for foundation initialization
      debugPrint('[SPLASH] Getting shared preferences...');
      final prefs = _ref.read(sharedPreferencesProvider);
      debugPrint('[SPLASH] Preferences Ready');

      // 2. Load last selected account
      final lastAccountId = prefs.getString('last_selected_account_id');
      debugPrint('[SPLASH] Loaded last selected account ID: $lastAccountId');

      // 3. Wait for the authentication status to resolve
      debugPrint('[SPLASH] Waiting for auth status...');
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
        } catch (e) {
          debugPrint('[SPLASH WARNING] Auth status wait timed out: $e. Using current status.');
          authState = _ref.read(authProvider);
        } finally {
          subscription.close();
        }
      }
      final AuthStatus status = authState.status;
      debugPrint('[SPLASH] Auth status resolved: $status');
      isAuthenticated = status == AuthStatus.authenticated || status == AuthStatus.guest;

      // 4. Load Settings
      debugPrint('[SPLASH] Loading settings...');
      final settings = await _ref.read(settingsRepositoryProvider).loadSettings().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[SPLASH WARNING] loadSettings timed out.');
          return SettingsEntity();
        },
      );
      debugPrint('[SPLASH] Settings Ready');

      if (settings.appLockEnabled && isAuthenticated) {
        _ref.read(lockProvider.notifier).lock();
        debugPrint('[SPLASH] App Lock Enabled & Triggered');
      }

      // 5. Restore session / Sync wallets
      if (status == AuthStatus.authenticated) {
        debugPrint('[SPLASH] Wallet Sync Started');
        try {
          await _ref.read(accountRepositoryProvider).syncAccounts().timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint('[SPLASH WARNING] syncAccounts timed out.');
            },
          );
        } catch (e) {
          debugPrint('[SPLASH WARNING] syncAccounts failed: $e');
        }
        debugPrint('[SPLASH] Wallet Sync Finished');
      }

      // Onboarding and Wallet check
      onboardingCompleted = _ref.read(onboardingProvider);
      debugPrint('[SPLASH] Onboarding completed status: $onboardingCompleted');

      if (!onboardingCompleted) {
        debugPrint('[SPLASH] Checking for local wallets...');
        final accounts = await _ref.read(accountRepositoryProvider).getAccounts().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('[SPLASH WARNING] getAccounts timed out.');
            return [];
          },
        );
        if (accounts.isNotEmpty) {
          await _ref.read(onboardingProvider.notifier).completeOnboarding();
          onboardingCompleted = true;
          debugPrint('[SPLASH] Wallets found locally, marked onboarding completed.');
        }
      }

      if (onboardingCompleted && isAuthenticated) {
        debugPrint('[SPLASH] Checking wallets for final navigation...');
        final finalAccounts = await _ref.read(accountRepositoryProvider).getAccounts().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('[SPLASH WARNING] getAccounts (final) timed out.');
            return [];
          },
        );
        hasWallets = finalAccounts.isNotEmpty;
      }

      // Determine correct route
      if (!onboardingCompleted) {
        destinationRoute = AppRoutes.onboarding;
      } else if (!isAuthenticated) {
        destinationRoute = AppRoutes.login;
      } else if (!hasWallets) {
        destinationRoute = AppRoutes.createWallet;
      } else {
        destinationRoute = AppRoutes.home;
      }

    } catch (e, stackTrace) {
      debugPrint('[SPLASH ERROR] Startup error: $e');
      debugPrintStack(stackTrace: stackTrace);
      destinationRoute = AppRoutes.login;
    } finally {
      debugPrint('[SPLASH] Finalizing navigation to: $destinationRoute');
      if (context.mounted) {
        debugPrint('[SPLASH] Context is mounted. Navigating to: $destinationRoute');
        context.go(destinationRoute);
      } else {
        debugPrint('[SPLASH SEVERE WARNING] Context is NOT mounted. Retrying navigation via microtask.');
        Future.microtask(() {
          if (context.mounted) {
            debugPrint('[SPLASH] Retry: Context mounted. Navigating to: $destinationRoute');
            context.go(destinationRoute);
          } else {
            debugPrint('[SPLASH ERROR] Retry failed: Context still NOT mounted.');
          }
        });
      }

      // Navigation flag removed
    }
  }
}

final splashControllerProvider = Provider<SplashController>((ref) => SplashController(ref));
