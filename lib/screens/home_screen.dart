import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:imtihon_main/providers/app_provider.dart';
import 'package:imtihon_main/screens/food_screen.dart';
import 'package:imtihon_main/services/gemini_services.dart';
import 'dart:io';
import '../models/food_entry.dart';
import '../models/user_data.dart';
import 'user_input_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
  }

  Future<void> _pickImage(ImageSource source) async {
    final isCameraLoading = ref.read(isCameraLoadingProvider.notifier);
    final isGalleryLoading = ref.read(isGalleryLoadingProvider.notifier);

    if (source == ImageSource.camera) {
      isCameraLoading.state = true;
    } else {
      isGalleryLoading.state = true;
    }
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedImage == null) {
        isCameraLoading.state = false;
        isGalleryLoading.state = false;
        return;
      }
      ;

      final file = File(pickedImage.path);

      final analysis = await _geminiService.analyzeFoodImage(file);

      final userData = ref.read(userDataProvider);
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Iltimos, avval bo‘y va vaznni kiriting')),
        );
        return;
      }

      final exercises = await _geminiService.getExerciseRecommendations(
        userData.height,
        userData.weight,
        analysis.calories,
      );

      final foodEntry = analysis.getFoofEntry(
        date: DateTime.now(),
        exercises: exercises,
      );

      final box = Hive.box<FoodEntry>('foodEntries');
      await box.add(foodEntry);

      ref.read(foodEntriesProvider.notifier).state = [
        foodEntry,
        ...ref.read(foodEntriesProvider),
      ];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ovqat tahlil qilindi va saqlandi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasmni tahlil qilishda xato: $e')),
      );
    } finally {
      isCameraLoading.state = false;
      isGalleryLoading.state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final entries = ref.watch(foodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('FitAI'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserInputScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (userData == null) ...[
              Text('Iltimos, bo‘y va vaznni kiriting'),
            ] else ...[
              Consumer(
                builder: (context, ref, child) {
                  final isGalleryLoading = ref.watch(isGalleryLoadingProvider);
                  return ElevatedButton(
                    onPressed: isGalleryLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    child: isGalleryLoading
                        ? Center(child: CircularProgressIndicator())
                        : Text('Galereyadan rasm tanlash'),
                  );
                },
              ),
              SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  final isCameraLoading = ref.watch(isCameraLoadingProvider);

                  return ElevatedButton(
                    onPressed: isCameraLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    child: isCameraLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Kameradan rasm olish'),
                  );
                },
              ),
            ],
            SizedBox(height: 20),
            Expanded(
              child: entries.isEmpty
                  ? Center(child: Text('Hozircha ovqat tarixi yo‘q'))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FoodScreen(food: entries[index]),
                                ),
                              );
                            },
                            leading: Image.file(
                              File(entry.imagePath),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.error, size: 60),
                            ),
                            title: Text(entry.description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kaloriya:    ${entry.calories} kcal'),
                                Text(
                                  'Sanasi:     ${entry.date.toString().substring(0, 16)}',
                                ),
                                if (entry.exercises.isNotEmpty)
                                  Text(
                                    'Mashqlar:      ${entry.exercises.length} ta mashq',
                                    style: TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
