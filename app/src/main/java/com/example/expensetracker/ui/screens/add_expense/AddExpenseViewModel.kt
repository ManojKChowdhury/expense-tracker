package com.example.expensetracker.ui.screens.add_expense

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.expensetracker.data.local.Transaction
import com.example.expensetracker.data.local.TransactionType
import com.example.expensetracker.data.repository.ExpenseRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Calendar

data class AddExpenseUiState(
    val amount: String = "",
    val selectedCategory: String = "",
    val selectedType: TransactionType = TransactionType.EXPENSE,
    val selectedDate: Long = System.currentTimeMillis(),
    val paymentMethod: String = "Cash",
    val notes: String = "",
    val receiptPhotoUri: String? = null,
    val isSaving: Boolean = false
)

class AddExpenseViewModel(
    private val repository: ExpenseRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(AddExpenseUiState())
    val uiState: StateFlow<AddExpenseUiState> = _uiState.asStateFlow()

    fun updateAmount(amount: String) {
        _uiState.value = _uiState.value.copy(amount = amount)
    }

    fun selectCategory(category: String) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
    }

    fun selectType(type: TransactionType) {
        _uiState.value = _uiState.value.copy(
            selectedType = type,
            selectedCategory = "" // Reset category when type changes
        )
    }

    fun selectDate(date: Long) {
        _uiState.value = _uiState.value.copy(selectedDate = date)
    }

    fun selectPaymentMethod(method: String) {
        _uiState.value = _uiState.value.copy(paymentMethod = method)
    }

    fun updateNotes(notes: String) {
        _uiState.value = _uiState.value.copy(notes = notes)
    }

    fun updateReceiptPhoto(uri: String?) {
        _uiState.value = _uiState.value.copy(receiptPhotoUri = uri)
    }

    fun saveTransaction(onSuccess: () -> Unit) {
        val state = _uiState.value
        
        if (state.amount.isEmpty() || state.selectedCategory.isEmpty()) {
            return
        }

        viewModelScope.launch {
            _uiState.value = state.copy(isSaving = true)
            
            try {
                val amount = state.amount.toDoubleOrNull() ?: 0.0
                val transaction = Transaction(
                    amount = amount,
                    category = state.selectedCategory,
                    type = state.selectedType,
                    paymentMethod = state.paymentMethod,
                    date = state.selectedDate,
                    notes = state.notes,
                    receiptPhotoUri = state.receiptPhotoUri
                )
                
                repository.insertTransaction(transaction)
                onSuccess()
            } catch (e: Exception) {
                // Handle error
                _uiState.value = state.copy(isSaving = false)
            }
        }
    }

    fun resetState() {
        _uiState.value = AddExpenseUiState()
    }
}
