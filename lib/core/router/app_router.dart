import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/routes.dart';
import 'route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

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

      // 1. If we are currently loading, only stay on splash or go to splash if at login
      if (status == AuthStatus.loading) {
        if (isSplashing || isLoggingIn) return AppRoutes.splash;
        return null; // Stay where we are otherwise
      }

      // 2. Error status -> Login
      if (status == AuthStatus.error) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      // 3. Authenticated/Guest -> Home (if currently at login or splash)
      if (status == AuthStatus.authenticated || status == AuthStatus.guest) {
        if (isLoggingIn || isSplashing) {
          return AppRoutes.home;
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
        path: AppRoutes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
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
