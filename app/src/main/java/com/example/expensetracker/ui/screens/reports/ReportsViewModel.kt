package com.example.expensetracker.ui.screens.reports

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.expensetracker.data.local.CategoryTotal
import com.example.expensetracker.data.local.DailyTotal
import com.example.expensetracker.data.repository.ExpenseRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.Calendar

data class ReportsUiState(
    val totalSpent: Double = 0.0,
    val categoryTotals: List<CategoryTotal> = emptyList(),
    val dailyTotals: List<DailyTotal> = emptyList(),
    val selectedPeriod: ReportPeriod = ReportPeriod.THIS_MONTH,
    val isLoading: Boolean = true
)

enum class ReportPeriod {
    THIS_WEEK,
    THIS_MONTH,
    LAST_MONTH
}

class ReportsViewModel(
    private val repository: ExpenseRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(ReportsUiState())
    val uiState: StateFlow<ReportsUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun selectPeriod(period: ReportPeriod) {
        _uiState.value = _uiState.value.copy(selectedPeriod = period, isLoading = true)
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            val (startDate, endDate) = getDateRangeForPeriod(_uiState.value.selectedPeriod)

            combine(
                repository.getCategoryTotals(startDate, endDate),
                repository.getDailyTotals(startDate, endDate)
            ) { categoryTotals, dailyTotals ->
                val totalSpent = repository.getTotalExpense(startDate, endDate)

                ReportsUiState(
                    totalSpent = totalSpent,
                    categoryTotals = categoryTotals,
                    dailyTotals = dailyTotals,
                    selectedPeriod = _uiState.value.selectedPeriod,
                    isLoading = false
                )
            }.collect { state ->
                _uiState.value = state
            }
        }
    }

    private fun getDateRangeForPeriod(period: ReportPeriod): Pair<Long, Long> {
        val calendar = Calendar.getInstance()
        
        return when (period) {
            ReportPeriod.THIS_WEEK -> {
                calendar.set(Calendar.DAY_OF_WEEK, calendar.firstDayOfWeek)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                calendar.set(Calendar.MILLISECOND, 0)
                val startOfWeek = calendar.timeInMillis

                calendar.add(Calendar.DAY_OF_WEEK, 6)
                calendar.set(Calendar.HOUR_OF_DAY, 23)
                calendar.set(Calendar.MINUTE, 59)
                calendar.set(Calendar.SECOND, 59)
                calendar.set(Calendar.MILLISECOND, 999)
                val endOfWeek = calendar.timeInMillis

                Pair(startOfWeek, endOfWeek)
            }
            ReportPeriod.THIS_MONTH -> {
                repository.getCurrentMonthRange()
            }
            ReportPeriod.LAST_MONTH -> {
                calendar.add(Calendar.MONTH, -1)
                calendar.set(Calendar.DAY_OF_MONTH, 1)
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                calendar.set(Calendar.MILLISECOND, 0)
                val startOfLastMonth = calendar.timeInMillis

                calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
                calendar.set(Calendar.HOUR_OF_DAY, 23)
                calendar.set(Calendar.MINUTE, 59)
                calendar.set(Calendar.SECOND, 59)
                calendar.set(Calendar.MILLISECOND, 999)
                val endOfLastMonth = calendar.timeInMillis

                Pair(startOfLastMonth, endOfLastMonth)
            }
        }
    }
}
