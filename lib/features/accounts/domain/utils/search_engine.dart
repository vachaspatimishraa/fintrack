import '../../../../core/database/isar/collections/account_model.dart';

class SearchEngine {
  static List<AccountModel> search({
    required List<AccountModel> accounts,
    required String query,
  }) {
    if (query.trim().isEmpty) return accounts;
    final lowercaseQuery = query.trim().toLowerCase();

    return accounts.where((item) {
      final nameMatch = item.name.toLowerCase().contains(lowercaseQuery);
      final typeMatch = item.type.toLowerCase().contains(lowercaseQuery);
      final notesMatch = item.notes?.toLowerCase().contains(lowercaseQuery) ?? false;
      return nameMatch || typeMatch || notesMatch;
    }).toList();
  }
}
