import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../splash/providers/initialization_provider.dart';
import '../../sync/providers/sync_provider.dart';
import '../data/datasources/local/account_local_datasource.dart';
import '../data/datasources/remote/account_remote_datasource.dart';
import '../domain/repositories/account_repository.dart';
import '../data/repositories/account_repository_impl.dart';
import '../domain/utils/search_engine.dart';
import '../domain/utils/filter_engine.dart';
import '../domain/utils/sort_engine.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import 'account_search_provider.dart';
import 'account_sort_provider.dart';
import 'account_filter_provider.dart';
import 'account_pagination_provider.dart';

final accountLocalDatasourceProvider = Provider<AccountLocalDatasource>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return AccountLocalDatasource(isarService.isar);
});

final accountRemoteDatasourceProvider = Provider<AccountRemoteDataSource>((ref) {
  return AccountRemoteDataSource(Supabase.instance.client);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final localDatasource = ref.watch(accountLocalDatasourceProvider);
  final remoteDatasource = ref.watch(accountRemoteDatasourceProvider);
  final syncService = ref.watch(syncServiceProvider);
  final supabase = Supabase.instance.client;
  return AccountRepositoryImpl(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    syncService: syncService,
    supabase: supabase,
  );
});

// Stream of standard active (non-deleted, non-archived) accounts
final accountsStreamProvider = StreamProvider<List<AccountModel>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAccounts();
});

// Stream of all active (non-deleted) accounts, including archived
final allAccountsStreamProvider = StreamProvider<List<AccountModel>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchAllAccounts();
});

final totalBalanceProvider = Provider<double>((ref) {
  final accountsAsyncValue = ref.watch(accountsStreamProvider);
  return accountsAsyncValue.maybeWhen(
    data: (accounts) => accounts.fold(0.0, (sum, item) => sum + item.balance),
    orElse: () => 0.0,
  );
});

// Current Account state provider
class CurrentAccountNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  static const String _key = 'current_account_uuid';

  CurrentAccountNotifier(this._prefs) : super(null) {
    _init();
  }

  CurrentAccountNotifier.dummy() : _prefs = null as dynamic, super(null);

  void _init() {
    state = _prefs.getString(_key);
  }

  Future<void> selectAccount(String? uuid) async {
    state = uuid;
    if (uuid != null) {
      await _prefs.setString(_key, uuid);
    } else {
      await _prefs.remove(_key);
    }
  }
}

final currentAccountProvider = StateNotifierProvider<CurrentAccountNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CurrentAccountNotifier(prefs);
});

// Exposes the currently selected AccountModel
final currentAccountModelProvider = Provider<AccountModel?>((ref) {
  final currentUuid = ref.watch(currentAccountProvider);
  final accountsAsync = ref.watch(allAccountsStreamProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) {
      if (currentUuid == null) {
        return accounts.isNotEmpty ? accounts.first : null;
      }
      return accounts.firstWhere((acc) => acc.uuid == currentUuid, orElse: () => accounts.first);
    },
    orElse: () => null,
  );
});

// Stream of everything (including deleted) for manage screens
final everythingAccountsStreamProvider = StreamProvider<List<AccountModel>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return repository.watchEverything();
});

// Unified filtered and paginated list of accounts
final filteredAccountsProvider = Provider<List<AccountModel>>((ref) {
  final accountsAsync = ref.watch(everythingAccountsStreamProvider);
  final searchQuery = ref.watch(accountSearchProvider);
  final sortOption = ref.watch(accountSortProvider);
  final filterOption = ref.watch(accountFilterProvider);
  final pagination = ref.watch(accountPaginationProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) {
      // 1. Filter
      var list = FilterEngine.filter(accounts: accounts, option: filterOption);

      // 2. Search
      list = SearchEngine.search(accounts: list, query: searchQuery);

      // 3. Sort
      SortEngine.sort(accounts: list, option: sortOption);

      // 4. Paginate
      final offset = pagination.page * pagination.limit;
      if (offset >= list.length) {
        return <AccountModel>[];
      }
      final end = (offset + pagination.limit).clamp(0, list.length);
      return list.sublist(offset, end);
    },
    orElse: () => [],
  );
});
