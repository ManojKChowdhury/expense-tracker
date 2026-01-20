package com.example.expensetracker.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface BudgetDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBudget(budget: Budget): Long

    @Update
    suspend fun updateBudget(budget: Budget)

    @Query("SELECT * FROM budgets WHERE category = :category AND month = :month AND year = :year LIMIT 1")
    fun getBudget(category: String, month: Int, year: Int): Flow<Budget?>

    @Query("SELECT * FROM budgets WHERE month = :month AND year = :year")
    fun getAllBudgetsForMonth(month: Int, year: Int): Flow<List<Budget>>

    @Query("DELETE FROM budgets WHERE category = :category AND month = :month AND year = :year")
    suspend fun deleteBudget(category: String, month: Int, year: Int)
}
