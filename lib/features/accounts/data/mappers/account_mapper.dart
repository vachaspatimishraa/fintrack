import '../../../../core/database/isar/collections/account_model.dart';

class AccountMapper {
  static Map<String, dynamic> toJson(AccountModel model) {
    return model.toJson();
  }

  static AccountModel fromJson(Map<String, dynamic> json) {
    return AccountModel.fromJson(json);
  }
}
