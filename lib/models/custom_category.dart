import 'package:flutter/material.dart';

/// カテゴリタイプを定義する列挙型
enum CategoryType {
  expense('支出'),
  income('収入');

  final String displayName;
  const CategoryType(this.displayName);

  @override
  String toString() => displayName;
}

/// カスタムカテゴリを表すモデルクラス
class CustomCategory {
  final int? id; // データベースのプライマリキー
  final String name; // カテゴリ名
  final CategoryType type; // カテゴリタイプ（支出/収入）
  final int colorValue; // カラーの値
  final int iconCodePoint; // アイコンのコードポイント
  final String iconFontFamily; // アイコンのフォントファミリー
  final int sortOrder; // 並び順
  final bool isDefault; // デフォルトカテゴリかどうか
  final DateTime createdAt; // 作成日時
  final DateTime? updatedAt; // 更新日時

  CustomCategory({
    this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.iconCodePoint,
    this.iconFontFamily = 'MaterialIcons',
    required this.sortOrder,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// カラーを取得するゲッター
  Color get color => Color(colorValue);

  /// アイコンを取得するゲッター
  IconData get icon {
    // データベースに保存されている codePoint を既定の定数アイコンリストと照合し、
    // 一致するものがあればその const IconData を返す。これによりツリーシェイクが効く。
    try {
      return CategoryIcons.predefinedIcons.firstWhere(
        (ic) => ic.codePoint == iconCodePoint && (ic.fontFamily ?? 'MaterialIcons') == iconFontFamily,
        orElse: () => Icons.category,
      );
    } catch (_) {
      return Icons.category;
    }
  }

  /// データベースから読み込むためのファクトリメソッド
  factory CustomCategory.fromMap(Map<String, dynamic> map) {
    return CustomCategory(
      id: map['id'],
      name: map['name'],
      type: CategoryType.values[map['type']],
      colorValue: map['colorValue'],
      iconCodePoint: map['iconCodePoint'],
      iconFontFamily: map['iconFontFamily'] ?? 'MaterialIcons',
      sortOrder: map['sortOrder'],
      isDefault: map['isDefault'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  /// データベースに保存するためのマップに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'sortOrder': sortOrder,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// オブジェクトのコピーを作成するメソッド
  CustomCategory copyWith({
    int? id,
    String? name,
    CategoryType? type,
    int? colorValue,
    int? iconCodePoint,
    String? iconFontFamily,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCategory &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}

/// 定義済みのカラーパレット
class CategoryColors {
  static const List<Color> predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Color(0xFF4CAF50), // グリーン
    Color(0xFF2196F3), // ブルー
    Color(0xFFF44336), // レッド
    Color(0xFFFF9800), // オレンジ
    Color(0xFF9C27B0), // パープル
    Color(0xFF607D8B), // ブルーグレー
    Color(0xFF795548), // ブラウン
    Color(0xFF009688), // ティール
    Color(0xFFE91E63), // ピンク
    Color(0xFF3F51B5), // インディゴ
  ];
}

/// 定義済みのアイコンリスト
class CategoryIcons {
  static const List<IconData> predefinedIcons = [
    // 食事・飲食関連
    Icons.fastfood,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.cake,
    Icons.lunch_dining,
    
    // 交通・移動関連
    Icons.directions_car,
    Icons.directions_bus,
    Icons.train,
    Icons.flight,
    Icons.local_taxi,
    Icons.directions_bike,
    Icons.directions_walk,
    
    // 娯楽・趣味関連
    Icons.movie,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.games,
    Icons.book,
    Icons.camera_alt,
    Icons.fitness_center,
    
    // 生活必需品関連
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.store,
    Icons.local_grocery_store,
    Icons.home,
    Icons.electric_bolt,
    Icons.water_drop,
    
    // 健康・医療関連
    Icons.favorite,
    Icons.local_hospital,
    Icons.medical_services,
    Icons.medication,
    Icons.health_and_safety,
    
    // 教育・学習関連
    Icons.school,
    Icons.library_books,
    Icons.computer,
    Icons.science,
    
    // 仕事・収入関連
    Icons.work,
    Icons.attach_money,
    Icons.account_balance,
    Icons.trending_up,
    Icons.business,
    Icons.card_giftcard,
    
    // その他
    Icons.category,
    Icons.star,
    Icons.favorite_border,
    Icons.lightbulb,
    Icons.pets,
    Icons.child_care,
    Icons.elderly,
    Icons.accessibility,
    Icons.savings,
    Icons.credit_card,
    Icons.account_balance_wallet,
    Icons.payment,
    Icons.money,
    Icons.local_atm,
    Icons.euro,
    Icons.currency_yen,
    Icons.currency_exchange,
  ];

  /// アイコンをカテゴリ別に分類
  static const Map<String, List<IconData>> categorizedIcons = {
    '食事・飲食': [
      Icons.fastfood,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.local_bar,
      Icons.cake,
      Icons.lunch_dining,
      Icons.dinner_dining,
      Icons.breakfast_dining,
      Icons.local_pizza,
    ],
    '交通・移動': [
      Icons.directions_car,
      Icons.directions_bus,
      Icons.train,
      Icons.flight,
      Icons.local_taxi,
      Icons.directions_bike,
      Icons.directions_walk,
      Icons.motorcycle,
      Icons.local_shipping,
    ],
    '娯楽・趣味': [
      Icons.movie,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.games,
      Icons.book,
      Icons.camera_alt,
      Icons.fitness_center,
      Icons.beach_access,
      Icons.park,
    ],
    '買い物・生活': [
      Icons.shopping_bag,
      Icons.shopping_cart,
      Icons.store,
      Icons.local_grocery_store,
      Icons.home,
      Icons.electric_bolt,
      Icons.water_drop,
      Icons.wifi,
      Icons.phone,
    ],
    '健康・医療': [
      Icons.favorite,
      Icons.local_hospital,
      Icons.medical_services,
      Icons.medication,
      Icons.health_and_safety,
      Icons.psychology,
      Icons.spa,
    ],
    '教育・学習': [
      Icons.school,
      Icons.library_books,
      Icons.computer,
      Icons.science,
      Icons.calculate,
      Icons.translate,
      Icons.code,
    ],
    '仕事・収入': [
      Icons.work,
      Icons.attach_money,
      Icons.account_balance,
      Icons.trending_up,
      Icons.business,
      Icons.card_giftcard,
      Icons.savings,
      Icons.credit_card,
    ],
    'その他': [
      Icons.category,
      Icons.star,
      Icons.favorite_border,
      Icons.lightbulb,
      Icons.pets,
      Icons.child_care,
      Icons.elderly,
      Icons.accessibility,
    ],
  };
}
