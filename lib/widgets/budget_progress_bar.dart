import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/settings_provider.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double budget;

  const BudgetProgressBar({
    Key? key,
    required this.spent,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budget;

    final settings = context.watch<SettingsProvider>();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.slatePale,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget
                  ? Theme.of(context).colorScheme.error
                  : AppColors.emeraldPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              settings.hideBalances
                  ? 'Spent: ****'
                  : 'Spent: ${settings.currency}${spent.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              settings.hideBalances
                  ? 'Budget: ****'
                  : 'Budget: ${settings.currency}${budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
