package com.example.expensetracker.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "transactions")
data class Transaction(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val amount: Double,
    val category: String,
    val type: TransactionType, // INCOME or EXPENSE
    val paymentMethod: String,
    val date: Long, // Timestamp in milliseconds
    val notes: String = "",
    val receiptPhotoUri: String? = null
)

enum class TransactionType {
    INCOME,
    EXPENSE
}
