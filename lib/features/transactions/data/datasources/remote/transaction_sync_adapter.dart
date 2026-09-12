import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/transactions/data/mappers/transaction_mapper.dart';

class TransactionSyncAdapter {
  static Map<String, dynamic> toSupabasePayload(TransactionEntity entity) {
    return TransactionMapper.toJson(entity);
  }

  static TransactionEntity fromSupabasePayload(Map<String, dynamic> payload) {
    return TransactionMapper.fromJson(payload);
  }
}
