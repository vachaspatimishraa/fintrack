import '../../../domain/entities/transaction_entity.dart';
import '../../mappers/transaction_mapper.dart';

class TransactionSyncAdapter {
  static Map<String, dynamic> toSupabasePayload(TransactionEntity entity) {
    return TransactionMapper.toJson(entity);
  }

  static TransactionEntity fromSupabasePayload(Map<String, dynamic> payload) {
    return TransactionMapper.fromJson(payload);
  }
}
