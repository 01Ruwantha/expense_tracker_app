import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/expense_providers.dart';
import '../../../../core/widgets/expense_tile.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../routing/app_router.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/category_card.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              context.go(AppRoutes.history);
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
        onPressed: () => context.push(AppRoutes.addExpense),
        tooltip: AppStrings.addExpense,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor:
                  (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                      .withValues(alpha: 0.92),
              surfaceTintColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        size: 18, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 10),
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
                      Text(AppStrings.dashboard, style: textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined,
                      color: colorScheme.onSurfaceVariant),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),

            // ─── Body ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  // Greeting
                  _buildGreeting(colorScheme, textTheme, user?.name ?? 'User'),
                  const SizedBox(height: 20),

                  // Monthly Summary Card
                  const MonthlySummaryCard(),
                  const SizedBox(height: 20),

                  // Month selector tabs
                  _buildMonthSelector(colorScheme, textTheme),
                  const SizedBox(height: 20),

                  // Category Breakdown
                  _buildCategorySection(colorScheme, textTheme),
                  const SizedBox(height: 20),

                  // Recent Expenses
                  _buildRecentExpenses(colorScheme, textTheme),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(
      ColorScheme colorScheme, TextTheme textTheme, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${AppStrings.hello}, $name ',
                  style: textTheme.headlineLarge,
                ),
                const Text('👋', style: TextStyle(fontSize: 22)),
              ],
            ),
            Text(
              AppStrings.monthlyOverview,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.wallet_outlined,
                    color: colorScheme.primary, size: 24),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(ColorScheme colorScheme, TextTheme textTheme) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MonthChip(
            label: AppStrings.thisMonth,
            icon: Icons.calendar_today_rounded,
            isSelected: selectedMonth.isCurrentMonth,
            onTap: () => ref.read(selectedMonthProvider.notifier).state =
                SelectedMonth(),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(width: 8),
          _MonthChip(
            label: AppStrings.lastMonth,
            icon: Icons.history_rounded,
            isSelected: !selectedMonth.isCurrentMonth &&
                selectedMonth.month == (now.month == 1 ? 12 : now.month - 1),
            onTap: () {
              final lastMonth = DateTime(now.year, now.month - 1);
              ref.read(selectedMonthProvider.notifier).state =
                  SelectedMonth(date: lastMonth);
            },
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(width: 8),
          _MonthChip(
            label: AppStrings.customRange,
            icon: Icons.tune_rounded,
            isSelected: false,
            onTap: () => _showMonthPicker(context),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ColorScheme colorScheme, TextTheme textTheme) {
    final breakdown = ref.watch(categoryBreakdownProvider);
    final total = ref.watch(monthlyTotalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.categoriesBreakdown, style: textTheme.titleLarge),
            Text(
              '${breakdown.length} ${AppStrings.categories}',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (breakdown.isEmpty)
          Center(
            child: Text(
              'No expenses this month',
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          SizedBox(
            height: 144,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: breakdown.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = breakdown.entries.elementAt(index);
                final percentage =
                    total > 0 ? (entry.value / total * 100) : 0.0;
                return CategoryCard(
                  category: entry.key,
                  amount: entry.value,
                  percentage: percentage.toDouble(),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentExpenses(ColorScheme colorScheme, TextTheme textTheme) {
    final expensesAsync = ref.watch(expensesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentExpenses,
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () => context.go(AppRoutes.history),
              child: Row(
                children: [
                  Text(AppStrings.viewAll,
                      style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600)),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: colorScheme.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        expensesAsync.when(
          loading: () => Column(
            children: List.generate(
                4,
                (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ExpenseItemSkeleton(),
                    )),
          ),
          error: (error, _) => ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(expensesStreamProvider),
          ),
          data: (expenses) {
            if (expenses.isEmpty) {
              return EmptyStateWidget.noExpenses(
                onAddTap: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.addExpense),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(AppStrings.addExpense),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(160, 44),
                  ),
                ),
              );
            }
            final recent = expenses.take(5).toList();
            return Column(
              children: recent
                  .map((expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ExpenseTile(
                          expense: expense,
                          onTap: () {
                            if (expense.id.isEmpty) {
                              return;
                            }
                            context.pushNamed(
                              'edit-expense',
                              pathParameters: {
                                AppRouteParams.expenseId: expense.id
                              },
                            );
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Select Month',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && mounted) {
      ref.read(selectedMonthProvider.notifier).state =
          SelectedMonth(date: picked);
    }
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _MonthChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
