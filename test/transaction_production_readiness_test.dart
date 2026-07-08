import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/retry_manager.dart';
import 'package:fintrack/features/transactions/domain/utils/repository_logger.dart';
import 'package:fintrack/features/transactions/data/mappers/failure_mapper.dart';

void main() {
  group('Transaction Production Readiness & Security Tests', () {
    test('RetryManager calculates exponential delay correct intervals', () {
      expect(RetryManager.getNextDelay(1).inMinutes, equals(1));
      expect(RetryManager.getNextDelay(2).inMinutes, equals(2));
      expect(RetryManager.getNextDelay(3).inMinutes, equals(4));
      expect(RetryManager.getNextDelay(4).inMinutes, equals(8));
      expect(RetryManager.getNextDelay(5).inMinutes, equals(16));
      expect(RetryManager.getNextDelay(6).inMinutes, equals(32));
      expect(RetryManager.getNextDelay(7).inMinutes, equals(32)); // caps at 32 mins
    });

    test('FailureMapper converts exceptions to Failure models', () {
      final socketFailure = FailureMapper.fromException(const SocketException('no connection'));
      expect(socketFailure.code, equals('NETWORK_ERROR'));
      expect(socketFailure.isRetryAvailable, isTrue);

      final unknownFailure = FailureMapper.fromException(Exception('generic crash'));
      expect(unknownFailure.code, equals('UNKNOWN_ERROR'));
    });

    test('RepositoryLogger sanitizes sensitive financial parameters', () {
      final payload = {
        'id': 'tx-uuid-1',
        'amount': 250.0,
        'description': 'Private details description',
        'category': 'Food',
        'receipt_url': 'https://supabase.com/receipt.jpg',
      };

      final sanitized = RepositoryLogger.sanitizePayload(payload);
      expect(sanitized['id'], equals('tx-uuid-1'));
      expect(sanitized['amount'], equals('[REDACTED]'));
      expect(sanitized['description'], equals('[REDACTED]'));
      expect(sanitized['receipt_url'], equals('[REDACTED]'));
      expect(sanitized['category'], equals('Food'));
    });
  });
}
