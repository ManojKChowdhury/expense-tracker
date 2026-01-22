import 'package:flutter/material.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.getCategoryColor(transaction.category)
                      .withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: AppColors.getCategoryColor(transaction.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.slateLight,
                          ),
                    ),
                    if (transaction.notes.isNotEmpty)
                      Text(
                        transaction.notes,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.slateLight,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Amount
              Text(
                transaction.type == TransactionType.income
                    ? '+\$${transaction.amount.toStringAsFixed(2)}'
                    : '-\$${transaction.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.income
                          ? AppColors.tealAccent
                          : AppColors.coralAccent,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.account_balance;
      case 'freelance':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
