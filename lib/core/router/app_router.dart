import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/routes.dart';
import 'route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
    final authState = ref.watch(authProvider);

    return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final status = authState.status;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isSplashing = state.matchedLocation == AppRoutes.splash;

      if (isSplashing) {
        return null;
      }

      if (status == AuthStatus.unknown || status == AuthStatus.loading) {
        return AppRoutes.splash;
      }

      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (status == AuthStatus.authenticated || status == AuthStatus.guest) {
        if (isLoggingIn) {
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
