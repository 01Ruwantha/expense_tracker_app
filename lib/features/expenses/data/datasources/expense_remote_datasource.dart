import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../core/utils/expense_category.dart';
import '../models/expense_model.dart';

/// Firestore data source for expenses.
class ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ExpenseRemoteDataSource({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  CollectionReference<Map<String, dynamic>> _expensesCollection(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('expenses');

  /// Watch expenses in real-time.
  Stream<List<ExpenseEntity>> watchExpenses(String userId) {
    return _expensesCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList());
  }

  /// Get expenses for a specific month.
  Future<List<ExpenseEntity>> getExpensesByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final snapshot = await _expensesCollection(userId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromFirestore(doc))
        .toList();
  }

  /// Get expenses with optional filters.
  Future<List<ExpenseEntity>> getExpenses({
    required String userId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    Query<Map<String, dynamic>> query =
        _expensesCollection(userId).orderBy('date', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.id);
    }
    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThan: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    List<ExpenseEntity> expenses =
        snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();

    // Client-side search (Firestore doesn't support full-text search natively)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      expenses = expenses
          .where((e) =>
              e.title.toLowerCase().contains(query) ||
              (e.note?.toLowerCase().contains(query) ?? false) ||
              e.category.label.toLowerCase().contains(query))
          .toList();
    }

    return expenses;
  }

  /// Add a new expense.
  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final model = ExpenseModel(
      id: id,
      userId: expense.userId,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
      createdAt: now,
      updatedAt: null,
    );

    await _expensesCollection(expense.userId).doc(id).set(model.toFirestore());
    return model;
  }

  /// Update an existing expense.
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    final now = DateTime.now();
    final model = ExpenseModel.fromEntity(expense).copyWith(updatedAt: now);

    await _expensesCollection(expense.userId)
        .doc(expense.id)
        .update(model.toFirestore());
    return model;
  }

  /// Delete an expense.
  Future<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    await _expensesCollection(userId).doc(expenseId).delete();
  }
}
