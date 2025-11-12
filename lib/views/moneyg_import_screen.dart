import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/csv_import_service.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';

/// MoneyGデータインポート画面
class MoneyGImportScreen extends StatefulWidget {
  const MoneyGImportScreen({super.key});

  @override
  State<MoneyGImportScreen> createState() => _MoneyGImportScreenState();
}

class _MoneyGImportScreenState extends State<MoneyGImportScreen> {
  final CSVImportService _csvImportService = CSVImportService();
  CSVImportResult? _importResult;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  ImportDataType _selectedDataType = ImportDataType.expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyG データインポート'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoSection(),
                const SizedBox(height: 16),
                _buildFileSelectionSection(),
                const SizedBox(height: 16),
                if (_importResult != null) ...[
                  _buildFormatInfoSection(),
                  const SizedBox(height: 16),
                  _buildDataTypeSelectionSection(),
                  const SizedBox(height: 16),
                  _buildPreviewSection(),
                  const SizedBox(height: 16),
                  _buildImportButtonSection(),
                ],
                if (_errorMessage != null) _buildErrorSection(),
                if (_successMessage != null) _buildSuccessSection(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 情報セクション
  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'MoneyGデータインポートについて',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'MoneyG v1.2.2以前でエクスポートしたCSVファイルをインポートできます。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '対応形式:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('• 支出のみ (expenses_yyyymmdd_hhmmss.csv)', style: TextStyle(fontSize: 12)),
            const Text('• 収入のみ (incomes_yyyymmdd_hhmmss.csv)', style: TextStyle(fontSize: 12)),
            const Text('• 全データ (all_data_yyyymmdd_hhmmss.csv)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// ファイル選択セクション
  Widget _buildFileSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📁 MoneyG CSVファイルを選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'MoneyG v1.2.2以前でエクスポートしたCSVファイルを選択してください。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _selectCSVFile,
              icon: const Icon(Icons.file_upload),
              label: Text(_importResult == null ? 'ファイルを選択' : 'ファイルを再選択'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            if (_importResult != null) ...[
              const SizedBox(height: 8),
              Text(
                '選択ファイル: ${_importResult!.file.path.split('\\').last}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '総行数: ${_importResult!.totalRows}行',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// フォーマット情報セクション
  Widget _buildFormatInfoSection() {
    if (_importResult?.detectedFormat == null) return const SizedBox.shrink();

    final format = _importResult!.detectedFormat!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 検出されたフォーマット',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              format.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              'データタイプ: ${_getDataTypeDisplayName(format.dataType)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// データタイプ選択セクション
  Widget _buildDataTypeSelectionSection() {
    if (_importResult?.detectedFormat?.dataType != 'both') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 インポートするデータタイプ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '全データ形式が検出されました。どのデータをインポートしますか？',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...ImportDataType.values.map((type) => 
              // ignore: deprecated_member_use
              RadioListTile<ImportDataType>(
              title: Text(type.displayName),
              value: type,
              // ignore: deprecated_member_use
              groupValue: _selectedDataType,
              // ignore: deprecated_member_use
              onChanged: (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  /// プレビューセクション
  Widget _buildPreviewSection() {
    if (_importResult == null || _importResult!.previewData.isEmpty) {
      return const SizedBox.shrink();
    }

    final previewCount = _importResult!.previewData.length > 5 ? 5 : _importResult!.previewData.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👀 データプレビュー',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '最初の$previewCount行を表示しています',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('日付')),
                  DataColumn(label: Text('カテゴリ')),
                  DataColumn(label: Text('金額')),
                  DataColumn(label: Text('メモ')),
                ],
                rows: _importResult!.previewData
                    .take(previewCount)
                    .map((row) => DataRow(
                          cells: [
                            DataCell(Text(row.parsedDate?.toString().split(' ')[0] ?? '-')),
                            DataCell(Text(row.suggestedCategory?.toString().split('.').last ?? '-')),
                            DataCell(Text(row.parsedAmount?.toString() ?? '-')),
                            DataCell(Text(row.parsedDescription ?? '-')),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// インポートボタンセクション
  Widget _buildImportButtonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '⬇️ データをインポート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '選択したデータをデータベースに追加します。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _importData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isLoading ? 'インポート中...' : 'データをインポート'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// エラーセクション
  Widget _buildErrorSection() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'エラー',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  /// 成功セクション
  Widget _buildSuccessSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'インポート完了',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  /// CSVファイル選択
  Future<void> _selectCSVFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _csvImportService.selectAndImportCSV();
      if (result != null) {
        setState(() {
          _importResult = result;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// データインポート
  Future<void> _importData() async {
    if (_importResult == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final format = _importResult!.detectedFormat;
      
      if (format?.dataType == 'both') {
        // 全データ形式の場合
        switch (_selectedDataType) {
          case ImportDataType.expense:
            await _importExpenses();
            break;
          case ImportDataType.income:
            await _importIncomes();
            break;
          case ImportDataType.both:
            await _importBothData();
            break;
        }
      } else if (format?.dataType == 'expense') {
        // 支出のみ形式
        await _importExpenses();
      } else if (format?.dataType == 'income') {
        // 収入のみ形式
        await _importIncomes();
      } else {
        throw Exception('サポートされていないデータ形式です');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 支出データインポート
  Future<void> _importExpenses() async {
    if (!mounted) return;
    
    final expenses = await _csvImportService.convertToExpenses(_importResult!, _importResult!.detectedFormat);
    
    if (!mounted) return;
    final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
    
    for (final expense in expenses) {
      await expenseViewModel.addExpense(expense);
    }
    
    if (mounted) {
      setState(() {
        _successMessage = '${expenses.length}件の支出データをインポートしました';
      });
    }
  }

  /// 収入データインポート
  Future<void> _importIncomes() async {
    if (!mounted) return;
    
    final incomes = await _csvImportService.convertToIncomes(_importResult!);
    
    if (!mounted) return;
    final incomeViewModel = Provider.of<IncomeViewModel>(context, listen: false);
    
    for (final income in incomes) {
      await incomeViewModel.addIncome(income);
    }
    
    if (mounted) {
      setState(() {
        _successMessage = '${incomes.length}件の収入データをインポートしました';
      });
    }
  }

  /// 支出・収入両方のデータインポート
  Future<void> _importBothData() async {
    if (!mounted) return;
    
    final result = await _csvImportService.convertToAll(_importResult!);
    
    if (!mounted) return;
    final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
    final incomeViewModel = Provider.of<IncomeViewModel>(context, listen: false);
    
    for (final expense in result.expenses) {
      await expenseViewModel.addExpense(expense);
    }
    
    for (final income in result.incomes) {
      await incomeViewModel.addIncome(income);
    }
    
    if (mounted) {
      setState(() {
        _successMessage = '${result.expenses.length}件の支出、${result.incomes.length}件の収入データをインポートしました';
      });
    }
  }

  /// データタイプ表示名を取得
  String _getDataTypeDisplayName(String? dataType) {
    switch (dataType) {
      case 'expense':
        return '支出のみ';
      case 'income':
        return '収入のみ';
      case 'both':
        return '支出・収入両方';
      default:
        return '不明';
    }
  }
}
