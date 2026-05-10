import 'package:flutter/foundation.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';
import 'package:expense_tracker_flutter/models/budget.dart';
import 'package:expense_tracker_flutter/models/aggregates.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';

class BudgetProgress {
  final Budget budget;
  final double spent;

  BudgetProgress({
    required this.budget,
    required this.spent,
  });

  double get percentage => budget.amount > 0 ? spent / budget.amount : 0.0;
  double get remaining => budget.amount - spent;
}

class BudgetProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<BudgetProgress> _budgetProgresses = [];
  List<BudgetProgress> get budgetProgresses => _budgetProgresses;

  double _totalBudget = 0.0;
  double get totalBudget => _totalBudget;

  double _totalSpent = 0.0;
  double get totalSpent => _totalSpent;

  int _currentMonth = DateTime.now().month;
  int get currentMonth => _currentMonth;

  int _currentYear = DateTime.now().year;
  int get currentYear => _currentYear;

  BudgetProvider(this._repository) {
    loadBudgetData();
  }

  void setMonthYear(int month, int year) {
    _currentMonth = month;
    _currentYear = year;
    loadBudgetData();
  }

  Future<void> loadBudgetData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final budgets = await _repository.getAllBudgetsForMonth(_currentMonth, _currentYear);
      
      final startDate = DateTime(_currentYear, _currentMonth, 1);
      final endDate = DateTime(_currentYear, _currentMonth + 1, 0, 23, 59, 59);
      
      final categoryTotals = await _repository.getCategoryTotals(startDate, endDate);
      
      final totalSpentInMonth = await _repository.getTotalByType(TransactionType.expense, startDate, endDate);

      _budgetProgresses = budgets.map((budget) {
        final spent = categoryTotals
            .firstWhere(
              (ct) => ct.category == budget.category,
              orElse: () => CategoryTotal(category: budget.category, total: 0.0),
            )
            .total;
            
        return BudgetProgress(budget: budget, spent: spent);
      }).toList();
      
      _totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amount);
      _totalSpent = totalSpentInMonth;
      
    } catch (e) {
      debugPrint('Error loading budget data: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBudget(String category, double amount) async {
    try {
      final existingBudget = await _repository.getBudget(category, _currentMonth, _currentYear);
      
      if (existingBudget != null) {
        final updatedBudget = existingBudget.copyWith(amount: amount);
        await _repository.updateBudget(updatedBudget);
      } else {
        final newBudget = Budget(
          category: category,
          amount: amount,
          month: _currentMonth,
          year: _currentYear,
        );
        await _repository.insertBudget(newBudget);
      }
      
      await loadBudgetData();
    } catch (e) {
      debugPrint('Error saving budget: \$e');
    }
  }
}
