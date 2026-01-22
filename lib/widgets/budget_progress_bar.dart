import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';

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
              'Spent: \$${spent.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Budget: \$${budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
