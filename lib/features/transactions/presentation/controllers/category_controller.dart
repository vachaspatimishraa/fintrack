import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/isar/collections/category_model.dart';
import '../../providers/transaction_provider.dart';

class CategoryController {
  final Ref _ref;

  CategoryController(this._ref);

  Future<void> saveCategory(CategoryModel category) {
    return _ref.read(categoryRepositoryProvider).saveCategory(category);
  }

  Future<void> deleteCategory(String uuid) {
    return _ref.read(categoryRepositoryProvider).deleteCategory(uuid);
  }

  Future<List<CategoryModel>> getRecentCategories(int limit) {
    return _ref.read(categoryRepositoryProvider).getRecentCategories(limit);
  }
}

final categoryControllerProvider = Provider<CategoryController>((ref) {
  return CategoryController(ref);
});
