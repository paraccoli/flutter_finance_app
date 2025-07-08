import 'package:flutter/material.dart';
import '../models/custom_category.dart';
import '../services/database_service.dart';
import 'custom_category_editor_screen.dart';

class CustomCategoryManagerScreen extends StatefulWidget {
  const CustomCategoryManagerScreen({super.key});

  @override
  State<CustomCategoryManagerScreen> createState() => _CustomCategoryManagerScreenState();
}

class _CustomCategoryManagerScreenState extends State<CustomCategoryManagerScreen>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;
  
  List<CustomCategory> _expenseCategories = [];
  List<CustomCategory> _incomeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    
    try {
      final expenseCategories = await _databaseService.getCustomCategoriesByType(CategoryType.expense);
      final incomeCategories = await _databaseService.getCustomCategoriesByType(CategoryType.income);
      
      setState(() {
        _expenseCategories = expenseCategories;
        _incomeCategories = incomeCategories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('カテゴリの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _createCategory(CategoryType type) async {
    final result = await Navigator.push<CustomCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCategoryEditorScreen(
          categoryType: type,
          existingCategories: type == CategoryType.expense 
              ? _expenseCategories 
              : _incomeCategories,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadCategories();
    }
  }

  Future<void> _editCategory(CustomCategory category) async {
    final result = await Navigator.push<CustomCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCategoryEditorScreen(
          category: category,
          categoryType: category.type,
          existingCategories: category.type == CategoryType.expense 
              ? _expenseCategories 
              : _incomeCategories,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadCategories();
    }
  }

  Future<void> _deleteCategory(CustomCategory category) async {
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('デフォルトカテゴリは削除できません')),
      );
      return;
    }

    // 使用状況をチェック
    String warningMessage = '「${category.name}」を削除しますか？\n\n';
    warningMessage += '⚠️ 注意: このカテゴリを使用している支出/収入データがある場合、\n';
    warningMessage += 'それらのデータは「削除されたカテゴリ」として表示されるようになります。';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリを削除'),
        content: Text(warningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deleteCustomCategory(category.id!);
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('「${category.name}」を削除しました\n関連するデータの整合性も保たれています'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _reorderCategories(List<CustomCategory> categories, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
    
    try {
      await _databaseService.updateCategorySortOrder(categories);
      await _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('並び順の更新に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カテゴリ管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.money_off),
              text: '支出',
            ),
            Tab(
              icon: Icon(Icons.attach_money),
              text: '収入',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(_expenseCategories, CategoryType.expense),
                _buildCategoryList(_incomeCategories, CategoryType.income),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCategory(
          _tabController.index == 0 ? CategoryType.expense : CategoryType.income,
        ),
        label: const Text('新規作成'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<CustomCategory> categories, CategoryType type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == CategoryType.expense ? Icons.money_off : Icons.attach_money,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '${type.displayName}カテゴリがありません',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '「新規作成」ボタンでカテゴリを追加できます',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) => _reorderCategories(categories, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          key: ValueKey(category.id),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: category.isDefault 
                ? const Text(
                    'デフォルトカテゴリ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editCategory(category),
                  tooltip: '編集',
                ),
                if (!category.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(category),
                    tooltip: '削除',
                  ),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
