import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../models/custom_theme_settings.dart';
import '../utils/app_theme.dart';
import 'custom_theme_creator_screen.dart';

/// カスタムテーマ管理画面
class CustomThemeManagerScreen extends StatelessWidget {
  const CustomThemeManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('カスタムテーマ管理'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomThemeCreatorScreen(),
                    ),
                  );
                },
                tooltip: '新しいテーマを作成',
              ),
            ],
          ),
          body: themeViewModel.customThemes.isEmpty
              ? _buildEmptyState()
              : _buildThemeList(themeViewModel),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'カスタムテーマがありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '右上の + ボタンから新しいテーマを作成できます',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeList(ThemeViewModel themeViewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: themeViewModel.customThemes.length,
      itemBuilder: (context, index) {
        final theme = themeViewModel.customThemes[index];
        final isCurrentTheme = themeViewModel.currentTheme == AppThemeType.custom &&
            themeViewModel.currentCustomTheme?.name == theme.name;

        return Card(
          elevation: isCurrentTheme ? 8 : 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: _buildThemePreview(theme),
            title: Text(
              theme.name,
              style: TextStyle(
                fontWeight: isCurrentTheme ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('作成日: ${_formatDate(theme.createdAt)}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildColorDot(theme.primaryColor),
                    const SizedBox(width: 4),
                    _buildColorDot(theme.secondaryColor),
                    const SizedBox(width: 4),
                    _buildColorDot(theme.accentColor),
                    const SizedBox(width: 8),
                    Text('フォント: ${theme.fontSize.toInt()}px'),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => _handleAction(context, action, theme, themeViewModel),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'apply',
                  child: Row(
                    children: [
                      Icon(
                        isCurrentTheme ? Icons.check_circle : Icons.check_circle_outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(isCurrentTheme ? '適用中' : '適用'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('編集'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 8),
                      Text('複製'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              themeViewModel.applyCustomTheme(theme);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${theme.name}を適用しました')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThemePreview(CustomThemeSettings theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
            theme.accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.palette,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _handleAction(
    BuildContext context,
    String action,
    CustomThemeSettings theme,
    ThemeViewModel themeViewModel,
  ) {
    switch (action) {
      case 'apply':
        themeViewModel.applyCustomTheme(theme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${theme.name}を適用しました')),
        );
        break;

      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomThemeCreatorScreen(existingTheme: theme),
          ),
        );
        break;

      case 'duplicate':
        final duplicatedTheme = theme.copyWith(
          name: '${theme.name} のコピー',
          createdAt: DateTime.now(),
        );
        themeViewModel.saveCustomTheme(duplicatedTheme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${theme.name}を複製しました')),
        );
        break;

      case 'delete':
        _showDeleteConfirmDialog(context, theme, themeViewModel);
        break;
    }
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    CustomThemeSettings theme,
    ThemeViewModel themeViewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テーマを削除'),
        content: Text('「${theme.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              themeViewModel.deleteCustomTheme(theme.name);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${theme.name}を削除しました')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
