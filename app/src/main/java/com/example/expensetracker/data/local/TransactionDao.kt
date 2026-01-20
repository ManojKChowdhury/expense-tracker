package com.example.expensetracker.data.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface TransactionDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTransaction(transaction: Transaction): Long

    @Update
    suspend fun updateTransaction(transaction: Transaction)

    @Delete
    suspend fun deleteTransaction(transaction: Transaction)

    @Query("SELECT * FROM transactions ORDER BY date DESC")
    fun getAllTransactions(): Flow<List<Transaction>>

    @Query("SELECT * FROM transactions ORDER BY date DESC LIMIT :limit")
    fun getRecentTransactions(limit: Int): Flow<List<Transaction>>

    @Query("SELECT * FROM transactions WHERE date >= :startDate AND date <= :endDate ORDER BY date DESC")
    fun getTransactionsByDateRange(startDate: Long, endDate: Long): Flow<List<Transaction>>

    @Query("SELECT * FROM transactions WHERE category = :category AND date >= :startDate AND date <= :endDate")
    fun getTransactionsByCategory(category: String, startDate: Long, endDate: Long): Flow<List<Transaction>>

    @Query("SELECT SUM(amount) FROM transactions WHERE type = :type AND date >= :startDate AND date <= :endDate")
    suspend fun getTotalByType(type: TransactionType, startDate: Long, endDate: Long): Double?

    @Query("SELECT category, SUM(amount) as total FROM transactions WHERE type = 'EXPENSE' AND date >= :startDate AND date <= :endDate GROUP BY category ORDER BY total DESC")
    fun getCategoryTotals(startDate: Long, endDate: Long): Flow<List<CategoryTotal>>

    @Query("SELECT date, SUM(amount) as total FROM transactions WHERE type = 'EXPENSE' AND date >= :startDate AND date <= :endDate GROUP BY date ORDER BY date ASC")
    fun getDailyTotals(startDate: Long, endDate: Long): Flow<List<DailyTotal>>
}

data class CategoryTotal(
    val category: String,
    val total: Double
)

data class DailyTotal(
    val date: Long,
    val total: Double
)
