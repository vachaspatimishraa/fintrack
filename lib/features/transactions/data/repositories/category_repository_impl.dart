import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar/collections/category_model.dart';
import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../core/services/sync_service.dart';

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
        .watch(fireImmediately: true);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final userId = _currentUserId;
    var list = await _isar.categoryModels
        .filter()
        .userIdEqualTo(userId)
        .isDeletedEqualTo(false)
        .findAll();

    if (list.isEmpty) {
      await seedDefaultCategories();
      list = await _isar.categoryModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .findAll();
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
      {'name': 'Salary', 'icon': 'payments', 'color': '#4CAF50'},
      {'name': 'Bonus', 'icon': 'redeem', 'color': '#8BC34A'},
      {'name': 'Interest', 'icon': 'trending_up', 'color': '#009688'},
      {'name': 'Cashback', 'icon': 'local_offer', 'color': '#00BCD4'},
      {'name': 'Freelance', 'icon': 'work_outline', 'color': '#3F51B5'},
      {'name': 'Business', 'icon': 'store', 'color': '#2196F3'},
      {'name': 'Investment', 'icon': 'show_chart', 'color': '#9C27B0'},
      {'name': 'Gift', 'icon': 'card_giftcard', 'color': '#E91E63'},
      {'name': 'Other Income', 'icon': 'monetization_on', 'color': '#9E9E9E'},
    ];

    // Seeding default expense categories
    final defaultExpense = [
      {'name': 'Food', 'icon': 'restaurant', 'color': '#F44336'},
      {'name': 'Travel', 'icon': 'flight', 'color': '#FF9800'},
      {'name': 'Fuel', 'icon': 'local_gas_station', 'color': '#FFC107'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#E91E63'},
      {'name': 'Groceries', 'icon': 'shopping_cart', 'color': '#CDDC39'},
      {'name': 'Bills', 'icon': 'receipt', 'color': '#FF5722'},
      {'name': 'Medical', 'icon': 'medical_services', 'color': '#E53935'},
      {'name': 'Subscription', 'icon': 'subscriptions', 'color': '#9C27B0'},
      {'name': 'Rent', 'icon': 'home', 'color': '#795548'},
      {'name': 'Education', 'icon': 'school', 'color': '#3F51B5'},
      {'name': 'Entertainment', 'icon': 'sports_esports', 'color': '#00BCD4'},
      {'name': 'Other', 'icon': 'category', 'color': '#9E9E9E'},
    ];

    for (final c in defaultIncome) {
      defaults.add(
        CategoryModel()
          ..uuid = const Uuid().v4()
          ..userId = userId
          ..name = c['name']!
          ..type = 'income'
          ..icon = c['icon']!
          ..color = c['color']!
          ..isDefault = true
          ..isDeleted = false
          ..isSynced = false
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..syncVersion = 1,
      );
    }

    for (final c in defaultExpense) {
      defaults.add(
        CategoryModel()
          ..uuid = const Uuid().v4()
          ..userId = userId
          ..name = c['name']!
          ..type = 'expense'
          ..icon = c['icon']!
          ..color = c['color']!
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
