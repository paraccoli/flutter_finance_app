# GitHub Copilot Instructions for Money:G Flutter Finance App

## Architecture Overview

This is a **Flutter MVVM personal finance app** with a **service-oriented architecture** focused on privacy and offline functionality. Key patterns:

- **MVVM Pattern**: ViewModels (`lib/viewmodels/`) manage state using `ChangeNotifier` and `Provider`
- **Service Layer**: Business logic isolated in `lib/services/` (database, ads, export, notifications, etc.)
- **Data Models**: Immutable models in `lib/models/` with `fromMap()` and `toMap()` methods
- **Singleton Services**: Most services use singleton pattern (e.g., `DatabaseService()`, `CategoryService()`)

## Core Data Flow

```dart
// Standard pattern for data operations
final viewModel = Provider.of<ExpenseViewModel>(context, listen: false);
await viewModel.addExpense(expense); // Triggers notifyListeners() -> UI update
```

## Database Architecture

**SQLite with custom migration system** (`database_service.dart`):
- Manual version management (currently v6)
- Custom migration logic in `_onUpgrade()` with backup strategies
- Tables: `expenses`, `incomes`, `nisa_investments`, `custom_categories`
- Always use transactions for multi-table operations
- Cross-platform support via `sqflite_common_ffi`

```dart
// Pattern for database operations with error handling
Future<void> insertExpense(Expense expense) async {
  final db = await database;
  await db.transaction((txn) async {
    await txn.insert('expenses', expense.toMap());
  });
}
```

## Critical Development Patterns

### 1. Category System (Dual Legacy + Custom)
- **Legacy enums**: `ExpenseCategory`, `IncomeCategory` in models
- **Custom categories**: `custom_categories` table with `CategoryService`
- **Unified access**: Use `CategoryService().getExpenseCategories()` for UI
- **Backward compatibility**: Models support both `category` (enum) and `customCategoryId`

### 2. Theme System (Custom + Presets)
- **Preset themes**: 9 predefined themes including Light, Dark, Cosmic, Cosmos, Nature, etc.
- **Custom themes**: User-created themes with 3-color system (primary, secondary, accent)
- **Theme management**: Create, edit, duplicate, delete custom themes via `ThemeViewModel`
- **Real-time preview**: Theme changes apply immediately across all screens

### 3. Ad Integration Points
```dart
// Always add ads after user actions
await AdService().showInterstitialAd(); // After expense/income add
await AdService().showRewardAd(); // For premium features
```

### 4. Provider State Management
```dart
// Standard ViewModel pattern with error handling
class ExpenseViewModel extends ChangeNotifier {
  Future<void> addExpense(Expense expense) async {
    try {
      await _databaseService.insertExpense(expense);
      await loadExpenses(); // Refresh data
      // notifyListeners() called in loadExpenses()
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }
}
```

## Build & Test Commands

```bash
# Core development workflow
flutter pub get                    # Dependencies
flutter analyze                   # Static analysis (required for CI)
dart format --set-exit-if-changed . # Format check
flutter test --coverage           # Run tests with coverage

# Building
flutter build apk --release       # Android APK
flutter build appbundle --release # Google Play Store
flutter run                       # Hot reload development
```

## File Organization Rules

- **Models** (`lib/models/`): Immutable data classes with `fromMap`/`toMap`
- **ViewModels** (`lib/viewmodels/`): Extend `ChangeNotifier`, handle UI state
- **Services** (`lib/services/`): Business logic, external API integration
- **Views** (`lib/views/`): Screen-level widgets, consume ViewModels via `Provider.of()`
- **Widgets** (`lib/widgets/`): Reusable UI components

## Critical Integration Points

### AdMob Integration
- **Test IDs**: Used in development (see `admob_service.dart`)
- **Production IDs**: Set via `android/app/src/main/AndroidManifest.xml`
- **Ad timing**: After user actions (expense/income add), app startup, periodic

### CSV Import/Export
- **Legacy support**: MoneyG v1.2.2 CSV format compatibility in `csv_import_service.dart`
- **Multiple formats**: "expenses only", "income only", "all data"
- **Auto-detection**: Header-based format recognition

### Database Migrations
- **Version-based**: Increment version in `_initDatabase()` 
- **Backup strategy**: Create temporary tables during structure changes
- **Verification**: `_verifyTableStructure()` ensures data integrity post-migration

## Premium Features & Monetization

### Premium Functionality
- **Ad removal**: Purchase-based permanent ad removal
- **Premium features**: Advanced analytics, export formats, etc.
- **Temporary premium**: 24-hour access via reward ad viewing
- **Purchase service**: Handles in-app purchases via `PurchaseService`

### Ad Integration Strategy
- **Interstitial ads**: After user actions (add expense/income)
- **Banner ads**: On main screens with ad-free premium option
- **Reward ads**: Grant temporary premium access
- **AdMob service**: Centralized ad management with test/production IDs

## Development Environment Setup

1. **Flutter 3.8.1+** required (current version in `pubspec.yaml`)
2. **Dart SDK**: ^3.8.1 for latest language features
3. **Desktop development**: Uses `sqflite_common_ffi` for Windows/Linux/macOS
4. **Platform detection**: `Platform.isAndroid/isIOS` for mobile-specific code
5. **Debug logging**: Extensive `debugPrint()` statements (production-safe)

## Testing & Quality

- **Linting**: `flutter_lints` package with custom rules in `analysis_options.yaml`
- **CI/CD**: GitHub Actions for format, analyze, test, build (`/.github/workflows/`)
- **Coverage**: Required for CI pipeline
- **Cross-platform**: Builds for Android, iOS, Windows, Linux, macOS
- **Static analysis**: Must pass `flutter analyze` for CI

## Key External Dependencies

- **Charts**: `fl_chart ^1.0.0` for financial visualizations
- **State**: `provider ^6.1.2` for MVVM state management  
- **Database**: `sqflite ^2.3.2` + `sqflite_common_ffi ^2.3.2` for cross-platform
- **Monetization**: `google_mobile_ads ^5.2.0` + `in_app_purchase ^3.2.1`
- **UI**: `google_fonts ^6.2.0`, Material Design 3, custom theme system
- **File operations**: `file_picker ^10.1.9`, `csv ^6.0.0` for data import/export
- **Notifications**: `flutter_local_notifications ^19.2.1` + `timezone ^0.10.1`

## Release Management

### Version Control
- **Current version**: v1.3.4 (see `pubspec.yaml`)
- **Release notes**: Standardized format in `release/RELEASE_NOTE_TEMPLATE.md`
- **GitHub releases**: Automated with APK/AAB distribution
- **Documentation**: Comprehensive release notes for each version

### Build Process
- **APK building**: `flutter build apk --release`
- **AAB building**: `flutter build appbundle --release` (Google Play)
- **Multi-platform**: Support for Android, iOS, Windows, Linux, macOS
- **Asset management**: Icons, backgrounds via `flutter_launcher_icons`

When implementing new features, maintain the MVVM pattern, use the service layer for business logic, and ensure database operations are transactional. Always test both legacy and custom category scenarios.