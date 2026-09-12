import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:fintrack/core/database/isar/collections/category_model.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';
import 'package:fintrack/features/transactions/domain/repositories/category_repository.dart';
import 'package:fintrack/core/services/sync_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Isar _isar;
  final SupabaseClient _supabase;
  final SyncService _syncService;

  CategoryRepositoryImpl({
    required Isar isar,
    required SupabaseClient supabase,
    required SyncService syncService,
  })  : _isar = isar,
        _supabase = supabase,
        _syncService = syncService;

  String get _currentUserId => _supabase.auth.currentUser?.id ?? 'guest';

  @override
  Stream<List<CategoryModel>> watchCategories() {
    final userId = _currentUserId;
    return _isar.categoryModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(false)
        .sortByOrder()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final userId = _currentUserId;
    var list = await _isar.categoryModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(false)
        .sortByOrder()
        .findAll();

    if (list.isEmpty) {
      final exists = await _isar.categoryModels.filter().userIdEqualTo(userId).findFirst();
      if (exists == null) {
        await seedDefaultCategories();
        list = await _isar.categoryModels
            .filter()
            .userIdEqualTo(userId)
            .isDeletedEqualTo(false)
            .sortByOrder()
            .findAll();
      }
    }
    return list;
  }

  @override
  Future<CategoryModel?> getCategoryByUuid(String uuid) {
    return _isar.categoryModels.filter().uuidEqualTo(uuid).findFirst();
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    final isNew = category.uuid.isEmpty;
    final categoryUuid = isNew ? const Uuid().v4() : category.uuid;

    final updated = CategoryModel()
      ..id = category.id
      ..uuid = categoryUuid
      ..userId = _currentUserId
      ..name = category.name
      ..type = category.type
      ..icon = category.icon
      ..color = category.color
      ..order = category.order
      ..isDefault = category.isDefault
      ..isDeleted = category.isDeleted
      ..isSynced = false
      ..createdAt = isNew ? DateTime.now() : category.createdAt
      ..updatedAt = DateTime.now()
      ..syncVersion = isNew ? 1 : category.syncVersion + 1;

    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(updated);
    });

    await _syncService.queueSync(
      entityType: 'category',
      entityUuid: updated.uuid,
      action: isNew ? 'create' : 'update',
      payload: updated.toJson(),
    );
  }

  @override
  Future<void> reorderCategories(List<CategoryModel> categories) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < categories.length; i++) {
        final cat = categories[i];
        cat.order = i;
        cat.updatedAt = DateTime.now();
        await _isar.categoryModels.put(cat);
      }
    });
  }

  @override
  Future<void> deleteCategory(String uuid) async {
    final category = await _isar.categoryModels.filter().uuidEqualTo(uuid).findFirst();
    if (category != null) {
      await _isar.writeTxn(() async {
        category.isDeleted = true;
        category.isSynced = false;
        category.updatedAt = DateTime.now();
        await _isar.categoryModels.put(category);
      });

      await _syncService.queueSync(
        entityType: 'category',
        entityUuid: uuid,
        action: 'delete',
        payload: {},
      );
    }
  }

  @override
  Future<List<CategoryModel>> getRecentCategories(int limit) async {
    final userId = _currentUserId;
    // Query recently used categories by scanning recent transactions
    final transactions = await _isar.transactionModels
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .limit(30)
        .findAll();

    final recentNames = transactions.map((t) => t.category).toSet().toList();
    final categories = await _isar.categoryModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(false)
        .sortByOrder()
        .findAll();

    final Map<String, CategoryModel> catMap = {for (var c in categories) c.name: c};
    final List<CategoryModel> ordered = [];
    for (final name in recentNames) {
      if (catMap.containsKey(name)) {
        ordered.add(catMap[name]!);
        if (ordered.length >= limit) break;
      }
    }

    if (ordered.length < limit) {
      for (final cat in categories) {
        if (!ordered.contains(cat)) {
          ordered.add(cat);
          if (ordered.length >= limit) break;
        }
      }
    }

    return ordered;
  }

  @override
  Future<void> seedDefaultCategories() async {
    final userId = _currentUserId;
    final exists = await _isar.categoryModels.filter().userIdEqualTo(userId).findFirst();
    if (exists != null) return;

    final List<CategoryModel> defaults = [];

    // Seeding default income categories
    final defaultIncome = [
      {'name': 'Salary', 'icon': '💰', 'color': '#4CAF50'},
      {'name': 'Bonus', 'icon': '🎉', 'color': '#8BC34A'},
      {'name': 'Investment', 'icon': '📈', 'color': '#9C27B0'},
      {'name': 'Business', 'icon': '🏢', 'color': '#2196F3'},
      {'name': 'Freelance', 'icon': '💻', 'color': '#3F51B5'},
      {'name': 'Cashback', 'icon': '💸', 'color': '#00BCD4'},
      {'name': 'Gift', 'icon': '🎁', 'color': '#E91E63'},
      {'name': 'Other Income', 'icon': '💵', 'color': '#9E9E9E'},
    ];

    // Seeding default expense categories matching user interface screenshot
    final defaultExpense = [
      {'name': 'Transport', 'icon': '🚕', 'color': '#FFC107'},
      {'name': 'Apparel', 'icon': '🧥', 'color': '#2196F3'},
      {'name': 'Education', 'icon': '📙', 'color': '#FF9800'},
      {'name': 'Snacks', 'icon': '🍟', 'color': '#F44336'},
      {'name': 'Food', 'icon': '🌯', 'color': '#4CAF50'},
      {'name': 'Petrol', 'icon': '⛽', 'color': '#E91E63'},
      {'name': 'Dhobi', 'icon': '👚', 'color': '#E91E63'},
      {'name': 'Bike', 'icon': '🚲', 'color': '#4CAF50'},
      {'name': 'Movie', 'icon': '🎥', 'color': '#9C27B0'},
      {'name': 'Groceries', 'icon': '🛒', 'color': '#CDDC39'},
      {'name': 'Bills', 'icon': '🧾', 'color': '#FF5722'},
      {'name': 'Medical', 'icon': '💊', 'color': '#E53935'},
      {'name': 'Rent', 'icon': '🏠', 'color': '#795548'},
      {'name': 'Drink', 'icon': '🥤', 'color': '#00BCD4'},
      {'name': 'Other', 'icon': '📦', 'color': '#9E9E9E'},
    ];

    for (int i = 0; i < defaultIncome.length; i++) {
      final c = defaultIncome[i];
      defaults.add(
        CategoryModel()
          ..uuid = const Uuid().v4()
          ..userId = userId
          ..name = c['name']!
          ..type = 'income'
          ..icon = c['icon']!
          ..color = c['color']!
          ..order = i
          ..isDefault = true
          ..isDeleted = false
          ..isSynced = false
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..syncVersion = 1,
      );
    }

    for (int i = 0; i < defaultExpense.length; i++) {
      final c = defaultExpense[i];
      defaults.add(
        CategoryModel()
          ..uuid = const Uuid().v4()
          ..userId = userId
          ..name = c['name']!
          ..type = 'expense'
          ..icon = c['icon']!
          ..color = c['color']!
          ..order = i
          ..isDefault = true
          ..isDeleted = false
          ..isSynced = false
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..syncVersion = 1,
      );
    }

    await _isar.writeTxn(() async {
      await _isar.categoryModels.putAll(defaults);
    });
  }
}
