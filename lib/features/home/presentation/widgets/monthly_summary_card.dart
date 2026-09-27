import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/expense_providers.dart';
import '../../../../core/utils/formatters.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Monthly summary card matching the Stitch gradient design.
class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyAsync = ref.watch(monthlyExpensesProvider);
    final total = ref.watch(monthlyTotalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Budget from settings or default
    double budget = 2500.0;
    try {
      final box = Hive.box('settings');
      final saved = box.get('monthlyBudget', defaultValue: 2500.0);
      if (saved is num) budget = saved.toDouble();
    } catch (_) {}

    final percentage = budget > 0 ? (total / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget - total).clamp(0.0, budget);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkPrimary,
                  AppColors.darkPrimaryContainer,
                  AppColors.darkSecondary,
                ]
              : [
                  AppColors.lightPrimary,
                  AppColors.lightPrimaryContainer,
                  AppColors.lightSecondary,
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: title + indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.darkSecondaryFixed
                                : AppColors.lightSecondaryFixed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.thisMonthTotal,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Month label
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        Formatters.monthYear(selectedMonth.asDateTime),
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                monthlyAsync.when(
                  loading: () => Container(
                    height: 48,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Error loading',
                    style: textTheme.headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  data: (_) => Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.currency(total),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'USD',
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Budget progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Formatters.currency(total)} of ${Formatters.currency(budget)} budget',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(0)}% ${AppStrings.budgetUsed}',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              colors: [
                                isDark
                                    ? AppColors.darkSecondaryFixedDim
                                    : AppColors.lightSecondaryFixedDim,
                                isDark
                                    ? AppColors.darkSecondaryFixed
                                    : AppColors.lightSecondaryFixed,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${Formatters.currency(remaining)} ${AppStrings.remaining}',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '${DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day - DateTime.now().day} ${AppStrings.daysLeft}',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
