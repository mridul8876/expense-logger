
import 'database_helper.dart';
import 'expense.dart';

class ExpenseRepository {
  ExpenseRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> addExpense(Expense expense) async {
    await _databaseHelper.insertTransaction(expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final rows = await _databaseHelper.getTransactions();

    return rows.map((row) => Expense.fromMap(row)).toList();
  }

  Future<void> updateExpense(Expense expense) async {
    final updatedRows =
    await _databaseHelper.updateTransaction(expense.toMap());

    if (updatedRows == 0) {
      throw StateError('Transaction not found: ${expense.id}');
    }
  }

  Future<void> deleteExpense(String id) async {
    await _databaseHelper.deleteTransaction(id);
  }
}
