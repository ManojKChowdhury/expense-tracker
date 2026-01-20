package com.example.expensetracker.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "budgets")
data class Budget(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val category: String, // "OVERALL" for monthly budget, or specific category name
    val amount: Double,
    val month: Int, // 1-12
    val year: Int
)
