import 'package:hive/hive.dart';

part 'food_entry.g.dart';

@HiveType(typeId: 0)
class FoodEntry extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String calories;

  @HiveField(2)
  final String protein;

  @HiveField(3)
  final String fat;

  @HiveField(4)
  final String carbs;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final List<String> exercises;

  @HiveField(7)
  final DateTime date;

  FoodEntry({
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.imagePath,
    required this.calories,
    required this.description,
    required this.exercises,
    required this.date,
  });
}
