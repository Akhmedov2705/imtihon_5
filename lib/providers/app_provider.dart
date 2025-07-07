import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../models/food_entry.dart';

final userDataProvider = StateProvider<UserData?>((ref) => null);
final foodEntriesProvider = StateProvider<List<FoodEntry>>((ref) => []);
final isCameraLoadingProvider = StateProvider<bool>((ref) => false);
final isGalleryLoadingProvider = StateProvider<bool>((ref) => false);
