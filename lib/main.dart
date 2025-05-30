import 'package:flutter/material.dart';
import 'core/app_initializer.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_screen.dart';
import 'providers/app_state_provider.dart';
import 'providers/search_provider.dart';
import 'providers/graph_provider.dart';
import 'providers/data_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app following the specified flow
  final appInitializer = AppInitializer();
  await appInitializer.initialize();

  runApp(MyApp(appInitializer: appInitializer));
}

class MyApp extends StatelessWidget {
  final AppInitializer appInitializer;

  const MyApp({super.key, required this.appInitializer});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final searchProvider = SearchProvider();
            searchProvider.initialize(appInitializer.dataService);
            return searchProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final dataProvider = DataProvider(appInitializer.dataService);
            final graphProvider = GraphProvider();
            graphProvider.initialize(appInitializer.graphService, appInitializer.dataService, dataProvider);
            return graphProvider;
          },
        ),
        Provider<DataProvider>(create: (_) => DataProvider(appInitializer.dataService)),
      ],
      child: MaterialApp(
        title: 'HanziGraph Flutter',
        theme: AppTheme.lightTheme,
        home: MainScreen(appInitializer: appInitializer),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
