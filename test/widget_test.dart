import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/core/utils/expense_category.dart';
import 'package:expense_tracker_app/core/utils/formatters.dart';
import 'package:expense_tracker_app/features/expenses/domain/entities/expense_entity.dart';

void main() {
  group('Expense Tracker Core Tests', () {
    test('Formatters format currency correctly', () {
      expect(Formatters.currency(1234.56), equals('\$1,234.56'));
      expect(Formatters.currency(0), equals('\$0.00'));
    });

    test('ExpenseCategory gives correct labels and icons', () {
      expect(ExpenseCategory.food.label, equals('Food & Dining'));
      expect(ExpenseCategory.transport.label, equals('Transport'));
      expect(ExpenseCategory.shopping.label, equals('Shopping'));
    });

    test('ExpenseEntity instantiates with valid parameters', () {
      final expense = ExpenseEntity(
        id: 'test-1',
        userId: 'user-1',
        title: 'Grocery Run',
        amount: 85.50,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 27),
        note: 'Weekly essentials',
        createdAt: DateTime(2026, 9, 27),
      );

      expect(expense.id, equals('test-1'));
      expect(expense.amount, equals(85.50));
      expect(expense.category, equals(ExpenseCategory.food));
    });
  });
}
