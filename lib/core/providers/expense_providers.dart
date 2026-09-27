import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../../../core/utils/expense_category.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

// ─── Filter State ─────────────────────────────────────────────────────────────

class ExpenseFilter {
  final ExpenseCategory? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const ExpenseFilter({
    this.category,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  ExpenseFilter copyWith({
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool clearCategory = false,
    bool clearDates = false,
    bool clearSearch = false,
  }) {
    return ExpenseFilter(
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasFilters =>
      category != null || startDate != null || searchQuery?.isNotEmpty == true;
}

// ─── Selected Month State ─────────────────────────────────────────────────────

class SelectedMonth {
  final int year;
  final int month;

  SelectedMonth({DateTime? date})
      : year = date?.year ?? DateTime.now().year,
        month = date?.month ?? DateTime.now().month;

  SelectedMonth.from(this.year, this.month);

  DateTime get asDateTime => DateTime(year, month);
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Currently selected month for dashboard
final selectedMonthProvider =
    StateProvider<SelectedMonth>((ref) => SelectedMonth());

/// Current expense filters for history screen
final expenseFilterProvider =
    StateProvider<ExpenseFilter>((ref) => const ExpenseFilter());

/// Real-time stream of user's expenses
final expensesStreamProvider = StreamProvider<List<ExpenseEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final repo = ref.read(expenseRepositoryProvider);
  return repo.watchExpenses(user.uid);
});

/// Expenses for the selected month
final monthlyExpensesProvider =
    FutureProvider<List<ExpenseEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final month = ref.watch(selectedMonthProvider);
  // Re-run when the real-time stream emits updates
  ref.watch(expensesStreamProvider);
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getExpensesByMonth(
    userId: user.uid,
    year: month.year,
    month: month.month,
  );
  return result.fold((_) => [], (expenses) => expenses);
});

/// Monthly total for selected month
final monthlyTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider).valueOrNull ?? [];
  return expenses.fold<double>(0, (sum, e) => sum + e.amount);
});

/// Category breakdown for selected month
final categoryBreakdownProvider =
    Provider<Map<ExpenseCategory, double>>((ref) {
  final expenses = ref.watch(monthlyExpensesProvider).valueOrNull ?? [];
  final breakdown = <ExpenseCategory, double>{};
  for (final expense in expenses) {
    breakdown[expense.category] =
        (breakdown[expense.category] ?? 0) + expense.amount;
  }
  return breakdown;
});

/// Recent expenses (last 5) from the stream
final recentExpensesProvider = Provider<List<ExpenseEntity>>((ref) {
  final all = ref.watch(expensesStreamProvider).valueOrNull ?? [];
  return all.take(5).toList();
});

// ─── Expense ViewModel ───────────────────────────────────────────────────────

class ExpenseOperationState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const ExpenseOperationState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ExpenseOperationState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return ExpenseOperationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ExpenseViewModel extends StateNotifier<ExpenseOperationState> {
  final ExpenseRepository _repository;

  ExpenseViewModel(this._repository) : super(const ExpenseOperationState());

  Future<bool> addExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final result = await _repository.addExpense(expense);
    return result.fold(
      (failure) {
        state = state.copyWith(
            isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  Future<bool> updateExpense(ExpenseEntity expense) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final result = await _repository.updateExpense(expense);
    return result.fold(
      (failure) {
        state = state.copyWith(
            isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  Future<bool> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final result = await _repository.deleteExpense(
      userId: userId,
      expenseId: expenseId,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
            isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const ExpenseOperationState();
  }
}

final expenseViewModelProvider =
    StateNotifierProvider<ExpenseViewModel, ExpenseOperationState>((ref) {
  return ExpenseViewModel(ref.read(expenseRepositoryProvider));
});

/// Filtered expenses for history screen
final filteredExpensesProvider =
    FutureProvider<List<ExpenseEntity>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final filter = ref.watch(expenseFilterProvider);
  // Re-run when the real-time stream emits updates
  ref.watch(expensesStreamProvider);
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getExpenses(
    userId: user.uid,
    category: filter.category,
    startDate: filter.startDate,
    endDate: filter.endDate,
    searchQuery: filter.searchQuery,
  );
  return result.fold((_) => [], (expenses) => expenses);
});
