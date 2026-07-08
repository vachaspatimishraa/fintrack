import '../../../../core/database/isar/collections/category_model.dart';

abstract class CategoryRepository {
  Stream<List<CategoryModel>> watchCategories();
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel?> getCategoryByUuid(String uuid);
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String uuid);
  Future<List<CategoryModel>> getRecentCategories(int limit);
  Future<void> seedDefaultCategories();
}
