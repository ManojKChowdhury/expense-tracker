import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expense_tracker_flutter/database/database_helper.dart';
import 'package:expense_tracker_flutter/models/transaction.dart' as models;
import 'package:expense_tracker_flutter/repositories/expense_repository.dart';

class DataManagementService {
  final DatabaseHelper _databaseHelper;
  final ExpenseRepository _expenseRepository;

  DataManagementService(this._databaseHelper, this._expenseRepository);

  Future<void> exportData() async {
    final transactions = await _expenseRepository.getAllTransactions();
    
    List<List<dynamic>> rows = [
      ['ID', 'Amount', 'Category', 'Type', 'PaymentMethod', 'Date', 'Notes']
    ];
    
    for (var t in transactions) {
      rows.add([
        t.id,
        t.amount,
        t.category,
        t.type == models.TransactionType.income ? 'INCOME' : 'EXPENSE',
        t.paymentMethod,
        t.date.millisecondsSinceEpoch,
        t.notes ?? '',
      ]);
    }

    String csvString = csv.encode(rows);
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expense_tracker_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    
    await file.writeAsString(csvString);
    
    // Share the file
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(path)], text: 'Expense Tracker Backup');
  }

  Future<bool> importData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final csvString = await file.readAsString();
        
        List<List<dynamic>> rowsAsListOfValues = csv.decode(csvString);
        
        if (rowsAsListOfValues.isEmpty) return false;
        
        // Skip header
        bool isFirstRow = true;
        for (var row in rowsAsListOfValues) {
          if (isFirstRow) {
            isFirstRow = false;
            continue;
          }
          
          if (row.length >= 6) {
            final transaction = models.Transaction(
              id: null, // Let DB generate ID
              amount: double.tryParse(row[1].toString()) ?? 0.0,
              category: row[2].toString(),
              type: row[3].toString() == 'INCOME' ? models.TransactionType.income : models.TransactionType.expense,
              paymentMethod: row[4].toString(),
              date: DateTime.fromMillisecondsSinceEpoch(int.tryParse(row[5].toString()) ?? DateTime.now().millisecondsSinceEpoch),
              notes: row.length > 6 ? row[6].toString() : '',
            );
            await _expenseRepository.insertTransaction(transaction);
          }
        }
        return true;
      }
    } catch (e) {
      // Ignore
    }
    return false;
  }

  Future<void> clearAllData() async {
    await _databaseHelper.clearAllData();
  }
}
