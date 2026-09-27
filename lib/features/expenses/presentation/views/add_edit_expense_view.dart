import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/expense_providers.dart';
import '../../../../core/utils/expense_category.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../features/expenses/domain/entities/expense_entity.dart';

class AddEditExpenseView extends ConsumerStatefulWidget {
  /// When provided, we are editing an existing expense.
  final String? expenseId;

  const AddEditExpenseView({super.key, this.expenseId});

  @override
  ConsumerState<AddEditExpenseView> createState() => _AddEditExpenseViewState();
}

class _AddEditExpenseViewState extends ConsumerState<AddEditExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();
  bool _isInitialized = false;
  ExpenseEntity? _existingExpense;

  bool get isEditing => widget.expenseId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && isEditing) {
      _loadExpense();
    }
    _isInitialized = true;
  }

  void _loadExpense() {
    final expenses = ref.read(expensesStreamProvider).valueOrNull ?? [];
    final expense = expenses.firstWhere(
      (e) => e.id == widget.expenseId,
      orElse: () => expenses.isEmpty
          ? throw Exception('Expense not found')
          : expenses.first,
    );
    if (expense.id == widget.expenseId) {
      _existingExpense = expense;
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _noteController.text = expense.note ?? '';
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final amount = double.tryParse(
        _amountController.text.replaceAll(',', '').replaceAll('\$', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.amountMustBePositive)),
      );
      return;
    }

    final vm = ref.read(expenseViewModelProvider.notifier);

    bool success;
    if (isEditing && _existingExpense != null) {
      success = await vm.updateExpense(
        _existingExpense!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );
    } else {
      success = await vm.addExpense(
        ExpenseEntity(
          id: '',
          userId: user.uid,
          title: _titleController.text.trim(),
          amount: amount,
          category: _selectedCategory,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
    }

    if (success && mounted) {
      context.pop();
    }
  }

  Future<void> _delete() async {
    if (_existingExpense == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteExpense),
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final vm = ref.read(expenseViewModelProvider.notifier);
      final success = await vm.deleteExpense(
        userId: user.uid,
        expenseId: _existingExpense!.id,
      );
      if (success && mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final opState = ref.watch(expenseViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for errors
    ref.listen(expenseViewModelProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
        ref.read(expenseViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editExpense : AppStrings.addExpense),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: colorScheme.error),
              onPressed: opState.isLoading ? null : _delete,
              tooltip: AppStrings.deleteExpense,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error state
              if (opState.errorMessage != null) ...[
                _buildErrorBanner(opState.errorMessage!, colorScheme, textTheme),
                const SizedBox(height: 16),
              ],

              // ─── Amount Input ─────────────────────────────────────────
              _buildAmountSection(colorScheme, textTheme, isDark),
              const SizedBox(height: 24),

              // ─── Title ───────────────────────────────────────────────
              _buildSectionLabel('Expense Title', textTheme, colorScheme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'e.g. Whole Foods Market',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? AppStrings.fieldRequired : null,
              ),
              const SizedBox(height: 20),

              // ─── Category ─────────────────────────────────────────────
              _buildSectionLabel(AppStrings.expenseCategory, textTheme, colorScheme),
              const SizedBox(height: 12),
              _buildCategorySelector(colorScheme, textTheme),
              const SizedBox(height: 20),

              // ─── Date ─────────────────────────────────────────────────
              _buildSectionLabel(AppStrings.expenseDate, textTheme, colorScheme),
              const SizedBox(height: 8),
              _buildDatePicker(colorScheme, textTheme, isDark),
              const SizedBox(height: 20),

              // ─── Note ─────────────────────────────────────────────────
              _buildSectionLabel(AppStrings.expenseNote, textTheme, colorScheme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Add any additional notes...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded, size: 20),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // ─── Save Button ──────────────────────────────────────────
              FilledButton(
                onPressed: opState.isLoading ? null : _save,
                child: opState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing
                                ? AppStrings.updateExpense
                                : AppStrings.saveExpense,
                            style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection(
      ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurfaceContainerLow,
                  AppColors.darkSurfaceContainer,
                ]
              : [
                  AppColors.lightSurfaceContainerLow,
                  AppColors.lightSurfaceContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.expenseAmount,
            style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$',
                style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      letterSpacing: -1.2,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    errorStyle: const TextStyle(height: 0.01, fontSize: 0.01),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                    final amount = double.tryParse(v);
                    if (amount == null || amount <= 0) {
                      return AppStrings.amountMustBePositive;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? category.color.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? category.color
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected
                      ? category.color
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  category.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? category.color
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(
      ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceContainerLow
              : AppColors.lightSurfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              Formatters.longDate(_selectedDate),
              style: textTheme.bodyMedium,
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
      String label, TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildErrorBanner(
      String message, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
