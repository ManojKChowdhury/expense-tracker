package com.example.expensetracker.data.repository

import com.example.expensetracker.data.local.*
import kotlinx.coroutines.flow.Flow
import java.util.Calendar

class ExpenseRepository(
    private val transactionDao: TransactionDao,
    private val budgetDao: BudgetDao
) {
    // Transaction operations
    suspend fun insertTransaction(transaction: Transaction): Long {
        return transactionDao.insertTransaction(transaction)
    }

    suspend fun updateTransaction(transaction: Transaction) {
        transactionDao.updateTransaction(transaction)
    }

    suspend fun deleteTransaction(transaction: Transaction) {
        transactionDao.deleteTransaction(transaction)
    }

    fun getAllTransactions(): Flow<List<Transaction>> {
        return transactionDao.getAllTransactions()
    }

    fun getRecentTransactions(limit: Int = 10): Flow<List<Transaction>> {
        return transactionDao.getRecentTransactions(limit)
    }

    fun getTransactionsByDateRange(startDate: Long, endDate: Long): Flow<List<Transaction>> {
        return transactionDao.getTransactionsByDateRange(startDate, endDate)
    }

    suspend fun getTotalIncome(startDate: Long, endDate: Long): Double {
        return transactionDao.getTotalByType(TransactionType.INCOME, startDate, endDate) ?: 0.0
    }

    suspend fun getTotalExpense(startDate: Long, endDate: Long): Double {
        return transactionDao.getTotalByType(TransactionType.EXPENSE, startDate, endDate) ?: 0.0
    }

    fun getCategoryTotals(startDate: Long, endDate: Long): Flow<List<CategoryTotal>> {
        return transactionDao.getCategoryTotals(startDate, endDate)
    }

    fun getDailyTotals(startDate: Long, endDate: Long): Flow<List<DailyTotal>> {
        return transactionDao.getDailyTotals(startDate, endDate)
    }

    // Budget operations
    suspend fun setBudget(category: String, amount: Double, month: Int, year: Int) {
        val budget = Budget(category = category, amount = amount, month = month, year = year)
        budgetDao.insertBudget(budget)
    }

    fun getBudget(category: String, month: Int, year: Int): Flow<Budget?> {
        return budgetDao.getBudget(category, month, year)
    }

    fun getAllBudgetsForMonth(month: Int, year: Int): Flow<List<Budget>> {
        return budgetDao.getAllBudgetsForMonth(month, year)
    }

    // Helper functions
    fun getCurrentMonthRange(): Pair<Long, Long> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.DAY_OF_MONTH, 1)
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startOfMonth = calendar.timeInMillis

        calendar.set(Calendar.DAY_OF_MONTH, calendar.getActualMaximum(Calendar.DAY_OF_MONTH))
        calendar.set(Calendar.HOUR_OF_DAY, 23)
        calendar.set(Calendar.MINUTE, 59)
        calendar.set(Calendar.SECOND, 59)
        calendar.set(Calendar.MILLISECOND, 999)
        val endOfMonth = calendar.timeInMillis

        return Pair(startOfMonth, endOfMonth)
    }

    fun getTodayRange(): Pair<Long, Long> {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startOfDay = calendar.timeInMillis

        calendar.set(Calendar.HOUR_OF_DAY, 23)
        calendar.set(Calendar.MINUTE, 59)
        calendar.set(Calendar.SECOND, 59)
        calendar.set(Calendar.MILLISECOND, 999)
        val endOfDay = calendar.timeInMillis

        return Pair(startOfDay, endOfDay)
    }
}
