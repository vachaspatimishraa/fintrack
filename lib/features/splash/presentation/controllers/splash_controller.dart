import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/initialization_provider.dart';

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
      while ((status == AuthStatus.unknown || status == AuthStatus.loading) && retryCount < 100) {
        await Future.delayed(const Duration(milliseconds: 50));
        status = _ref.read(authProvider).status;
        retryCount++;
      }

      // 4. Perform automatic navigation
      if (context.mounted) {
        if (status == AuthStatus.authenticated || status == AuthStatus.guest) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
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
