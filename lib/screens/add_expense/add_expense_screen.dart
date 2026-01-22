import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/add_expense_provider.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/widgets/category_icon.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AddExpenseProvider>(
        builder: (context, provider, child) {
          final uiState = provider.uiState;

          final expenseCategories = [
            'Food',
            'Transport',
            'Shopping',
            'Entertainment',
            'Bills',
            'Health',
            'Education',
            'Others'
          ];
          final incomeCategories = [
            'Salary',
            'Freelance',
            'Investment',
            'Gift',
            'Others'
          ];
          final paymentMethods = [
            'Cash',
            'Credit Card',
            'Debit Card',
            'UPI',
            'Bank Transfer'
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => provider.selectType(TransactionType.expense),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: uiState.selectedType == TransactionType.expense
                                  ? AppColors.coralAccent
                                  : AppColors.slatePale,
                              foregroundColor: uiState.selectedType == TransactionType.expense
                                  ? Colors.white
                                  : AppColors.slateDeep,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Expense'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => provider.selectType(TransactionType.income),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: uiState.selectedType == TransactionType.income
                                  ? AppColors.tealAccent
                                  : AppColors.slatePale,
                              foregroundColor: uiState.selectedType == TransactionType.income
                                  ? Colors.white
                                  : AppColors.slateDeep,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Income'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  onChanged: provider.updateAmount,
                ),
                const SizedBox(height: 20),

                // Category Selection
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: (uiState.selectedType == TransactionType.expense
                            ? expenseCategories
                            : incomeCategories)
                        .map((category) => CategoryIcon(
                              category: category,
                              isSelected: uiState.selectedCategory == category,
                              onTap: () => provider.selectCategory(category),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Date Picker
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: uiState.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      provider.selectDate(date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('MMM dd, yyyy').format(uiState.selectedDate)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: paymentMethods.take(3).map((method) {
                    return FilterChip(
                      label: Text(method),
                      selected: uiState.paymentMethod == method,
                      onSelected: (selected) {
                        if (selected) provider.selectPaymentMethod(method);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Notes
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: provider.updateNotes,
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: uiState.amount.isNotEmpty &&
                          uiState.selectedCategory.isNotEmpty &&
                          !uiState.isSaving
                      ? () async {
                          final success = await provider.saveTransaction();
                          if (success && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: uiState.isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Transaction',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
