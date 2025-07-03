import 'package:flutter/material.dart';
import '../models/custom_category.dart';
import '../services/database_service.dart';

class CustomCategoryEditorScreen extends StatefulWidget {
  final CustomCategory? category;
  final CategoryType categoryType;
  final List<CustomCategory> existingCategories;

  const CustomCategoryEditorScreen({
    super.key,
    this.category,
    required this.categoryType,
    required this.existingCategories,
  });

  @override
  State<CustomCategoryEditorScreen> createState() => _CustomCategoryEditorScreenState();
}

class _CustomCategoryEditorScreenState extends State<CustomCategoryEditorScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  Color _selectedColor = CategoryColors.predefinedColors.first;
  IconData _selectedIcon = CategoryIcons.predefinedIcons.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedColor = widget.category!.color;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    // 名前の重複チェック
    final name = _nameController.text.trim();
    final isDuplicate = widget.existingCategories.any((cat) =>
        cat.name.toLowerCase() == name.toLowerCase() &&
        cat.id != widget.category?.id);

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('同じ名前のカテゴリが既に存在します')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      
      if (widget.category == null) {
        // 新規作成
        final newCategory = CustomCategory(
          name: name,
          type: widget.categoryType,
          colorValue: _selectedColor.toARGB32(),
          iconCodePoint: _selectedIcon.codePoint,
          iconFontFamily: 'MaterialIcons',
          sortOrder: widget.existingCategories.length,
          isDefault: false,
          createdAt: now,
        );
        
        await _databaseService.insertCustomCategory(newCategory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「$name」を作成しました')),
          );
          Navigator.pop(context, newCategory);
        }
      } else {
        // 更新
        final updatedCategory = widget.category!.copyWith(
          name: name,
          colorValue: _selectedColor.toARGB32(),
          iconCodePoint: _selectedIcon.codePoint,
          updatedAt: now,
        );
        
        await _databaseService.updateCustomCategory(updatedCategory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「$name」を更新しました')),
          );
          Navigator.pop(context, updatedCategory);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('色を選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: CategoryColors.predefinedColors.length,
            itemBuilder: (context, index) {
              final color = CategoryColors.predefinedColors[index];
              final isSelected = color.toARGB32() == _selectedColor.toARGB32();
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アイコンを選択'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: DefaultTabController(
            length: CategoryIcons.categorizedIcons.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: CategoryIcons.categorizedIcons.keys
                      .map((category) => Tab(text: category))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: CategoryIcons.categorizedIcons.entries
                        .map((entry) => _buildIconGrid(entry.value))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid(List<IconData> icons) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = icon.codePoint == _selectedIcon.codePoint;
        
        return GestureDetector(
          onTap: () {
            setState(() => _selectedIcon = icon);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: _selectedColor, width: 2)
                  : Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              icon,
              color: isSelected ? _selectedColor : Colors.grey[600],
              size: 24,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final title = isEditing ? 'カテゴリを編集' : '新しいカテゴリを作成';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveCategory,
              child: Text(
                isEditing ? '更新' : '作成',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // プレビュー
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _selectedIcon,
                          color: _selectedColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty 
                                  ? 'カテゴリ名' 
                                  : _nameController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.categoryType.displayName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // カテゴリ名入力
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'カテゴリ名を入力してください';
                  }
                  if (value.trim().length > 20) {
                    return 'カテゴリ名は20文字以内で入力してください';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              
              const SizedBox(height: 24),
              
              // 色選択
              Text(
                '色',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _selectedColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'タップして色を変更',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // アイコン選択
              Text(
                'アイコン',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIcon,
                        color: _selectedColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'タップしてアイコンを変更',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? '更新' : '作成',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
