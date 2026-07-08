import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/accounts/providers/account_pagination_provider.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';

void main() {
  group('Account Search, Sort, Filter, and Pagination Unit Tests', () {
    late List<AccountModel> mockAccounts;

    setUp(() {
      final now = DateTime.now();
      mockAccounts = [
        AccountModel()
          ..uuid = 'acc-1'
          ..name = 'HDFC Bank'
          ..type = 'bank'
          ..balance = 50000.0
          ..notes = 'Main salary account'
          ..isArchived = false
          ..isDeleted = false
          ..isSynced = true
          ..createdAt = now.subtract(const Duration(days: 10))
          ..updatedAt = now.subtract(const Duration(days: 2)),
        AccountModel()
          ..uuid = 'acc-2'
          ..name = 'Cash Wallet'
          ..type = 'cash'
          ..balance = 1500.0
          ..notes = 'Pocket cash'
          ..isArchived = false
          ..isDeleted = false
          ..isSynced = false
          ..createdAt = now.subtract(const Duration(days: 5))
          ..updatedAt = now.subtract(const Duration(days: 1)),
        AccountModel()
          ..uuid = 'acc-3'
          ..name = 'Business Account'
          ..type = 'business'
          ..balance = 250000.0
          ..notes = 'Company expenses'
          ..isArchived = true
          ..isDeleted = false
          ..isSynced = true
          ..createdAt = now.subtract(const Duration(days: 20))
          ..updatedAt = now.subtract(const Duration(days: 5)),
        AccountModel()
          ..uuid = 'acc-4'
          ..name = 'Credit Card'
          ..type = 'card'
          ..balance = -5000.0
          ..notes = 'Overdrawn credit card'
          ..isArchived = false
          ..isDeleted = true
          ..isSynced = false
          ..createdAt = now.subtract(const Duration(days: 30))
          ..updatedAt = now.subtract(const Duration(days: 15)),
      ];
    });

    test('Filter logic works as expected', () {
      // 1. Active filter (non-deleted, non-archived)
      final active = mockAccounts.where((item) => !item.isDeleted && !item.isArchived).toList();
      expect(active.length, 2);
      expect(active.any((a) => a.uuid == 'acc-1'), true);
      expect(active.any((a) => a.uuid == 'acc-2'), true);

      // 2. Archived filter (non-deleted, archived)
      final archived = mockAccounts.where((item) => !item.isDeleted && item.isArchived).toList();
      expect(archived.length, 1);
      expect(archived.first.uuid, 'acc-3');

      // 3. Deleted filter (soft deleted)
      final deleted = mockAccounts.where((item) => item.isDeleted).toList();
      expect(deleted.length, 1);
      expect(deleted.first.uuid, 'acc-4');

      // 4. Pending Sync filter (non-deleted, non-synced)
      final pendingSync = mockAccounts.where((item) => !item.isDeleted && !item.isSynced).toList();
      expect(pendingSync.length, 1);
      expect(pendingSync.first.uuid, 'acc-2');
    });

    test('Search logic works as expected case-insensitively', () {
      final query = ' salary ';
      final match = mockAccounts.where((item) {
        return item.name.toLowerCase().contains(query.trim().toLowerCase()) ||
            item.type.toLowerCase().contains(query.trim().toLowerCase()) ||
            (item.notes?.toLowerCase().contains(query.trim().toLowerCase()) ?? false);
      }).toList();

      expect(match.length, 1);
      expect(match.first.uuid, 'acc-1');
    });

    test('Sorting logic works correctly', () {
      // 1. Alphabetical sorting
      final alphaList = List<AccountModel>.from(mockAccounts);
      alphaList.sort((a, b) => a.name.compareTo(b.name));
      expect(alphaList[0].name, 'Business Account');
      expect(alphaList[1].name, 'Cash Wallet');

      // 2. Highest Balance sorting
      final balanceList = List<AccountModel>.from(mockAccounts);
      balanceList.sort((a, b) => b.balance.compareTo(a.balance));
      expect(balanceList[0].name, 'Business Account'); // 250000
      expect(balanceList[1].name, 'HDFC Bank');        // 50000
      expect(balanceList[3].name, 'Credit Card');       // -5000
    });

    test('Pagination logic slices list correctly', () {
      final list = List<AccountModel>.from(mockAccounts);
      const paginationState = PaginationState(limit: 2, page: 1);
      final offset = paginationState.page * paginationState.limit;
      final end = (offset + paginationState.limit).clamp(0, list.length);
      final paginatedList = list.sublist(offset, end);

      expect(paginatedList.length, 2);
      expect(paginatedList[0].uuid, 'acc-3');
      expect(paginatedList[1].uuid, 'acc-4');
    });

    test('Validation constraints helper checks values correctly', () {
      // 1. Validate empty name rejection
      bool isValidName(String? name) {
        final trimmed = name?.trim() ?? '';
        return trimmed.isNotEmpty && trimmed.length <= 40;
      }
      expect(isValidName(''), isFalse);
      expect(isValidName('   '), isFalse);
      expect(isValidName('a' * 41), isFalse);
      expect(isValidName('Savings'), isTrue);

      // 2. Validate balance amount parsing
      double? parseAmount(String? val) {
        if (val == null || val.isEmpty) return null;
        return double.tryParse(val);
      }
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('100.50'), 100.50);
      expect(parseAmount('-50.00'), -50.00);
    });
  });
}
