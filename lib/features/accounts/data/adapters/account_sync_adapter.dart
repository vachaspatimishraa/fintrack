import '../../../../core/database/isar/collections/account_model.dart';
import '../mappers/account_mapper.dart';

class AccountSyncAdapter {
  static Map<String, dynamic> toRemotePayload(AccountModel model, String userId) {
    final map = AccountMapper.toJson(model);
    map['user_id'] = userId;
    return map;
  }

  static AccountModel fromRemotePayload(Map<String, dynamic> payload) {
    final model = AccountMapper.fromJson(payload);
    model.isSynced = true;
    return model;
  }
}
