import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/food_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: "AIzaSyBlec1htUQlFkO7hN39j0mlnP7t73hq2qg");
  Gemini.instance;

  await Hive.initFlutter();
  Hive.registerAdapter(FoodEntryAdapter());

  await Hive.openBox<FoodEntry>('foodEntries');
  runApp(ProviderScope(child: FitAIApp()));
}

class FitAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitAI',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
