import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/transaction_model.dart';
import '../../../domain/entities/transaction_query_filter.dart';

class TransactionLocalDatasource {
  final Isar _isar;

  TransactionLocalDatasource(this._isar);

  Stream<List<TransactionModel>> watchTransactions(String? userId) {
    if (userId != null) {
      return _isar.transactionModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    } else {
      return _isar.transactionModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    }
  }

  Future<List<TransactionModel>> getTransactions(String? userId) async {
    if (userId != null) {
      return _isar.transactionModels
          .filter()
          .userIdEqualTo(userId)
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .findAll();
    } else {
      return _isar.transactionModels
          .filter()
          .userIdIsNull()
          .isDeletedEqualTo(false)
          .sortByDateDesc()
          .findAll();
    }
  }

  Future<List<TransactionModel>> getTransactionsPaginated({
    required String? userId,
    required int limit,
    required int offset,
    required TransactionQueryFilter queryFilter,
  }) async {
    QueryBuilder<TransactionModel, TransactionModel, QFilterCondition> query =
        _isar.transactionModels.filter();

    if (userId != null) {
      query = query.userIdEqualTo(userId);
    } else {
      query = query.userIdIsNull();
    }

    if (queryFilter.isDeleted != null) {
      query = query.isDeletedEqualTo(queryFilter.isDeleted!);
    }

    if (queryFilter.type != null) {
      query = query.typeEqualTo(queryFilter.type!);
    }

    if (queryFilter.categories.isNotEmpty) {
      query = query.group((q) {
        QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>? subQ;
        for (var i = 0; i < queryFilter.categories.length; i++) {
          if (i == 0) {
            subQ = q.categoryEqualTo(queryFilter.categories[i]);
          } else {
            subQ = subQ!.or().categoryEqualTo(queryFilter.categories[i]);
          }
        }
        return subQ!;
      });
    }

    if (queryFilter.accountId != null) {
      query = query.accountIdEqualTo(queryFilter.accountId!);
    }

    if (queryFilter.paymentMethod != null) {
      query = query.paymentMethodEqualTo(queryFilter.paymentMethod!);
    }

    if (queryFilter.dateRange != null) {
      query = query.dateGreaterThan(queryFilter.dateRange!.start.subtract(const Duration(milliseconds: 1)))
          .and()
          .dateLessThan(queryFilter.dateRange!.end.add(const Duration(days: 1)));
    }

    if (queryFilter.minAmount != null || queryFilter.maxAmount != null) {
      if (queryFilter.amountComparison == 'greater' && queryFilter.minAmount != null) {
        query = query.amountGreaterThan(queryFilter.minAmount!);
      } else if (queryFilter.amountComparison == 'less' && queryFilter.maxAmount != null) {
        query = query.amountLessThan(queryFilter.maxAmount!);
      } else if (queryFilter.minAmount != null && queryFilter.maxAmount != null) {
        query = query.amountGreaterThan(queryFilter.minAmount!).and().amountLessThan(queryFilter.maxAmount!);
      }
    }

    if (queryFilter.hasReceipt != null) {
      if (queryFilter.hasReceipt!) {
        query = query.group((q) => q.receiptUrlIsNotNull().or().receiptLocalPathIsNotNull());
      } else {
        query = query.receiptUrlIsNull().and().receiptLocalPathIsNull();
      }
    }

    if (queryFilter.syncStatus != null) {
      if (queryFilter.syncStatus == 'pending') {
        query = query.isSyncedEqualTo(false);
      } else if (queryFilter.syncStatus == 'synced') {
        query = query.isSyncedEqualTo(true);
      }
    }

    if (queryFilter.isRecurring != null) {
      query = query.isRecurringEqualTo(queryFilter.isRecurring!);
    }

    if (queryFilter.query.trim().isNotEmpty) {
      final qStr = queryFilter.query.trim();
      query = query.group((q) {
        return q
            .titleContains(qStr, caseSensitive: false)
            .or()
            .descriptionContains(qStr, caseSensitive: false)
            .or()
            .categoryContains(qStr, caseSensitive: false)
            .or()
            .paymentMethodContains(qStr, caseSensitive: false);
      });
    }

    final sortableQuery = query as QueryBuilder<TransactionModel, TransactionModel, QAfterFilterCondition>;
    QueryBuilder<TransactionModel, TransactionModel, QAfterSortBy> sortedQuery;
    switch (queryFilter.sortBy) {
      case 'oldest':
        sortedQuery = sortableQuery.sortByDate();
        break;
      case 'highest_amount':
        sortedQuery = sortableQuery.sortByAmountDesc();
        break;
      case 'lowest_amount':
        sortedQuery = sortableQuery.sortByAmount();
        break;
      case 'recently_updated':
        sortedQuery = sortableQuery.sortByUpdatedAtDesc();
        break;
      case 'alphabetical':
        sortedQuery = sortableQuery.sortByTitle();
        break;
      case 'category':
        sortedQuery = sortableQuery.sortByCategory();
        break;
      case 'newest':
      default:
        sortedQuery = sortableQuery.sortByDateDesc();
        break;
    }

    return sortedQuery.offset(offset).limit(limit).findAll();
  }

  Future<TransactionModel?> getTransactionByUuid(String uuid) {
    return _isar.transactionModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> putTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(transaction);
    });
  }

  Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.delete(id);
    });
  }
}
