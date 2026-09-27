import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Expense categories matching the Stitch design system.
enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  education,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return AppStrings.categoryFood;
      case ExpenseCategory.transport:
        return AppStrings.categoryTransport;
      case ExpenseCategory.shopping:
        return AppStrings.categoryShopping;
      case ExpenseCategory.bills:
        return AppStrings.categoryBills;
      case ExpenseCategory.entertainment:
        return AppStrings.categoryEntertainment;
      case ExpenseCategory.health:
        return AppStrings.categoryHealth;
      case ExpenseCategory.education:
        return AppStrings.categoryEducation;
      case ExpenseCategory.other:
        return AppStrings.categoryOther;
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.bills:
        return Icons.bolt_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.health:
        return Icons.favorite_outline;
      case ExpenseCategory.education:
        return Icons.school_outlined;
      case ExpenseCategory.other:
        return Icons.more_horiz_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.categoryFood;
      case ExpenseCategory.transport:
        return AppColors.categoryTransport;
      case ExpenseCategory.shopping:
        return AppColors.categoryShopping;
      case ExpenseCategory.bills:
        return AppColors.categoryBills;
      case ExpenseCategory.entertainment:
        return AppColors.categoryEntertainment;
      case ExpenseCategory.health:
        return AppColors.categoryHealth;
      case ExpenseCategory.education:
        return AppColors.categoryEducation;
      case ExpenseCategory.other:
        return AppColors.categoryOther;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.categoryFoodBg;
      case ExpenseCategory.transport:
        return AppColors.categoryTransportBg;
      case ExpenseCategory.shopping:
        return AppColors.categoryShoppingBg;
      case ExpenseCategory.bills:
        return AppColors.categoryBillsBg;
      case ExpenseCategory.entertainment:
        return AppColors.categoryEntertainmentBg;
      case ExpenseCategory.health:
        return AppColors.categoryHealthBg;
      case ExpenseCategory.education:
        return AppColors.categoryEducationBg;
      case ExpenseCategory.other:
        return AppColors.categoryOtherBg;
    }
  }

  String get id => name;

  static ExpenseCategory fromId(String id) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == id,
      orElse: () => ExpenseCategory.other,
    );
  }
}
