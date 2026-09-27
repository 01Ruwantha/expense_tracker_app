import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_providers.dart';
import '../features/auth/presentation/views/sign_in_view.dart';
import '../features/auth/presentation/views/sign_up_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/expenses/presentation/views/add_edit_expense_view.dart';
import '../features/history/presentation/views/history_view.dart';
import '../features/home/presentation/views/category_summary_view.dart';
import '../features/settings/presentation/views/settings_view.dart';

/// Named route constants
class AppRoutes {
  AppRoutes._();

  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String history = '/history';
  static const String categoryDetail = '/categories';
  static const String settings = '/settings';
}

/// Query parameters
class AppRouteParams {
  AppRouteParams._();
  static const String expenseId = 'expenseId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.signIn,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.signIn;
      }
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        name: 'sign-in',
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'sign-up',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        name: 'add-expense',
        builder: (context, state) => const AddEditExpenseView(),
      ),
      GoRoute(
        path: '${AppRoutes.editExpense}/:expenseId',
        name: 'edit-expense',
        builder: (context, state) {
          final expenseId = state.pathParameters[AppRouteParams.expenseId]!;
          return AddEditExpenseView(expenseId: expenseId);
        },
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryView(),
      ),
      GoRoute(
        path: AppRoutes.categoryDetail,
        name: 'categories',
        builder: (context, state) => const CategorySummaryView(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
