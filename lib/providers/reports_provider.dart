import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/models/aggregates.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';

enum ReportPeriod {
  thisWeek,
  thisMonth,
  lastMonth,
}

class ReportsUiState {
  final double totalSpent;
  final List<CategoryTotal> categoryTotals;
  final List<DailyTotal> dailyTotals;
  final ReportPeriod selectedPeriod;
  final bool isLoading;

  ReportsUiState({
    this.totalSpent = 0.0,
    this.categoryTotals = const [],
    this.dailyTotals = const [],
    this.selectedPeriod = ReportPeriod.thisMonth,
    this.isLoading = true,
  });

  ReportsUiState copyWith({
    double? totalSpent,
    List<CategoryTotal>? categoryTotals,
    List<DailyTotal>? dailyTotals,
    ReportPeriod? selectedPeriod,
    bool? isLoading,
  }) {
    return ReportsUiState(
      totalSpent: totalSpent ?? this.totalSpent,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportsProvider extends ChangeNotifier {
  final ExpenseRepository repository;
  ReportsUiState _uiState = ReportsUiState();

  ReportsUiState get uiState => _uiState;

  ReportsProvider(this.repository);

  Future<void> loadData() async {
    _uiState = _uiState.copyWith(isLoading: true);
    notifyListeners();

    try {
      final dateRange = _getDateRangeForPeriod(_uiState.selectedPeriod);

      final totalSpent = await repository.getTotalByType(
        TransactionType.expense,
        dateRange.start,
        dateRange.end,
      );
      final categoryTotals = await repository.getCategoryTotals(
        dateRange.start,
        dateRange.end,
      );
      final dailyTotals = await repository.getDailyTotals(
        dateRange.start,
        dateRange.end,
      );

      _uiState = ReportsUiState(
        totalSpent: totalSpent,
        categoryTotals: categoryTotals,
        dailyTotals: dailyTotals,
        selectedPeriod: _uiState.selectedPeriod,
        isLoading: false,
      );
      notifyListeners();
    } catch (e) {
      _uiState = _uiState.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  void selectPeriod(ReportPeriod period) {
    _uiState = _uiState.copyWith(selectedPeriod: period, isLoading: true);
    notifyListeners();
    loadData();
  }

  DateRange _getDateRangeForPeriod(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.thisWeek:
        return repository.getThisWeekRange();
      case ReportPeriod.thisMonth:
        return repository.getCurrentMonthRange();
      case ReportPeriod.lastMonth:
        return repository.getLastMonthRange();
    }
  }
}
