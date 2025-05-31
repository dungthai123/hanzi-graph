# Features - MVVM Lite Architecture

This directory contains all the features of the application, organized using the **MVVM Lite** pattern to reduce boilerplate while maintaining clean separation of concerns.

## Architecture Structure

Each feature follows this simplified structure:

```
feature_name/
├── model/
│   └── feature_model.dart          # Data models and entities
├── datasource/
│   └── feature_datasource.dart     # Data access layer
├── repository/
│   └── feature_repository.dart     # Repository pattern implementation
├── viewmodel/
│   └── feature_viewmodel.dart      # Business logic and state management
└── view/
    └── feature_screen.dart         # UI components and screens
```

## Key Benefits of MVVM Lite

### ✅ Reduced Boilerplate

- **Before**: Separate interfaces, implementations, use cases, entities
- **After**: Combined concrete classes with clear responsibilities

### ✅ Simplified Dependencies

- **Before**: Multiple layers with abstract interfaces
- **After**: Direct dependencies with concrete implementations

### ✅ Maintained Separation of Concerns

- **Model**: Data structures and business entities
- **DataSource**: Raw data access (APIs, databases, files)
- **Repository**: Data coordination and caching logic
- **ViewModel**: Business logic and UI state management
- **View**: UI components and user interactions

### ✅ Easy Testing

- Each layer can be easily mocked and tested
- Clear boundaries between components
- Minimal setup required for unit tests

## Current Features

### 📝 Hanzi Feature

- **Purpose**: Chinese character exploration and learning
- **Models**: `HanziDefinition`, `HanziSentence`, `HanziComponent`, `HanziDetails`
- **Key Operations**: Search characters, get definitions, view components

### 📊 Graph Feature

- **Purpose**: Visual relationship graphs for characters
- **Models**: `GraphNode`, `GraphEdge`, `GraphData`
- **Key Operations**: Generate graphs, build component trees, visualize relationships

## Usage Pattern

### 1. Model Layer

```dart
class FeatureModel {
  final String id;
  final String name;
  // ... other properties
}
```

### 2. DataSource Layer

```dart
class FeatureDataSource {
  Future<FeatureModel> getData(String id) async {
    // Raw data access logic
  }
}
```

### 3. Repository Layer

```dart
class FeatureRepository {
  final FeatureDataSource _dataSource;

  FeatureRepository(this._dataSource);

  Future<FeatureModel> getFeature(String id) async {
    return await _dataSource.getData(id);
  }
}
```

### 4. ViewModel Layer

```dart
class FeatureViewModel extends BaseViewModel {
  final FeatureRepository _repository;

  FeatureViewModel(this._repository);

  Future<void> loadFeature(String id) async {
    await handleAsyncOperation(() async {
      final feature = await _repository.getFeature(id);
      // Update UI state
      return feature;
    });
  }
}
```

### 5. View Layer

```dart
class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureViewModel>(
      builder: (context, viewModel, child) {
        // UI implementation
      },
    );
  }
}
```

## Migration from Clean Architecture

The refactoring from Clean Architecture to MVVM Lite involved:

1. **Consolidating Entities**: Moved from `domain/entities/` to `model/`
2. **Simplifying DataSources**: Removed abstract interfaces, kept concrete implementations
3. **Streamlining Repositories**: Combined interface and implementation
4. **Eliminating Use Cases**: Moved business logic directly to ViewModels
5. **Maintaining ViewModels**: Kept the same structure with enhanced responsibilities

This approach maintains the benefits of layered architecture while significantly reducing complexity and boilerplate code.
