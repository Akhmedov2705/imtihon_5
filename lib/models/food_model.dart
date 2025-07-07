import 'dart:convert';

import 'package:imtihon_main/models/food_entry.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FoodModel {
  final String imagePath;
  final String calories;
  final String protein;
  final String fat;
  final String carbs;
  final String description;

  FoodModel({
    required this.imagePath,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imagePath': imagePath,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'description': description,
    };
  }

  FoodEntry getFoofEntry({
    required DateTime date,
    required List<String> exercises,
  }) {
    return FoodEntry(
      carbs: carbs,
      protein: protein,
      fat: fat,
      imagePath: imagePath,
      calories: calories,
      description: description,
      exercises: exercises,
      date: date,
    );
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      imagePath: map['imagePath'] as String,
      calories: map['calories'] as String,
      protein: map['protein'] as String,
      fat: map['fat'] as String,
      carbs: map['carbs'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory FoodModel.fromJson(String source) =>
      FoodModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
