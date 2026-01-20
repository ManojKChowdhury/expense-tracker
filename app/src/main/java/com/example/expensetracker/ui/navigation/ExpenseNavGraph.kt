package com.example.expensetracker.ui.navigation

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.expensetracker.data.local.AppDatabase
import com.example.expensetracker.data.repository.ExpenseRepository
import com.example.expensetracker.ui.screens.add_expense.AddExpenseScreen
import com.example.expensetracker.ui.screens.add_expense.AddExpenseViewModel
import com.example.expensetracker.ui.screens.home.HomeScreen
import com.example.expensetracker.ui.screens.home.HomeViewModel
import com.example.expensetracker.ui.screens.reports.ReportsScreen
import com.example.expensetracker.ui.screens.reports.ReportsViewModel

data class BottomNavItem(
    val route: String,
    val icon: ImageVector,
    val label: String
)

@Composable
fun ExpenseNavGraph(
    database: AppDatabase
) {
    val navController = rememberNavController()
    val repository = ExpenseRepository(
        transactionDao = database.transactionDao(),
        budgetDao = database.budgetDao()
    )

    val bottomNavItems = listOf(
        BottomNavItem(Screen.Home.route, Icons.Default.Home, "Home"),
        BottomNavItem(Screen.Reports.route, Icons.Default.BarChart, "Reports"),
        BottomNavItem(Screen.Budget.route, Icons.Default.AccountBalanceWallet, "Budget")
    )

    Scaffold(
        bottomBar = {
            val navBackStackEntry by navController.currentBackStackEntryAsState()
            val currentDestination = navBackStackEntry?.destination

            // Only show bottom bar on main screens
            if (currentDestination?.route in bottomNavItems.map { it.route }) {
                NavigationBar {
                    bottomNavItems.forEach { item ->
                        NavigationBarItem(
                            icon = { Icon(item.icon, contentDescription = item.label) },
                            label = { Text(item.label) },
                            selected = currentDestination?.hierarchy?.any { it.route == item.route } == true,
                            onClick = {
                                navController.navigate(item.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) {
                val viewModel = HomeViewModel(repository)
                HomeScreen(
                    viewModel = viewModel,
                    onAddExpenseClick = {
                        navController.navigate(Screen.AddExpense.route)
                    }
                )
            }

            composable(Screen.AddExpense.route) {
                val viewModel = AddExpenseViewModel(repository)
                AddExpenseScreen(
                    viewModel = viewModel,
                    onNavigateBack = {
                        navController.popBackStack()
                    }
                )
            }

            composable(Screen.Reports.route) {
                val viewModel = ReportsViewModel(repository)
                ReportsScreen(viewModel = viewModel)
            }

            composable(Screen.Budget.route) {
                // Placeholder for budget screen
                BudgetPlaceholderScreen()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BudgetPlaceholderScreen() {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Budget Management") }
            )
        }
    ) { paddingValues ->
        androidx.compose.foundation.layout.Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentAlignment = androidx.compose.ui.Alignment.Center
        ) {
            Text("Budget Management - Coming Soon")
        }
    }
}
