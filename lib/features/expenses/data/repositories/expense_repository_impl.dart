import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/either_result.dart';
import '../../../../core/utils/expense_category.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

/// Implementation of ExpenseRepository using Firestore.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<ExpenseEntity>> watchExpenses(String userId) {
    return _remoteDataSource.watchExpenses(userId);
  }

  @override
  EitherResult<List<ExpenseEntity>> getExpensesByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    try {
      final expenses = await _remoteDataSource.getExpensesByMonth(
        userId: userId,
        year: year,
        month: month,
      );
      return Right(expenses);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<List<ExpenseEntity>> getExpenses({
    required String userId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    try {
      final expenses = await _remoteDataSource.getExpenses(
        userId: userId,
        category: category,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
      );
      return Right(expenses);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    try {
      final result = await _remoteDataSource.addExpense(expense);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    try {
      final result = await _remoteDataSource.updateExpense(expense);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    try {
      await _remoteDataSource.deleteExpense(
          userId: userId, expenseId: expenseId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<double> getMonthlyTotal({
    required String userId,
    required int year,
    required int month,
  }) async {
    try {
      final expenses = await _remoteDataSource.getExpensesByMonth(
        userId: userId,
        year: year,
        month: month,
      );
      final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      return Right(total);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  EitherResult<Map<ExpenseCategory, double>> getCategoryBreakdown({
    required String userId,
    required int year,
    required int month,
  }) async {
    try {
      final expenses = await _remoteDataSource.getExpensesByMonth(
        userId: userId,
        year: year,
        month: month,
      );
      final breakdown = <ExpenseCategory, double>{};
      for (final expense in expenses) {
        breakdown[expense.category] =
            (breakdown[expense.category] ?? 0) + expense.amount;
      }
      return Right(breakdown);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
