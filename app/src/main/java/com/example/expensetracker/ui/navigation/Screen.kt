package com.example.expensetracker.ui.navigation

sealed class Screen(val route: String) {
    object Home : Screen("home")
    object AddExpense : Screen("add_expense")
    object Reports : Screen("reports")
    object Budget : Screen("budget")
}
