import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_flutter/main.dart';
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';
import 'package:expense_tracker_flutter/database/database_helper.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize repository with a database helper for the test
    final databaseHelper = DatabaseHelper();
    final repository = ExpenseRepository(databaseHelper);

    // Build our app and trigger a frame.
    // We pass the required repository parameter.
    await tester.pumpWidget(MyApp(repository: repository));

    // Verify that our app starts and builds a MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
