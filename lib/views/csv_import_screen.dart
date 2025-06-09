import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/csv_import_service.dart';
import '../viewmodels/expense_viewmodel.dart';

/// CSVインポート画面
class CSVImportScreen extends StatefulWidget {
  const CSVImportScreen({super.key});

  @override
  State<CSVImportScreen> createState() => _CSVImportScreenState();
}

class _CSVImportScreenState extends State<CSVImportScreen> {
  final CSVImportService _csvImportService = CSVImportService();
  CSVImportResult? _importResult;
  CSVFormat? _selectedFormat;
  bool _isLoading = false;
  String? _errorMessage;
  List<Expense>? _convertedExpenses;
  List<Expense>? _duplicateExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV インポート'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFileSelectionSection(),
                const SizedBox(height: 16),
                if (_importResult != null) ...[
                  _buildFormatSelectionSection(),
                  const SizedBox(height: 16),
                  _buildPreviewSection(),
                  const SizedBox(height: 16),
                  _buildImportButtonSection(),
                ],
                if (_errorMessage != null) _buildErrorSection(),
                const SizedBox(height: 50), // 余白を追加
              ],
            ),
          ),
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
              '📁 CSVファイルを選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'クレジットカード会社から提供されるCSVファイルを選択してください。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _selectCSVFile,
              icon: const Icon(Icons.file_upload),
              label: Text(_importResult == null ? 'ファイルを選択' : 'ファイルを再選択'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            if (_importResult != null) ...[
              const SizedBox(height: 8),
              Text(
                '選択ファイル: ${_importResult!.file.path.split('/').last}',
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

  /// フォーマット選択セクション
  Widget _buildFormatSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ CSVフォーマット',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_importResult!.detectedFormat != null) ...[
              Text(
                '自動検出: ${_importResult!.detectedFormat!.name}',
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 8),
            ],
            DropdownButtonFormField<CSVFormat>(
              value: _selectedFormat ?? _importResult!.detectedFormat,
              decoration: const InputDecoration(
                labelText: 'フォーマットを選択',
                border: OutlineInputBorder(),
              ),
              items: CSVImportService.supportedFormats.values.map((format) {
                return DropdownMenuItem<CSVFormat>(
                  value: format,
                  child: Text(format.name),
                );
              }).toList(),
              onChanged: (CSVFormat? newFormat) {
                setState(() {
                  _selectedFormat = newFormat;
                  _convertedExpenses = null;
                  _duplicateExpenses = null;
                  _errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// プレビューセクション
  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 データプレビュー',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '最初の10行をプレビュー表示',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _importResult!.previewData.isEmpty
                  ? const Center(
                      child: Text(
                        'プレビューデータがありません',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _importResult!.previewData.length,
                      itemBuilder: (context, index) {
                        final row = _importResult!.previewData[index];
                        return _buildPreviewRow(row, index + 1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// プレビュー行を構築
  Widget _buildPreviewRow(CSVPreviewRow row, int rowNumber) {
    final hasValidData = row.parsedDate != null && 
                        row.parsedAmount != null && 
                        row.parsedDescription != null;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: hasValidData ? null : Colors.red.shade50,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: hasValidData ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '$rowNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (row.parsedDate != null && row.parsedAmount != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${row.parsedDate!.year}/${row.parsedDate!.month.toString().padLeft(2, '0')}/${row.parsedDate!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.payments,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '¥${row.parsedAmount!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                row.parsedDescription ?? '',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (row.suggestedCategory != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: row.suggestedCategory!.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      row.suggestedCategory!.icon,
                                      size: 12,
                                      color: row.suggestedCategory!.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      row.suggestedCategory!.displayName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: row.suggestedCategory!.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'データを解析できませんでした',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          'Raw: ${row.rawData.join(', ')}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ インポート実行',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_duplicateExpenses != null && _duplicateExpenses!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_duplicateExpenses!.length}件の重複データが検出されました',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _selectedFormat == null ? null : _convertAndCheckDuplicates,
                    icon: const Icon(Icons.preview),
                    label: const Text('重複チェック'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _convertedExpenses == null ? null : _importData,
                    icon: const Icon(Icons.upload),
                    label: const Text('インポート'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_convertedExpenses != null) ...[
              const SizedBox(height: 8),
              Text(
                'インポート対象: ${_convertedExpenses!.length}件',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
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
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CSVファイルを選択
  Future<void> _selectCSVFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _csvImportService.selectAndImportCSV();
      
      setState(() {
        _importResult = result;
        _selectedFormat = result?.detectedFormat;
        _convertedExpenses = null;
        _duplicateExpenses = null;
      });
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

  /// データを変換して重複チェック
  Future<void> _convertAndCheckDuplicates() async {
    if (_importResult == null || _selectedFormat == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });    try {
      // データを変換
      final expenses = await _csvImportService.convertToExpenses(_importResult!, _selectedFormat!);
      
      // 重複チェック（非同期処理前にcontextを取得）
      final messenger = ScaffoldMessenger.of(context);
      final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
      
      final existingExpenses = expenseViewModel.expenses;
      final duplicates = await _csvImportService.checkDuplicates(expenses, existingExpenses);
        setState(() {
        _convertedExpenses = expenses;
        _duplicateExpenses = duplicates;
      });      if (duplicates.isNotEmpty && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('${duplicates.length}件の重複データが検出されました'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('重複データはありませんでした'),
            backgroundColor: Colors.green,
          ),
        );
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

  /// データをインポート
  Future<void> _importData() async {
    if (_convertedExpenses == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });    try {
      final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
      
      // 重複データを除外
      final uniqueExpenses = _convertedExpenses!.where((expense) {
        return _duplicateExpenses?.any((dup) => 
          dup.date == expense.date && 
          dup.amount == expense.amount && 
          dup.note == expense.note) != true;
      }).toList();

      debugPrint('CSV Import: インポート対象データ数 = ${uniqueExpenses.length}');
        // 一括でデータを保存
      if (uniqueExpenses.isNotEmpty) {
        try {
          await expenseViewModel.addExpensesBatch(uniqueExpenses);
          debugPrint('CSV Import: 一括保存成功');
          
          // インポートしたデータの日付範囲に表示範囲を更新
          final dates = uniqueExpenses.map((e) => e.date).toList();
          dates.sort();
          final earliestDate = dates.first;
          final latestDate = dates.last;
          
          debugPrint('CSV Import: 日付範囲を更新 - $earliestDate から $latestDate');
          expenseViewModel.setDateRange(earliestDate, latestDate);
          
          // 完了メッセージ
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${uniqueExpenses.length}件のデータをインポートしました'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pop(context, uniqueExpenses.length);
          }
        } catch (e) {
          debugPrint('CSV Import: 一括保存エラー = $e');
          setState(() {
            _errorMessage = 'データの保存に失敗しました: $e';
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('インポートするデータがありません'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
}
