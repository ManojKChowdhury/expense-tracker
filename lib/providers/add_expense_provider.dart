import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';

class AddExpenseUiState {
  final String amount;
  final String selectedCategory;
  final TransactionType selectedType;
  final DateTime selectedDate;
  final String paymentMethod;
  final String notes;
  final String? receiptPhotoUri;
  final bool isSaving;

  AddExpenseUiState({
    this.amount = '',
    this.selectedCategory = '',
    this.selectedType = TransactionType.expense,
    DateTime? selectedDate,
    this.paymentMethod = 'Cash',
    this.notes = '',
    this.receiptPhotoUri,
    this.isSaving = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AddExpenseUiState copyWith({
    String? amount,
    String? selectedCategory,
    TransactionType? selectedType,
    DateTime? selectedDate,
    String? paymentMethod,
    String? notes,
    String? receiptPhotoUri,
    bool? isSaving,
  }) {
    return AddExpenseUiState(
      amount: amount ?? this.amount,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
      selectedDate: selectedDate ?? this.selectedDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptPhotoUri: receiptPhotoUri ?? this.receiptPhotoUri,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddExpenseProvider extends ChangeNotifier {
  final ExpenseRepository repository;
  AddExpenseUiState _uiState = AddExpenseUiState();

  AddExpenseUiState get uiState => _uiState;

  AddExpenseProvider(this.repository);

  void updateAmount(String amount) {
    _uiState = _uiState.copyWith(amount: amount);
    notifyListeners();
  }

  void selectCategory(String category) {
    _uiState = _uiState.copyWith(selectedCategory: category);
    notifyListeners();
  }

  void selectType(TransactionType type) {
    _uiState = _uiState.copyWith(
      selectedType: type,
      selectedCategory: '', // Reset category when type changes
    );
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _uiState = _uiState.copyWith(selectedDate: date);
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _uiState = _uiState.copyWith(paymentMethod: method);
    notifyListeners();
  }

  void updateNotes(String notes) {
    _uiState = _uiState.copyWith(notes: notes);
    notifyListeners();
  }

  void updateReceiptPhoto(String? uri) {
    _uiState = _uiState.copyWith(receiptPhotoUri: uri);
    notifyListeners();
  }

  Future<bool> saveTransaction() async {
    if (_uiState.amount.isEmpty || _uiState.selectedCategory.isEmpty) {
      return false;
    }

    _uiState = _uiState.copyWith(isSaving: true);
    notifyListeners();

    try {
      final amount = double.tryParse(_uiState.amount) ?? 0.0;
      final transaction = Transaction(
        amount: amount,
        category: _uiState.selectedCategory,
        type: _uiState.selectedType,
        paymentMethod: _uiState.paymentMethod,
        date: _uiState.selectedDate,
        notes: _uiState.notes,
        receiptPhotoUri: _uiState.receiptPhotoUri,
      );

      await repository.insertTransaction(transaction);
      resetState();
      return true;
    } catch (e) {
      _uiState = _uiState.copyWith(isSaving: false);
      notifyListeners();
      return false;
    }
  }

  void resetState() {
    _uiState = AddExpenseUiState();
    notifyListeners();
  }
}
