import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/expense_providers.dart';
import '../../../../core/utils/expense_category.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/expense_tile.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../routing/app_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../../../features/expenses/domain/entities/expense_entity.dart';

class CategorySummaryView extends ConsumerStatefulWidget {
  const CategorySummaryView({super.key});

  @override
  ConsumerState<CategorySummaryView> createState() => _CategorySummaryViewState();
}

class _CategorySummaryViewState extends ConsumerState<CategorySummaryView> {
  ExpenseCategory? _expandedCategory;

  void _previousMonth() {
    final current = ref.read(selectedMonthProvider);
    final prevDate = DateTime(current.year, current.month - 1, 1);
    ref.read(selectedMonthProvider.notifier).state =
        SelectedMonth.from(prevDate.year, prevDate.month);
  }

  void _nextMonth() {
    final current = ref.read(selectedMonthProvider);
    final nextDate = DateTime(current.year, current.month + 1, 1);
    ref.read(selectedMonthProvider.notifier).state =
        SelectedMonth.from(nextDate.year, nextDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyExpensesAsync = ref.watch(monthlyExpensesProvider);
    final monthDate = DateTime(selectedMonth.year, selectedMonth.month);
    final monthFormatted = DateFormat('MMMM yyyy').format(monthDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.history);
              break;
            case 2:
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
        child: CustomScrollView(
          slivers: [
            // ─── Header & Month Switcher ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.categoryAnalytics,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Month selector pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainerLow
                            : AppColors.lightSurfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkOutlineVariant.withValues(alpha: 0.4)
                              : AppColors.lightOutlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: _previousMonth,
                            tooltip: 'Previous month',
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                monthFormatted,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: selectedMonth.isCurrentMonth
                                ? null
                                : _nextMonth,
                            tooltip: 'Next month',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Content ─────────────────────────────────────────────────────
            monthlyExpensesAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonCard(height: 80),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: ErrorStateWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(monthlyExpensesProvider),
                ),
              ),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'No expenses for $monthFormatted',
                      subtitle: 'Add expenses to see detailed category analytics.',
                      action: FilledButton.icon(
                        onPressed: () => context.go(AppRoutes.addExpense),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(AppStrings.addExpense),
                      ),
                    ),
                  );
                }

                final totalMonthly =
                    expenses.fold<double>(0, (sum, e) => sum + e.amount);

                // Group by category
                final Map<ExpenseCategory, List<ExpenseEntity>> byCat = {};
                for (final expense in expenses) {
                  byCat.putIfAbsent(expense.category, () => []).add(expense);
                }

                // Sort categories by highest amount spent
                final sortedCategories = byCat.keys.toList()
                  ..sort((a, b) {
                    final sumA =
                        byCat[a]!.fold<double>(0, (s, e) => s + e.amount);
                    final sumB =
                        byCat[b]!.fold<double>(0, (s, e) => s + e.amount);
                    return sumB.compareTo(sumA);
                  });

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Total Overview Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    AppColors.darkPrimaryContainer,
                                    AppColors.darkSurfaceContainerHighest,
                                  ]
                                : [
                                    AppColors.lightPrimary,
                                    AppColors.lightPrimaryContainer,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary)
                                  .withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL SPENT IN $monthFormatted'.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkOnPrimaryContainer
                                    : Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.currency(totalMonthly),
                              style: textTheme.displayMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkOnPrimaryContainer
                                    : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${expenses.length} transactions across ${byCat.keys.length} categories',
                              style: textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkOnPrimaryContainer
                                        .withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Segment bar overview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 12,
                          child: Row(
                            children: sortedCategories.map((cat) {
                              final catTotal = byCat[cat]!
                                  .fold<double>(0, (s, e) => s + e.amount);
                              final ratio =
                                  totalMonthly > 0 ? catTotal / totalMonthly : 0.0;
                              return Expanded(
                                flex: (ratio * 1000).toInt().clamp(1, 1000),
                                child: Container(
                                  color: cat.color,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Category Breakdown',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Cards List
                      ...sortedCategories.map((cat) {
                        final catExpenses = byCat[cat]!;
                        final catTotal = catExpenses.fold<double>(
                            0, (s, e) => s + e.amount);
                        final percent = totalMonthly > 0
                            ? (catTotal / totalMonthly) * 100
                            : 0.0;
                        final isExpanded = _expandedCategory == cat;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerLowest
                                : AppColors.lightSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded
                                  ? cat.color.withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _expandedCategory =
                                        isExpanded ? null : cat;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: cat.backgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              cat.icon,
                                              color: cat.color,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cat.label,
                                                  style: textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '${catExpenses.length} ${catExpenses.length == 1 ? 'transaction' : 'transactions'} • ${percent.toStringAsFixed(1)}%',
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                Formatters.currency(catTotal),
                                                style: textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Icon(
                                                isExpanded
                                                    ? Icons.expand_less_rounded
                                                    : Icons.expand_more_rounded,
                                                size: 20,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Progress bar
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: LinearProgressIndicator(
                                          value: percent / 100,
                                          backgroundColor: isDark
                                              ? AppColors
                                                  .darkSurfaceContainerHighest
                                              : AppColors
                                                  .lightSurfaceContainerHighest,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            cat.color,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded transactions list
                              if (isExpanded) ...[
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Transactions',
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(expenseFilterProvider
                                                  .notifier)
                                              .state = ExpenseFilter(
                                            category: cat,
                                            startDate: DateTime(
                                              selectedMonth.year,
                                              selectedMonth.month,
                                              1,
                                            ),
                                            endDate: DateTime(
                                              selectedMonth.year,
                                              selectedMonth.month + 1,
                                              0,
                                              23,
                                              59,
                                              59,
                                            ),
                                          );
                                          context.go(AppRoutes.history);
                                        },
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: const Text('View in History'),
                                      ),
                                    ],
                                  ),
                                ),
                                ...catExpenses.map((expense) => Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 8),
                                      child: ExpenseTile(
                                        expense: expense,
                                        onTap: () => context.go(
                                          '${AppRoutes.editExpense}/${expense.id}',
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 4),
                              ],
                            ],
                          ),
                        );
                      }),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
