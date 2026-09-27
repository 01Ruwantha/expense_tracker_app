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
  ConsumerState<CategorySummaryView> createState() =>
      _CategorySummaryViewState();
}

class _CategorySummaryViewState extends ConsumerState<CategorySummaryView> {
  ExpenseCategory? _expandedCategory;

  void _previousMonth() {
    final current = ref.read(selectedMonthProvider);
    final prev = DateTime(current.year, current.month - 1, 1);
    ref.read(selectedMonthProvider.notifier).state =
        SelectedMonth.from(prev.year, prev.month);
  }

  void _nextMonth() {
    final current = ref.read(selectedMonthProvider);
    final next = DateTime(current.year, current.month + 1, 1);
    ref.read(selectedMonthProvider.notifier).state =
        SelectedMonth.from(next.year, next.month);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyExpensesAsync = ref.watch(monthlyExpensesProvider);
    final monthFormatted = DateFormat('MMMM yyyy')
        .format(DateTime(selectedMonth.year, selectedMonth.month));

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
        onPressed: () => context.push(AppRoutes.addExpense),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ─── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                      'Analytics',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceContainer
                                : AppColors.lightSurfaceContainer,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16, color: colorScheme.primary),
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
                          onPressed:
                              selectedMonth.isCurrentMonth ? null : _nextMonth,
                          icon: const Icon(Icons.chevron_right_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceContainer
                                : AppColors.lightSurfaceContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Content ─────────────────────────────────────────────────────
            monthlyExpensesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SkeletonCard(height: 280),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.pie_chart_outline_rounded,
                      title: 'No expenses for $monthFormatted',
                      subtitle: 'Add expenses to see analytics.',
                      action: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.addExpense),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(AppStrings.addExpense),
                      ),
                    ),
                  );
                }

                final total =
                    expenses.fold<double>(0, (sum, e) => sum + e.amount);

                final Map<ExpenseCategory, List<ExpenseEntity>> byCat = {};
                for (final e in expenses) {
                  byCat.putIfAbsent(e.category, () => []).add(e);
                }

                final sortedCategories = byCat.keys.toList()
                  ..sort((a, b) {
                    final sumA = byCat[a]!.fold(0.0, (s, e) => s + e.amount);
                    final sumB = byCat[b]!.fold(0.0, (s, e) => s + e.amount);
                    return sumB.compareTo(sumA);
                  });

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Donut Chart Card ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerLowest
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: CustomPaint(
                                painter: _DonutChartPainter(
                                  categories: sortedCategories,
                                  byCat: byCat,
                                  total: total,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'TOTAL SPENT',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.currency(total),
                                        style:
                                            textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkSurfaceContainer
                                              : AppColors.lightSurfaceContainer,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          '${expenses.length} Expenses',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Legend
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: sortedCategories.map((cat) {
                                final catTotal = byCat[cat]!
                                    .fold(0.0, (s, e) => s + e.amount);
                                final percent =
                                    total > 0 ? (catTotal / total) * 100 : 0.0;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceContainerLow
                                        : AppColors.lightSurfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: cat.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${cat.label.split(' ').first} ${percent.toStringAsFixed(1)}%',
                                        style: textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Insight Card ───────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerLow
                              : AppColors.lightSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSecondaryContainer
                                    : AppColors.lightSecondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lightbulb_rounded,
                                color: isDark
                                    ? AppColors.darkOnSecondaryContainer
                                    : AppColors.lightOnSecondaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MONTHLY INSIGHT',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'You have ${expenses.length} expenses totaling ${Formatters.currency(total)} this month.',
                                    style: textTheme.bodyMedium
                                        ?.copyWith(height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Categories Header ──────────────────────────────────
                      Text(
                        'Categories',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a category to expand and see transactions',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Category Cards (Expandable) ────────────────────────
                      ...sortedCategories.map((cat) {
                        final catExpenses = byCat[cat]!;
                        final catTotal =
                            catExpenses.fold(0.0, (s, e) => s + e.amount);
                        final percent =
                            total > 0 ? (catTotal / total) * 100 : 0.0;
                        final isExpanded = _expandedCategory == cat;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceContainerLowest
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isExpanded
                                  ? cat.color.withValues(alpha: 0.45)
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
                              // Header – tap to expand / collapse
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _expandedCategory = isExpanded ? null : cat;
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
                                            child: Icon(cat.icon,
                                                color: cat.color, size: 22),
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
                                                  '${catExpenses.length} transactions • ${percent.toStringAsFixed(1)}%',
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
                                                style: textTheme.titleSmall
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
                                                  cat.color),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded transactions
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
                                ...catExpenses.map(
                                  (expense) => Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 0, 12, 8),
                                    child: ExpenseTile(
                                      expense: expense,
                                      onTap: () => context.push(
                                        '${AppRoutes.editExpense}/${expense.id}',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // ── Export Buttons ─────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('PDF export coming soon')),
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf_rounded,
                                  color: Colors.redAccent),
                              label: const Text('Export PDF'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('CSV export coming soon')),
                                );
                              },
                              icon: Icon(Icons.table_view_rounded,
                                  color: colorScheme.primary),
                              label: const Text('Export CSV'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

/// Simple donut chart painter
class _DonutChartPainter extends CustomPainter {
  final List<ExpenseCategory> categories;
  final Map<ExpenseCategory, List<ExpenseEntity>> byCat;
  final double total;

  _DonutChartPainter({
    required this.categories,
    required this.byCat,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 28.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -90 * (3.1415926535 / 180);

    for (final cat in categories) {
      final catTotal = byCat[cat]!.fold(0.0, (s, e) => s + e.amount);
      final sweepAngle = (catTotal / total) * 2 * 3.1415926535;

      final paint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
