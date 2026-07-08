import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../data/datasources/local/transaction_local_datasource.dart';
import '../data/datasources/remote/transaction_remote_datasource.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/entities/transaction_entity.dart';
import '../domain/entities/transaction_state.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/repositories/trash_repository.dart';
import '../data/repositories/trash_repository_impl.dart';
import '../../../core/services/receipt_service.dart';
import '../domain/utils/receipt_replacement_service.dart';
import '../../../../core/database/isar/collections/category_model.dart';
import '../domain/repositories/category_repository.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/repositories/receipt_repository.dart';
import '../data/repositories/receipt_repository_impl.dart';
import '../domain/utils/receipt_cache_service.dart';
import '../domain/utils/receipt_storage_service.dart';

final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasource>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return TransactionLocalDatasource(isarService.isar);
});

final transactionRemoteDatasourceProvider = Provider<TransactionRemoteDataSource>((ref) {
  final supabase = Supabase.instance.client;
  return TransactionRemoteDataSource(supabase);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final localDatasource = ref.watch(transactionLocalDatasourceProvider);
  final remoteDatasource = ref.watch(transactionRemoteDatasourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  final isarService = ref.watch(isarInitializationServiceProvider);
  return TransactionRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    syncService: syncService,
    supabase: supabase,
    isar: isarService.isar,
  );
});

final transactionsStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

class TransactionFilterNotifier extends StateNotifier<TransactionFilters> {
  TransactionFilterNotifier() : super(const TransactionFilters());

  void setQuery(String q) => state = state.copyWith(query: q);

  void setType(String? t) => t == null
      ? state = state.copyWith(clearType: true)
      : state = state.copyWith(type: t);

  void setCategoryId(String? id) => id == null
      ? state = state.copyWith(clearCategoryId: true)
      : state = state.copyWith(categoryId: id);

  void setCategory(String? c) => c == null
      ? state = state.copyWith(clearCategory: true)
      : state = state.copyWith(category: c);

  void setAccountId(String? a) => a == null
      ? state = state.copyWith(clearAccountId: true)
      : state = state.copyWith(accountId: a);

  void setDateRange(DateTimeRange? d) => d == null
      ? state = state.copyWith(clearDateRange: true)
      : state = state.copyWith(dateRange: d);

  void reset() => state = const TransactionFilters();
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilters>((ref) {
  return TransactionFilterNotifier();
});

final filteredTransactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final transactionsAsyncValue = ref.watch(transactionsStreamProvider);
  final filters = ref.watch(transactionFilterProvider);

  return transactionsAsyncValue.maybeWhen(
    data: (transactions) {
      return transactions.where((tx) {
        if (filters.query.isNotEmpty) {
          final q = filters.query.toLowerCase();
          final titleMatch = tx.title.toLowerCase().contains(q);
          final descMatch = tx.description.toLowerCase().contains(q);
          final catMatch = tx.category.toLowerCase().contains(q);
          if (!titleMatch && !descMatch && !catMatch) return false;
        }

        if (filters.type != null && tx.type != filters.type) return false;

        if (filters.categoryId != null && tx.categoryId != filters.categoryId) return false;
        if (filters.category != null && tx.category != filters.category) return false;

        if (filters.accountId != null && tx.accountId != filters.accountId) return false;

        if (filters.dateRange != null) {
          if (tx.date.isBefore(filters.dateRange!.start) ||
              tx.date.isAfter(filters.dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

final trashRepositoryProvider = Provider<TrashRepository>((ref) {
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return TrashRepositoryImpl(transactionRepo);
});

final receiptServiceProvider = Provider<ReceiptService>((ref) => ReceiptService());

final receiptReplacementServiceProvider = Provider<ReceiptReplacementService>((ref) {
  final receiptService = ref.watch(receiptServiceProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return ReceiptReplacementService(
    receiptService: receiptService,
    transactionRepository: transactionRepo,
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  return CategoryRepositoryImpl(
    isar: isarService.isar,
    supabase: supabase,
    syncService: syncService,
  );
});

final receiptCacheServiceProvider = Provider<ReceiptCacheService>((ref) => ReceiptCacheService());
final receiptStorageServiceProvider = Provider<ReceiptStorageService>((ref) => ReceiptStorageService(Supabase.instance.client));

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  final cache = ref.watch(receiptCacheServiceProvider);
  final storage = ref.watch(receiptStorageServiceProvider);
  return ReceiptRepositoryImpl(
    isar: isarService.isar,
    supabase: supabase,
    syncService: syncService,
    cacheService: cache,
    storageService: storage,
  );
});

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});
