# HanziGraph MVVM Architecture

This document explains the refactored MVVM (Model-View-ViewModel) architecture with feature-first organization.

## Architecture Overview

The application follows a clean MVVM architecture with the following layers:

```
View (UI) → ViewModel → Use Cases → Repository → Data Source
```

### Layer Responsibilities

1. **Data Source**: Raw data access and external API calls
2. **Repository**: Data abstraction and business logic coordination
3. **Use Cases**: Specific business operations
4. **ViewModel**: UI state management and user interaction handling
5. **View**: UI components and user interface

## Feature-First Organization

The codebase is organized by features rather than by technical layers:

```
lib/
├── core/
│   ├── base/
│   │   └── base_view_model.dart          # Base class for all view models
│   └── di/
│       └── dependency_injection.dart     # Dependency injection setup
├── features/
│   ├── hanzi/                           # Hanzi character feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── hanzi_datasource.dart
│   │   │   └── repositories/
│   │   │       └── hanzi_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── hanzi_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── hanzi_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_hanzi_details.dart
│   │   │       └── search_hanzi.dart
│   │   └── presentation/
│   │       └── viewmodels/
│   │           └── hanzi_viewmodel.dart
│   └── graph/                           # Graph visualization feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── graph_datasource.dart
│       │   └── repositories/
│       │       └── graph_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── graph_entity.dart
│       │   ├── repositories/
│       │   │   └── graph_repository.dart
│       │   └── usecases/
│       │       └── generate_graph.dart
│       └── presentation/
│           └── viewmodels/
│               └── graph_viewmodel.dart
└── main_mvvm.dart                       # MVVM app entry point
```

## Key Components

### Base View Model

All view models extend `BaseViewModel` which provides:

- Loading state management
- Error handling
- Async operation handling
- Proper disposal

```dart
class HanziViewModel extends BaseViewModel {
  Future<void> searchCharacters(String query) async {
    await handleAsyncOperation(() async {
      _searchResults = await _searchHanzi(query);
      return _searchResults;
    }, showLoading: false);
  }
}
```

### Dependency Injection

The `DependencyInjection` class wires all components together:

```dart
final di = DependencyInjection();
di.initialize(
  hanziData: hanziData,
  sentencesData: sentencesData,
  definitionsData: definitionsData,
  componentsData: componentsData,
);

// Access view models
final hanziViewModel = di.hanziViewModel;
final graphViewModel = di.graphViewModel;
```

### Use Cases

Business logic is encapsulated in use cases:

```dart
class GetHanziDetails {
  final HanziRepository _repository;

  GetHanziDetails(this._repository);

  Future<HanziDetails> call(String character) async {
    final definition = await _repository.getDefinition(character);
    final sentences = await _repository.getSentences(character);
    // ... combine data
    return HanziDetails(...);
  }
}
```

## Features

### Hanzi Feature

Handles character search, definitions, and details:

- **Entities**: `HanziDefinition`, `HanziSentence`, `HanziComponent`, `HanziDetails`
- **Use Cases**: `GetHanziDetails`, `SearchHanzi`
- **Repository**: Character data access abstraction
- **Data Source**: Local JSON data access
- **ViewModel**: Search and character selection state

### Graph Feature

Handles graph visualization and component trees:

- **Entities**: `GraphNode`, `GraphEdge`, `GraphData`
- **Use Cases**: `GenerateGraph`, `GenerateComponentTree`
- **Repository**: Graph generation abstraction
- **Data Source**: Graph algorithm implementation
- **ViewModel**: Graph state and mode switching

## Usage

### Running the MVVM Version

```bash
# Run the MVVM version
flutter run lib/main_mvvm.dart
```

### Using View Models in UI

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HanziViewModel>(
      builder: (context, hanziViewModel, child) {
        if (hanziViewModel.isLoading) {
          return CircularProgressIndicator();
        }

        if (hanziViewModel.error != null) {
          return Text('Error: ${hanziViewModel.error}');
        }

        return ListView.builder(
          itemCount: hanziViewModel.searchResults.length,
          itemBuilder: (context, index) {
            final character = hanziViewModel.searchResults[index];
            return ListTile(
              title: Text(character),
              onTap: () => hanziViewModel.selectCharacter(character),
            );
          },
        );
      },
    );
  }
}
```

## Benefits of This Architecture

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Testability**: Easy to unit test each layer independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same pattern
5. **Feature Organization**: Related code is grouped together
6. **Dependency Inversion**: High-level modules don't depend on low-level modules

## Testing Strategy

Each layer can be tested independently:

```dart
// Test use case
test('GetHanziDetails should return complete details', () async {
  final mockRepository = MockHanziRepository();
  final useCase = GetHanziDetails(mockRepository);

  when(mockRepository.getDefinition('人')).thenAnswer((_) async => mockDefinition);

  final result = await useCase('人');

  expect(result.character, '人');
  expect(result.hasDefinition, true);
});

// Test view model
test('HanziViewModel should update search results', () async {
  final mockUseCase = MockSearchHanzi();
  final viewModel = HanziViewModel(searchHanzi: mockUseCase);

  when(mockUseCase('人')).thenAnswer((_) async => ['人', '人民']);

  await viewModel.searchCharacters('人');

  expect(viewModel.searchResults, ['人', '人民']);
  expect(viewModel.isLoading, false);
});
```

## Migration from Old Architecture

The old architecture used:

- Services for business logic
- Providers for state management
- Models for data structures

The new architecture provides:

- Better separation of concerns
- Clearer data flow
- Easier testing
- More maintainable code

Both architectures can coexist during migration. The old `main.dart` continues to work while `main_mvvm.dart` demonstrates the new pattern.
