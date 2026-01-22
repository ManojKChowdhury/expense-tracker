import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';

class HomeUiState {
  final double monthlyBudget;
  final double totalSpent;
  final double todaySpent;
  final double totalIncome;
  final List<Transaction> recentTransactions;
  final bool isLoading;

  HomeUiState({
    this.monthlyBudget = 0.0,
    this.totalSpent = 0.0,
    this.todaySpent = 0.0,
    this.totalIncome = 0.0,
    this.recentTransactions = const [],
    this.isLoading = true,
  });

  HomeUiState copyWith({
    double? monthlyBudget,
    double? totalSpent,
    double? todaySpent,
    double? totalIncome,
    List<Transaction>? recentTransactions,
    bool? isLoading,
  }) {
    return HomeUiState(
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      totalSpent: totalSpent ?? this.totalSpent,
      todaySpent: todaySpent ?? this.todaySpent,
      totalIncome: totalIncome ?? this.totalIncome,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeProvider extends ChangeNotifier {
  final ExpenseRepository repository;
  HomeUiState _uiState = HomeUiState();

  HomeUiState get uiState => _uiState;

  HomeProvider(this.repository);

  Future<void> loadData() async {
    _uiState = _uiState.copyWith(isLoading: true);
    notifyListeners();

    try {
      final monthRange = repository.getCurrentMonthRange();
      final todayRange = repository.getTodayRange();
      final now = DateTime.now();

      // Load all data
      final budget = await repository.getBudget('OVERALL', now.month, now.year);
      final totalSpent = await repository.getTotalByType(
        TransactionType.expense,
        monthRange.start,
        monthRange.end,
      );
      final todaySpent = await repository.getTotalByType(
        TransactionType.expense,
        todayRange.start,
        todayRange.end,
      );
      final totalIncome = await repository.getTotalByType(
        TransactionType.income,
        monthRange.start,
        monthRange.end,
      );
      final recentTransactions = await repository.getRecentTransactions(limit: 10);

      _uiState = HomeUiState(
        monthlyBudget: budget?.amount ?? 0.0,
        totalSpent: totalSpent,
        todaySpent: todaySpent,
        totalIncome: totalIncome,
        recentTransactions: recentTransactions,
        isLoading: false,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  void refreshData() {
    loadData();
  }
}
