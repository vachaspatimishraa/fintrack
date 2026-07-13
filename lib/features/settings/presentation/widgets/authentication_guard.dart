import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../providers/security_provider.dart';
import '../../providers/settings_provider.dart';
import '../../domain/services/screenshot_protection_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/services/biometric_service.dart';

class AuthenticationGuard extends ConsumerStatefulWidget {
  final Widget child;

  const AuthenticationGuard({super.key, required this.child});

  @override
  ConsumerState<AuthenticationGuard> createState() => _AuthenticationGuardState();
}

class _AuthenticationGuardState extends ConsumerState<AuthenticationGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyPrivacySettings();
    _checkInitialLock();
  }

  void _checkInitialLock() async {
    final settings = await ref.read(settingsRepositoryProvider).loadSettings();
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated || authState.status == AuthStatus.guest;
    if (settings.appLockEnabled && isAuthenticated) {
      ref.read(lockProvider.notifier).lock();
    }
  }

  void _applyPrivacySettings() async {
    final settingsAsync = ref.read(settingsProvider);
    settingsAsync.whenData((settings) {
      ScreenshotProtectionService.setEnabled(settings.screenshotProtectionEnabled);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(sessionManagerProvider).updateActivity();
      final settings = ref.read(settingsProvider).value;
      if (settings != null && settings.appLockEnabled && settings.sessionTimeout == 'immediately') {
        ref.read(lockProvider.notifier).lock();
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkLock();
    }
  }

  void _checkLock() {
    final settings = ref.read(settingsProvider).value;
    if (settings != null && settings.appLockEnabled) {
      final sessionManager = ref.read(sessionManagerProvider);
      if (sessionManager.shouldLockSync(settings.sessionTimeout)) {
        ref.read(lockProvider.notifier).lock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(lockProvider);

    // Watch authProvider to check authentication status
    final currentAuthState = ref.watch(authProvider);
    final isAuthenticated = currentAuthState.status == AuthStatus.authenticated || currentAuthState.status == AuthStatus.guest;

    if (lockState.isLocked && isAuthenticated) {
      return _LockOverlay(
        error: lockState.error,
        onAuthenticate: () => ref.read(lockProvider.notifier).authenticate(
          context.translate('authenticate_reason'),
        ),
      );
    }

    return widget.child;
  }
}

class _LockOverlay extends StatefulWidget {
  final String? error;
  final VoidCallback onAuthenticate;

  const _LockOverlay({
    this.error,
    required this.onAuthenticate,
  });

  @override
  State<_LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<_LockOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _pulseController.repeat(reverse: true);
    _checkBiometrics();
    _triggerAuth();
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService().isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
      });
    }
  }

  void _triggerAuth() {
    Future.delayed(Duration.zero, widget.onAuthenticate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFailed = widget.error != null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // FinTrack Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 90,
                  width: 90,
                ),
                const SizedBox(height: 24),
                const Text(
                  'FinTrack',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 48),
                // Pulsing Lock/Biometric Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _biometricsAvailable ? Icons.fingerprint : Icons.lock_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  context.translate('locked_title'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  hasFailed
                      ? context.translate('auth_failed')
                      : context.translate('authenticate_to_continue'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: hasFailed
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: hasFailed ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Modern Material 3 filled button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: widget.onAuthenticate,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.security),
                    label: Text(
                      hasFailed ? context.translate('try_again') : context.translate('unlock_application'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
