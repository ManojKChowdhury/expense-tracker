package com.example.expensetracker

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.expensetracker.data.local.AppDatabase
import com.example.expensetracker.ui.navigation.ExpenseNavGraph
import com.example.expensetracker.ui.theme.ExpenseTrackerTheme

class MainActivity : ComponentActivity() {
    private lateinit var database: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        database = AppDatabase.getDatabase(applicationContext)
        
        setContent {
            ExpenseTrackerTheme {
                ExpenseNavGraph(database = database)
            }
        }
    }
}
