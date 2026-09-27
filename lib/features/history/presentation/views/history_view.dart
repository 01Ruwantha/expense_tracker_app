import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/expense_providers.dart';
import '../../../../core/utils/expense_category.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/expense_tile.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../routing/app_router.dart';
import '../../../../features/home/presentation/widgets/bottom_nav_bar.dart';
import '../../../../features/expenses/domain/entities/expense_entity.dart';

enum DateQuickFilter { all, thisMonth, last7Days, custom }

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final _searchController = TextEditingController();
  DateQuickFilter _dateFilter = DateQuickFilter.all;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(expenseFilterProvider);
    if (filter.searchQuery != null) {
      _searchController.text = filter.searchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(expenseFilterProvider.notifier).update(
          (state) => state.copyWith(
            searchQuery: query.trim().isEmpty ? null : query.trim(),
            clearSearch: query.trim().isEmpty,
          ),
        );
  }

  void _selectCategory(ExpenseCategory? category) {
    ref.read(expenseFilterProvider.notifier).update(
          (state) => state.copyWith(
            category: category,
            clearCategory: category == null,
          ),
        );
  }

  void _applyDateFilter(DateQuickFilter quickFilter) async {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (quickFilter) {
      case DateQuickFilter.all:
        start = null;
        end = null;
        break;
      case DateQuickFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case DateQuickFilter.last7Days:
        start = DateTime(now.year, now.month, now.day - 7);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateQuickFilter.custom:
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: DateTimeRange(
            start: ref.read(expenseFilterProvider).startDate ??
                now.subtract(const Duration(days: 30)),
            end: ref.read(expenseFilterProvider).endDate ?? now,
          ),
        );
        if (range == null) return;
        start = range.start;
        end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
        break;
    }

    setState(() => _dateFilter = quickFilter);
    ref.read(expenseFilterProvider.notifier).update(
          (state) => state.copyWith(
            startDate: start,
            endDate: end,
            clearDates: quickFilter == DateQuickFilter.all,
          ),
        );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() => _dateFilter = DateQuickFilter.all);
    ref.read(expenseFilterProvider.notifier).state = const ExpenseFilter();
  }

  Future<void> _deleteExpense(ExpenseEntity expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteExpense),
        content: Text(
          'Are you sure you want to delete "${expense.title}" (${Formatters.currency(expense.amount)})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lightError,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final success = await ref
            .read(expenseViewModelProvider.notifier)
            .deleteExpense(userId: user.uid, expenseId: expense.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? 'Expense deleted' : 'Failed to delete expense',
              ),
              backgroundColor: success ? AppColors.lightPrimary : AppColors.lightError,
            ),
          );
        }
      }
    }
  }

  Map<String, List<ExpenseEntity>> _groupByDate(List<ExpenseEntity> expenses) {
    final groups = <String, List<ExpenseEntity>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final expense in expenses) {
      final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      String key;
      if (expDate == today) {
        key = 'Today';
      } else if (expDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMMM d, yyyy').format(expense.date);
      }

      groups.putIfAbsent(key, () => []).add(expense);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filter = ref.watch(expenseFilterProvider);
    final expensesAsync = ref.watch(filteredExpensesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              break;
            case 2:
              context.go(AppRoutes.categoryDetail);
              break;
            case 3:
              context.go(AppRoutes.settings);
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addExpense),
        tooltip: AppStrings.addExpense,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Header title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            AppStrings.history,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (filter.hasFilters)
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            textStyle: textTheme.labelMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainerLow
                          : AppColors.lightSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkOutlineVariant.withValues(alpha: 0.5)
                            : AppColors.lightOutlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: AppStrings.search,
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Category filter horizontal pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    children: [
                      // All Categories chip
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: filter.category == null,
                          label: const Text('All'),
                          onSelected: (_) => _selectCategory(null),
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceContainerHigh
                              : AppColors.lightSurfaceContainerHigh,
                          selectedColor: colorScheme.primaryContainer,
                          labelStyle: textTheme.labelMedium?.copyWith(
                            color: filter.category == null
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                            fontWeight: filter.category == null
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          showCheckmark: false,
                        ),
                      ),
                      // Individual Category chips
                      ...ExpenseCategory.values.map((cat) {
                        final isSelected = filter.category == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(cat.icon, size: 16, color: cat.color),
                            selected: isSelected,
                            label: Text(cat.label),
                            onSelected: (_) =>
                                _selectCategory(isSelected ? null : cat),
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceContainerHigh
                                : AppColors.lightSurfaceContainerHigh,
                            selectedColor: cat.backgroundColor,
                            labelStyle: textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? cat.color
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Date range chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: Row(
                    children: [
                      _buildDateChip('All Time', DateQuickFilter.all),
                      const SizedBox(width: 8),
                      _buildDateChip('This Month', DateQuickFilter.thisMonth),
                      const SizedBox(width: 8),
                      _buildDateChip('7 Days', DateQuickFilter.last7Days),
                      const SizedBox(width: 8),
                      _buildDateChip(
                        filter.startDate != null && _dateFilter == DateQuickFilter.custom
                            ? '${DateFormat('MMM d').format(filter.startDate!)} - ${DateFormat('MMM d').format(filter.endDate!)}'
                            : 'Custom',
                        DateQuickFilter.custom,
                        icon: Icons.calendar_month_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: expensesAsync.when(
            loading: () => ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => const SkeletonListTile(),
            ),
            error: (err, _) => ErrorStateWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(filteredExpensesProvider),
            ),
            data: (expenses) {
              if (expenses.isEmpty) {
                if (filter.hasFilters) {
                  return EmptyStateWidget.noResults();
                }
                return EmptyStateWidget.noExpenses(
                  onAddTap: FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.addExpense),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(AppStrings.addExpense),
                  ),
                );
              }

              // Compute total for filtered list
              final totalAmount = expenses.fold<double>(0, (sum, e) => sum + e.amount);
              final grouped = _groupByDate(expenses);

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: grouped.keys.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Summary card header
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainerHigh
                            : AppColors.lightSurfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${expenses.length} ${expenses.length == 1 ? 'transaction' : 'transactions'}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            Formatters.currency(totalAmount),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupKey = grouped.keys.elementAt(index - 1);
                  final groupExpenses = grouped[groupKey]!;
                  final groupTotal =
                      groupExpenses.fold<double>(0, (sum, e) => sum + e.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Group Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              groupKey,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              Formatters.currency(groupTotal),
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Expenses in this group
                      ...groupExpenses.map((expense) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.lightError.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.lightError,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              _deleteExpense(expense);
                              return false; // delete dialog will handle deletion
                            },
                            child: ExpenseTile(
                              expense: expense,
                              onTap: () => context.go(
                                '${AppRoutes.editExpense}/${expense.id}',
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, DateQuickFilter filterType, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = _dateFilter == filterType;

    return Expanded(
      child: GestureDetector(
        onTap: () => _applyDateFilter(filterType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : (isDark
                    ? AppColors.darkSurfaceContainerLow
                    : AppColors.lightSurfaceContainerLow),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : (isDark
                      ? AppColors.darkOutlineVariant.withValues(alpha: 0.3)
                      : AppColors.lightOutlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
