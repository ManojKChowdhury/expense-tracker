import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/budget_provider.dart';
import 'package:expense_tracker_flutter/screens/budget/widgets/add_budget_sheet.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';
import 'package:expense_tracker_flutter/widgets/category_icon.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_flutter/providers/settings_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budget Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = context.watch<SettingsProvider>();
          final formatCurrency = NumberFormat.currency(symbol: settings.currency);
          final totalBudget = provider.totalBudget;
          final totalSpent = provider.totalSpent;
          final remaining = totalBudget - totalSpent;
          final percentage = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

          return RefreshIndicator(
            onRefresh: () => provider.loadBudgetData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Top Summary Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E1A47), Color(0xFF1B2845)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly Budget',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(
                              DateTime(provider.currentYear, provider.currentMonth),
                            ),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: percentage > 0.9 ? AppColors.coralAccent : AppColors.mintLight,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                settings.hideBalances ? '****' : formatCurrency.format(totalSpent),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'SPENT',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(percentage * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.mintLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              Text(
                                settings.hideBalances ? '****' : formatCurrency.format(remaining > 0 ? remaining : 0),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.mintLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Goal',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              Text(
                                settings.hideBalances ? '****' : formatCurrency.format(totalBudget),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category Breakdowns
                Text(
                  'Category Budgets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                if (provider.budgetProgresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No budgets set yet.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...provider.budgetProgresses.map((bp) {
                    final catPercentage = bp.percentage.clamp(0.0, 1.0);
                    final isOver = bp.spent > bp.budget.amount;
                    final progressColor = isOver 
                        ? AppColors.coralAccent 
                        : AppColors.getCategoryColor(bp.budget.category);
                        
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: progressColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(CategoryIcon.getIcon(bp.budget.category), color: progressColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    bp.budget.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(bp.percentage * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: catPercentage,
                                minHeight: 8,
                                backgroundColor: progressColor.withOpacity(0.2),
                                color: progressColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  settings.hideBalances ? 'Spent: ****' : '${formatCurrency.format(bp.spent)} Spent',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  settings.hideBalances ? 'Limit: ****' : 'Limit: ${formatCurrency.format(bp.budget.amount)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddBudgetSheet(),
          );
        },
        backgroundColor: AppColors.emeraldPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
