import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/domain/utils/validation_service.dart';
import 'package:fintrack/features/transactions/domain/utils/balance_calculator.dart';
import 'package:fintrack/features/transactions/data/mappers/transaction_mapper.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';

void main() {
  group('Transaction Domain & Utility Tests', () {
    test('ValidationService validates title length bounds', () {
      expect(
        ValidationService.validateTitle(''),
        equals('enter_title'),
      );
      expect(
        ValidationService.validateTitle(null),
        equals('enter_title'),
      );
      expect(
        ValidationService.validateTitle('a' * 61),
        equals('enter_title'),
      );
      expect(ValidationService.validateTitle('Valid Title'), isNull);
    });

    test('ValidationService validates non-zero positive amounts', () {
      expect(
        ValidationService.validateAmount(''),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount(null),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount('abc'),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount('0'),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount('-10.5'),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount('1.234'),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(
        ValidationService.validateAmount('1000000000000'),
        equals('enter_valid_amount_gt_zero'),
      );
      expect(ValidationService.validateAmount('150.00'), isNull);
    });

    test('ValidationService validates description length bounds', () {
      expect(
        ValidationService.validateDescription('a' * 501),
        equals('max_chars_500'),
      );
      expect(
        ValidationService.validateDescription('Valid description'),
        isNull,
      );
    });

    test('BalanceCalculator computes total balance, income, and expense', () {
      final now = DateTime.now();
      final txs = [
        TransactionEntity(
          uuid: '1',
          accountId: 'acc1',
          type: 'income',
          categoryId: 'cat1',
          category: 'Salary',
          amount: 5000.0,
          title: 'Salary',
          description: '',
          currency: 'USD',
          paymentMethod: 'Bank',
          tags: const [],
          isDeleted: false,
          isSynced: true,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
        ),
        TransactionEntity(
          uuid: '2',
          accountId: 'acc1',
          type: 'expense',
          categoryId: 'cat2',
          category: 'Food',
          amount: 150.0,
          title: 'Groceries',
          description: '',
          currency: 'USD',
          paymentMethod: 'Cash',
          tags: const [],
          isDeleted: false,
          isSynced: true,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
        ),
        TransactionEntity(
          uuid: '3',
          accountId: 'acc1',
          type: 'expense',
          categoryId: 'cat3',
          category: 'Rent',
          amount: 1000.0,
          title: 'Rent payment',
          description: '',
          currency: 'USD',
          paymentMethod: 'Bank',
          tags: const [],
          isDeleted: true, // Soft deleted, should be excluded
          isSynced: false,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
        ),
      ];

      expect(BalanceCalculator.calculateIncome(txs), equals(5000.0));
      expect(BalanceCalculator.calculateExpense(txs), equals(150.0));
      expect(
        BalanceCalculator.calculateTotalBalance(txs, 1000.0),
        equals(5850.0),
      );
    });

    test('TransactionMapper correctly maps entity to/from model and JSON', () {
      final now = DateTime.now();
      final entity = TransactionEntity(
        uuid: 'uuid-123',
        accountId: 'acc-123',
        type: 'expense',
        categoryId: 'cat-123',
        category: 'Shopping',
        amount: 85.50,
        title: 'New Shoes',
        description: 'Store purchase',
        currency: 'EUR',
        paymentMethod: 'Card',
        receiptUrl: 'http://test.com/receipt.png',
        receiptLocalPath: '/local/path/receipt.png',
        tags: const ['clothes', 'personal'],
        isDeleted: false,
        isSynced: false,
        isRecurring: false,
        date: now,
        createdAt: now,
        updatedAt: now,
        userId: 'user-123',
        syncVersion: 2,
      );

      final model = TransactionMapper.toModel(entity);
      expect(model.uuid, equals(entity.uuid));
      expect(model.accountId, equals(entity.accountId));
      expect(model.type, equals(entity.type));
      expect(model.categoryId, equals(entity.categoryId));
      expect(model.category, equals(entity.category));
      expect(model.amount, equals(entity.amount));
      expect(model.title, equals(entity.title));
      expect(model.description, equals(entity.description));
      expect(model.currency, equals(entity.currency));
      expect(model.paymentMethod, equals(entity.paymentMethod));
      expect(model.receiptUrl, equals(entity.receiptUrl));
      expect(model.receiptLocalPath, equals(entity.receiptLocalPath));
      expect(model.tags, equals(entity.tags));
      expect(model.isDeleted, equals(entity.isDeleted));
      expect(model.isSynced, equals(entity.isSynced));
      expect(model.isRecurring, equals(entity.isRecurring));
      expect(model.date, equals(entity.date));
      expect(model.userId, equals(entity.userId));
      expect(model.syncVersion, equals(entity.syncVersion));

      final mappedEntity = TransactionMapper.toEntity(model);
      expect(mappedEntity.uuid, equals(entity.uuid));
      expect(mappedEntity.amount, equals(entity.amount));
      expect(mappedEntity.tags, equals(entity.tags));

      final json = TransactionMapper.toJson(entity);
      expect(json['id'], equals(entity.uuid));
      expect(json['amount'], equals(entity.amount));
      expect(json['category_id'], equals(entity.categoryId));

      json['tags'] = entity.tags;

      final fromJsonEntity = TransactionMapper.fromJson(json);
      expect(fromJsonEntity.uuid, equals(entity.uuid));
      expect(fromJsonEntity.amount, equals(entity.amount));
      expect(fromJsonEntity.tags, equals(entity.tags));
    });
    group('Isar Collection defaults fromJson tests', () {
      test('TransactionModel.fromJson handles null safety defaults', () {
        final json = {
          'id': 'uuid-999',
          'account_id': 'acc-999',
          'type': 'income',
          'date': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final model = TransactionModel.fromJson(json);
        expect(model.uuid, equals('uuid-999'));
        expect(model.accountId, equals('acc-999'));
        expect(model.type, equals('income'));
        expect(model.amount, equals(0.0));
        expect(model.title, equals(''));
        expect(model.categoryId, equals(''));
        expect(model.category, equals(''));
        expect(model.currency, equals('INR'));
        expect(model.paymentMethod, equals('Cash'));
        expect(model.isDeleted, isFalse);
        expect(model.isSynced, isTrue);
        expect(model.isRecurring, isFalse);
        expect(model.syncVersion, equals(1));
      });
    });
  });
}
