import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/ai_contract_validator.dart';

void main() {
  group('AI Contract & Autonomous Coding Rules Tests', () {
    test('AIContractValidator flags raw setState inside controller content', () {
      const badController = '''
      class MyController {
        void updateState() {
          setState(() {});
        }
      }
      ''';
      expect(AIContractValidator.verifyNoForbiddenPatterns(badController), isFalse);

      const goodController = '''
      class MyController {
        void updateState() {
          ref.read(provider.notifier).state = newState;
        }
      }
      ''';
      expect(AIContractValidator.verifyNoForbiddenPatterns(goodController), isTrue);
    });

    test('AIContractValidator flags direct SQL queries', () {
      const badQuery = 'select * from transactions';
      expect(AIContractValidator.verifyNoForbiddenPatterns(badQuery), isFalse);
    });
  });
}
