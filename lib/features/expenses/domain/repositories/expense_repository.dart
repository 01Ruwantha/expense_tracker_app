import '../../../../core/errors/either_result.dart';
import '../../../../core/utils/expense_category.dart';
import '../entities/expense_entity.dart';

/// Expense repository interface (domain layer).
abstract class ExpenseRepository {
  /// Watch expenses for a user in real-time.
  Stream<List<ExpenseEntity>> watchExpenses(String userId);

  /// Get expenses for a specific month.
  EitherResult<List<ExpenseEntity>> getExpensesByMonth({
    required String userId,
    required int year,
    required int month,
  });

  /// Get all expenses with optional filtering.
  EitherResult<List<ExpenseEntity>> getExpenses({
    required String userId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });

  /// Add a new expense to Firestore.
  EitherResult<ExpenseEntity> addExpense(ExpenseEntity expense);

  /// Update an existing expense.
  EitherResult<ExpenseEntity> updateExpense(ExpenseEntity expense);

  /// Delete an expense by ID.
  EitherResult<void> deleteExpense({
    required String userId,
    required String expenseId,
  });

  /// Get total amount for a specific month.
  EitherResult<double> getMonthlyTotal({
    required String userId,
    required int year,
    required int month,
  });

  /// Get category breakdown for a month.
  EitherResult<Map<ExpenseCategory, double>> getCategoryBreakdown({
    required String userId,
    required int year,
    required int month,
  });
}
