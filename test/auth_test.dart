import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/auth/data/models/user_profile_model.dart';
import 'package:fintrack/features/auth/providers/auth_provider.dart';

void main() {
  group('UserProfileModel Test', () {
    test('fromJson and toJson maps correctly', () {
      final now = DateTime.now();
      final model = UserProfileModel(
        userId: 'test_user_id_123',
        displayName: 'John Doe',
        email: 'john.doe@example.com',
        photoUrl: 'https://example.com/avatar.png',
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
        preferredCurrency: 'EUR',
        preferredTheme: 'dark',
        language: 'de',
      );

      final json = model.toJson();
      expect(json['user_id'], 'test_user_id_123');
      expect(json['display_name'], 'John Doe');
      expect(json['preferred_currency'], 'EUR');
      expect(json['preferred_theme'], 'dark');

      final parsed = UserProfileModel.fromJson(json);
      expect(parsed.userId, 'test_user_id_123');
      expect(parsed.displayName, 'John Doe');
      expect(parsed.preferredCurrency, 'EUR');
      expect(parsed.preferredTheme, 'dark');
    });
  });

  group('AuthState State Test', () {
    test('State constructors set correct statuses', () {
      const unknown = AuthState.unknown();
      expect(unknown.status, AuthStatus.loading);

      const loading = AuthState.loading();
      expect(loading.status, AuthStatus.loading);

      const guest = AuthState.guest();
      expect(guest.status, AuthStatus.guest);

      const unauth = AuthState.unauthenticated(errorMessage: 'Cancel');
      expect(unauth.status, AuthStatus.unauthenticated);

      final errorState = AuthState.error('Failed connection');
      expect(errorState.status, AuthStatus.error);
      expect(errorState.errorMessage, 'Failed connection');
    });
  });
}
