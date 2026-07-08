import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../accounts/presentation/screens/account_list_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../../core/utils/translations.dart';

class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authController = ref.read(authControllerProvider);
    
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand Logo & Name Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 36,
                    width: 36,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FinTrack',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // User section
            _buildUserSection(context, authState, authController),
            const Divider(height: 1),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icon(Icons.receipt_long_outlined, color: Theme.of(context).colorScheme.primary),
                    label: context.translate('transactions'),
                    destination: const TransactionsScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icon(Icons.account_balance_outlined, color: Theme.of(context).colorScheme.primary),
                    label: context.translate('accounts'),
                    destination: const AccountListScreen(),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary),
                    label: context.translate('settings'),
                    destination: const SettingsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, AuthState authState, AuthController authController) {
    final isLoading = authState.status == AuthStatus.loading;
    final isGuest = authState.status == AuthStatus.guest || authState.status == AuthStatus.unauthenticated;
    
    if (isGuest) {
      return InkWell(
        onTap: isLoading ? null : () => authController.loginWithGoogle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: 24,
                child: const Icon(Icons.person_outline, size: 28, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('guest_user'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          )
                        else
                          Text(
                            context.translate('sign_in_with_google'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Authenticated user
      final user = authState.user;
      final email = user?.email ?? '';
      final name = user?.userMetadata?['display_name'] ?? user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? 'User';
      final avatarUrl = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              backgroundColor: Colors.indigo,
              radius: 24,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 28, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required Widget icon,
    required String label,
    required Widget destination,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        // Close the drawer first
        Navigator.pop(context);
        // Push the screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }
}
