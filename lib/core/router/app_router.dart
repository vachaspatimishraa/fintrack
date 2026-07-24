import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/auth/providers/auth_provider.dart';
import 'package:fintrack/features/splash/presentation/screens/splash_screen.dart';
import 'package:fintrack/features/auth/presentation/screens/login_screen.dart';
import 'package:fintrack/features/home/presentation/screens/home_screen.dart';
import 'package:fintrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fintrack/features/accounts/presentation/screens/create_account_screen.dart';
import 'package:fintrack/core/constants/routes.dart';
import 'package:fintrack/core/router/route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final status = authState.status;
      final matchedLocation = state.matchedLocation;
      final isLoggingIn = matchedLocation == AppRoutes.login;
      final isSplashing = matchedLocation == AppRoutes.splash;
      final isOnboarding = matchedLocation == AppRoutes.onboarding;

      // 1. If we are currently loading, stay on splash if already on splash. Otherwise, stay where we are.
      if (status == AuthStatus.loading) {
        if (isSplashing) return AppRoutes.splash;
        return null; 
      }

      // 2. Error status (unauthenticated) -> stay on login, onboarding, or splash. Redirect others to splash.
      if (status == AuthStatus.error) {
        if (isSplashing || isLoggingIn || isOnboarding) {
          return null;
        }
        return AppRoutes.splash;
      }

      // 3. Authenticated/Guest -> redirect to splash to handle wallet checks and route to Home/Create Wallet
      if (status == AuthStatus.authenticated || status == AuthStatus.guest) {
        if (isLoggingIn || isOnboarding) {
          return AppRoutes.splash;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createWallet,
        name: RouteNames.createWallet,
        builder: (context, state) => const CreateAccountScreen(),
      ),
    ],
  );
});

final routerRefreshListenableProvider = Provider<GoRouterRefreshListenable>((ref) {
  return GoRouterRefreshListenable(ref);
});

class GoRouterRefreshListenable extends ChangeNotifier {
  GoRouterRefreshListenable(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.status != next.status) {
        notifyListeners();
      }
    });
  }
}
