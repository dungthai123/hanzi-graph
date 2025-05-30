# HanziGraph Flutter

A Flutter transpilation of the JavaScript HanziGraph application for exploring Chinese character relationships and learning.

## ✅ Successfully Transpiled Features

### 1. **Initialization Flow (Following JavaScript Pattern)**

- **Phase 1**: Data Loading Phase (equivalent to data-load.js)
- **Phase 2**: Core Infrastructure (dataLayerInit, fileAnalysisInitialize)
- **Phase 3**: UI & State Management (orchestratorInit, optionsInit)
- **Phase 4**: Core Features (graphInit, studyModeInit, exploreInit)
- **Phase 5**: Search & Event Handlers (searchInit)
- **Phase 6**: Secondary Features (statsInit, faqInit)

### 2. **Architecture Components**

- `AppInitializer` - Main initialization controller
- `DataService` - Equivalent to data-layer.js
- `SearchService` - Equivalent to search.js + search-suggestions-worker.js
- `GraphService` - Equivalent to graph.js
- `AppStateProvider` - Equivalent to ui-orchestrator.js

### 3. **UI Components**

- `MainScreen` - Main app layout with state switching
- `SearchBarWidget` - Search with Chinese character tokenization
- `GraphWidget` - Graph visualization (simplified Canvas version)
- `ExamplesWidget` - Character details and examples
- `MenuWidget` & `FaqWidget` - Navigation and help

### 4. **Data Structure**

- **✅ REAL DATA INTEGRATION**: All data moved from `public/data/` to `assets/data/`
- **257 Chinese characters** with definitions and pinyin
- **187 example sentences** with Chinese, English, and pinyin
- **1,191 frequency-ranked words** for character relationships
- Supports simplified, traditional, HSK, and Cantonese character sets
- JSON data loading with proper error handling

### 5. **State Management**

- Provider pattern replicating JavaScript event-driven architecture
- Proper state transitions matching the original UI orchestrator
- Search state management with suggestions and results

## 🎯 Data Integration Verification

The app now successfully uses real data from `assets/data/simplified/`:

```
📚 Definitions: 257 characters
📝 Sentences: 187 examples
📖 Wordlist: 1,191 words

Example - Character "我" (I/me):
📖 Definition: I; me; my (wo3)
📝 Example sentences:
   我是 - I am!
   我也能去 - I can come, too.
   别告诉他我在这 - Don't tell him that I'm here.
```

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Demo data loading
dart demo.dart
```

## 📱 Features

### ✅ Implemented

- **Character Search**: Find Chinese characters with real-time suggestions
- **Definitions**: Display character meanings with pinyin pronunciation
- **Example Sentences**: Show real usage in context with translations
- **Graph Visualization**: Character relationship mapping
- **Responsive UI**: Material Design optimized for Chinese characters

### ❌ Excluded (As Requested)

- Login/Authentication features
- Learning flashcard features
- Study mode functionality
- Statistics tracking

## 🏗️ Architecture

### Data Flow

1. **AppInitializer** loads JSON data from assets during startup
2. **DataService** provides access to definitions, sentences, and components
3. **SearchProvider** manages search state and character selection
4. **GraphProvider** generates and manages character relationship graphs
5. **ExamplesWidget** displays character details using real data

### File Structure

```
lib/
├── core/
│   └── app_initializer.dart      # Main initialization flow
├── services/
│   ├── data_service.dart         # Data access layer
│   ├── search_service.dart       # Search functionality
│   └── graph_service.dart        # Graph generation
├── providers/
│   ├── app_state_provider.dart   # App state management
│   ├── search_provider.dart      # Search state
│   ├── graph_provider.dart       # Graph state
│   └── data_provider.dart        # Data access
├── ui/
│   ├── screens/
│   │   └── main_screen.dart      # Main app layout
│   ├── widgets/
│   │   ├── search_bar_widget.dart
│   │   ├── graph_widget.dart
│   │   ├── examples_widget.dart
│   │   ├── menu_widget.dart
│   │   └── faq_widget.dart
│   └── theme/
│       └── app_theme.dart        # Chinese character optimized theme
└── models/
    ├── definition_data.dart
    ├── sentence_data.dart
    ├── component_data.dart
    └── graph_data.dart
```

## 🎨 Theme

Custom theme optimized for Chinese characters:

- **Hanzi Color**: `#1A1A1A` (dark gray for readability)
- **Pinyin Color**: `#666666` (medium gray for pronunciation)
- **Definition Color**: `#333333` (readable text)
- **Primary Color**: Material blue for UI elements

## 🧪 Testing

- Unit tests for DataService with real data parsing
- Integration tests for app initialization
- Widget tests for UI components
- Demo script showing data loading capabilities

## 📊 Performance

- Efficient JSON parsing during app startup
- Lazy loading of character relationships
- Optimized search with character tokenization
- Memory-efficient data structures

## 🌐 Internationalization

Ready for:

- Simplified Chinese (implemented)
- Traditional Chinese (data structure ready)
- HSK levels (data structure ready)
- Cantonese (data structure ready)

---

**Status**: ✅ **COMPLETE** - Successfully transpiled from JavaScript to Flutter with full real data integration
