import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currency';
  static const String _themeModeKey = 'theme_mode';
  static const String _firstDayOfWeekKey = 'first_day_of_week';
  static const String _hideBalancesKey = 'hide_balances';
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _categoriesKey = 'categories';

  String _currency = '\$';
  ThemeMode _themeMode = ThemeMode.system;
  int _firstDayOfWeek = 1; // 1 = Monday
  bool _hideBalances = false;
  bool _appLockEnabled = false;
  bool _dailyReminderEnabled = false;
  int _dailyReminderHour = 20; // 8 PM default
  int _dailyReminderMinute = 0;
  List<String> _categories = [
    'Housing', 'Food', 'Transportation', 'Utilities', 
    'Insurance', 'Healthcare', 'Savings & Debt', 'Personal', 'Entertainment', 'Other'
  ];

  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  int get firstDayOfWeek => _firstDayOfWeek;
  bool get hideBalances => _hideBalances;
  bool get appLockEnabled => _appLockEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  int get dailyReminderHour => _dailyReminderHour;
  int get dailyReminderMinute => _dailyReminderMinute;
  List<String> get categories => _categories;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currency = prefs.getString(_currencyKey) ?? '\$';
    
    final themeIndex = prefs.getInt(_themeModeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    _firstDayOfWeek = prefs.getInt(_firstDayOfWeekKey) ?? 1;
    _hideBalances = prefs.getBool(_hideBalancesKey) ?? false;
    _appLockEnabled = prefs.getBool(_appLockEnabledKey) ?? false;
    _dailyReminderEnabled = prefs.getBool(_dailyReminderEnabledKey) ?? false;
    _dailyReminderHour = prefs.getInt(_dailyReminderHourKey) ?? 20;
    _dailyReminderMinute = prefs.getInt(_dailyReminderMinuteKey) ?? 0;
    
    final savedCategories = prefs.getStringList(_categoriesKey);
    if (savedCategories != null && savedCategories.isNotEmpty) {
      _categories = savedCategories;
    }

    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setFirstDayOfWeek(int day) async {
    _firstDayOfWeek = day;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_firstDayOfWeekKey, day);
    notifyListeners();
  }

  Future<void> setHideBalances(bool hide) async {
    _hideBalances = hide;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideBalancesKey, hide);
    notifyListeners();
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    _appLockEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    _dailyReminderHour = hour;
    _dailyReminderMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyReminderHourKey, hour);
    await prefs.setInt(_dailyReminderMinuteKey, minute);
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      _categories.add(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, _categories);
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    if (_categories.contains(category)) {
      _categories.remove(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, _categories);
      notifyListeners();
    }
  }
}
