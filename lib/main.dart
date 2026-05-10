import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/home_provider.dart';
import 'package:expense_tracker_flutter/providers/add_expense_provider.dart';
import 'package:expense_tracker_flutter/providers/reports_provider.dart';
import 'package:expense_tracker_flutter/providers/budget_provider.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';
import 'package:expense_tracker_flutter/database/database_helper.dart';
import 'package:expense_tracker_flutter/screens/main_screen.dart';
import 'package:expense_tracker_flutter/theme/app_theme.dart';
import 'package:expense_tracker_flutter/providers/settings_provider.dart';
import 'package:expense_tracker_flutter/repositories/data_management_service.dart';
import 'package:expense_tracker_flutter/screens/app_lock_wrapper.dart';
import 'package:expense_tracker_flutter/repositories/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().init();
  
  // Initialize database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database;
  
  // Initialize repository
  final repository = ExpenseRepository(databaseHelper);
  
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ExpenseRepository repository;

  const MyApp({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ExpenseRepository>.value(
          value: repository,
        ),
        Provider<DataManagementService>(
          create: (_) => DataManagementService(DatabaseHelper(), repository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(repository)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddExpenseProvider(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportsProvider(repository)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(repository)..loadBudgetData(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const AppLockWrapper(child: MainScreen()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
