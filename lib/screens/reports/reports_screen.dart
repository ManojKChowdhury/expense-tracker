import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/reports_provider.dart';
import 'package:expense_tracker_flutter/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, child) {
          final uiState = provider.uiState;

          if (uiState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Period Selector
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('This Week'),
                    selected: uiState.selectedPeriod == ReportPeriod.thisWeek,
                    onSelected: (selected) {
                      if (selected) provider.selectPeriod(ReportPeriod.thisWeek);
                    },
                  ),
                  FilterChip(
                    label: const Text('This Month'),
                    selected: uiState.selectedPeriod == ReportPeriod.thisMonth,
                    onSelected: (selected) {
                      if (selected) provider.selectPeriod(ReportPeriod.thisMonth);
                    },
                  ),
                  FilterChip(
                    label: const Text('Last Month'),
                    selected: uiState.selectedPeriod == ReportPeriod.lastMonth,
                    onSelected: (selected) {
                      if (selected) provider.selectPeriod(ReportPeriod.lastMonth);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Spending Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Total Spending',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.slateLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${uiState.totalSpent.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.coralAccent,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Breakdown
              Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              if (uiState.categoryTotals.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No expenses in this period',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.slateLight,
                            ),
                      ),
                    ),
                  ),
                )
              else
                ...uiState.categoryTotals.map((categoryTotal) {
                  final percentage = uiState.totalSpent > 0
                      ? (categoryTotal.total / uiState.totalSpent * 100)
                      : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.getCategoryColor(categoryTotal.category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryTotal.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.slateLight,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${categoryTotal.total.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coralAccent,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              // Daily Spending Chart
              if (uiState.dailyTotals.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Daily Spending Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: uiState.dailyTotals
                                  .map((e) => e.total)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < uiState.dailyTotals.length) {
                                    return Text(
                                      '${uiState.dailyTotals[value.toInt()].date.day}',
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: uiState.dailyTotals
                              .asMap()
                              .entries
                              .map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.total,
                                  color: AppColors.emeraldPrimary,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
