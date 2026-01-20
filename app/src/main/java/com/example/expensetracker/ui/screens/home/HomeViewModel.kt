package com.example.expensetracker.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.expensetracker.data.local.Transaction
import com.example.expensetracker.data.repository.ExpenseRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.Calendar

data class HomeUiState(
    val monthlyBudget: Double = 0.0,
    val totalSpent: Double = 0.0,
    val todaySpent: Double = 0.0,
    val totalIncome: Double = 0.0,
    val recentTransactions: List<Transaction> = emptyList(),
    val isLoading: Boolean = true
)

class HomeViewModel(
    private val repository: ExpenseRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            val (monthStart, monthEnd) = repository.getCurrentMonthRange()
            val (todayStart, todayEnd) = repository.getTodayRange()
            
            val calendar = Calendar.getInstance()
            val currentMonth = calendar.get(Calendar.MONTH) + 1
            val currentYear = calendar.get(Calendar.YEAR)

            // Combine flows
            combine(
                repository.getBudget("OVERALL", currentMonth, currentYear),
                repository.getRecentTransactions(10)
            ) { budget, transactions ->
                val totalSpent = repository.getTotalExpense(monthStart, monthEnd)
                val todaySpent = repository.getTotalExpense(todayStart, todayEnd)
                val totalIncome = repository.getTotalIncome(monthStart, monthEnd)

                HomeUiState(
                    monthlyBudget = budget?.amount ?: 0.0,
                    totalSpent = totalSpent,
                    todaySpent = todaySpent,
                    totalIncome = totalIncome,
                    recentTransactions = transactions,
                    isLoading = false
                )
            }.collect { state ->
                _uiState.value = state
            }
        }
    }

    fun refreshData() {
        loadData()
    }
}
