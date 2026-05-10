import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_flutter/providers/settings_provider.dart';
import 'package:expense_tracker_flutter/repositories/data_management_service.dart';
import 'package:expense_tracker_flutter/providers/home_provider.dart';
import 'package:expense_tracker_flutter/providers/reports_provider.dart';
import 'package:expense_tracker_flutter/providers/budget_provider.dart';
import 'package:expense_tracker_flutter/repositories/notification_service.dart';
import 'package:expense_tracker_flutter/screens/settings/manage_categories_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'General'),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Currency'),
                trailing: Text(settings.currency, style: const TextStyle(fontSize: 16)),
                onTap: () => _showCurrencyPicker(context, settings),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                trailing: Text(_getThemeName(settings.themeMode)),
                onTap: () => _showThemePicker(context, settings),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('First Day of Week'),
                trailing: Text(settings.firstDayOfWeek == 1 ? 'Monday' : 'Sunday'),
                onTap: () => _showFirstDayPicker(context, settings),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.visibility_off),
                title: const Text('Hide Balances'),
                subtitle: const Text('Blur amounts on Home screen'),
                value: settings.hideBalances,
                onChanged: (value) => settings.setHideBalances(value),
              ),
              
              const Divider(),
              _buildSectionHeader(context, 'Customization'),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Manage Categories'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                  );
                },
              ),
              
              const Divider(),
              _buildSectionHeader(context, 'Notifications'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Daily Reminder'),
                subtitle: const Text('Remind me to log expenses'),
                value: settings.dailyReminderEnabled,
                onChanged: (value) {
                  settings.setDailyReminderEnabled(value);
                  if (value) {
                    NotificationService().scheduleDailyReminder(
                      settings.dailyReminderHour,
                      settings.dailyReminderMinute,
                    );
                  } else {
                    NotificationService().cancelAllReminders();
                  }
                },
              ),
              if (settings.dailyReminderEnabled)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder Time'),
                  trailing: Text(
                    TimeOfDay(hour: settings.dailyReminderHour, minute: settings.dailyReminderMinute).format(context),
                  ),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: settings.dailyReminderHour, minute: settings.dailyReminderMinute),
                    );
                    if (picked != null) {
                      settings.setDailyReminderTime(picked.hour, picked.minute);
                      NotificationService().scheduleDailyReminder(picked.hour, picked.minute);
                    }
                  },
                ),
              
              const Divider(),
              _buildSectionHeader(context, 'Security'),
              SwitchListTile(
                secondary: const Icon(Icons.lock),
                title: const Text('App Lock'),
                subtitle: const Text('Require authentication to open'),
                value: settings.appLockEnabled,
                onChanged: (value) => settings.setAppLockEnabled(value),
              ),
              
              const Divider(),
              _buildSectionHeader(context, 'Data & Backup'),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data (CSV)'),
                onTap: () async {
                  try {
                    await context.read<DataManagementService>().exportData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data exported successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Import Data (CSV)'),
                onTap: () async {
                  bool success = await context.read<DataManagementService>().importData();
                  if (context.mounted) {
                    if (success) {
                      context.read<HomeProvider>().refreshData();
                      context.read<ReportsProvider>().loadData();
                      context.read<BudgetProvider>().loadBudgetData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data imported successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Import failed or cancelled')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showClearDataConfirmation(context);
                },
              ),
              
              const Divider(),
              _buildSectionHeader(context, 'About'),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate the App'),
                onTap: () async {
                  final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.example.expense_tracker');
                  if (!await launchUrl(url)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch app store')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text('Send Feedback'),
                onTap: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@example.com',
                    queryParameters: {
                      'subject': 'Feedback for Expense Tracker'
                    },
                  );
                  if (!await launchUrl(emailLaunchUri)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open email client')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                trailing: Text(_appVersion),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    final currencies = ['\$', '€', '£', '₹', '¥'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: settings.currency,
              onChanged: (value) {
                if (value != null) {
                  settings.setCurrency(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeName(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFirstDayPicker(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('First Day of Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Monday'),
              value: 1,
              groupValue: settings.firstDayOfWeek,
              onChanged: (value) {
                if (value != null) {
                  settings.setFirstDayOfWeek(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('Sunday'),
              value: 7,
              groupValue: settings.firstDayOfWeek,
              onChanged: (value) {
                if (value != null) {
                  settings.setFirstDayOfWeek(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('Are you sure you want to delete all transactions and budgets? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<DataManagementService>().clearAllData();
              if (context.mounted) {
                context.read<HomeProvider>().refreshData();
                context.read<ReportsProvider>().loadData();
                context.read<BudgetProvider>().loadBudgetData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
