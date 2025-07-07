import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:imtihon_main/models/food_model.dart';

class GeminiService {
  final Gemini _gemini = Gemini.instance;

  Future<FoodModel> analyzeFoodImage(File image) async {
    try {
      final Uint8List imageBytes = await image.readAsBytes();

      final response = await Gemini.instance.textAndImage(
        text: '''
Please analyze the food in the attached image and respond only in the following format:

Description: (food name)
Calories: (amount in kcal)
Protein: (grams)
Fat: (grams)
Carbs: (grams)

Only return data, do not include any extra explanation.
''',
        images: [imageBytes],
        modelName: 'gemini-1.5-pro',
      );

      final text = _extractTextFromCandidates(response);
      final parsed = _parseResponse(text);
      log(parsed.toString());
      print("****" * 20);
      print(parsed);
      print(parsed.keys);
      print("****" * 20);
      parsed["imagePath"] = image.path;

      return FoodModel.fromMap(parsed);
      //  {
      //   'description': parsed['description'] ?? 'Nomaʼlum',
      //   'calories': parsed['calories'] ?? '0',
      //   'protein': parsed['protein'] ?? '0',
      //   'fat': parsed["fat'"] ?? '0',
      //   'carbs': parsed['carbs'] ?? '0',
      // };
    } catch (e) {
      log(e.toString());
      throw Exception('Rasm tahlil qilinmadi: $e');
    }
  }

  Future<List<String>> getExerciseRecommendations(
    double height,
    double weight,
    String calories,
  ) async {
    try {
      final response = await _gemini.text('''
Men $height sm bo‘yli va $weight kg vazndaman. Endigina $calories  ovqat iste’mol qildim. 
Uy sharoitida shu kaloriyani yo‘qotish uchun qanday mashqlar qilishim mumkin? 
Iltimos, quyidagi formatda 4-5 ta mashq yozing:
- Mashq 1
- Mashq 2
- Mashq 3
- Mashq 4
- Mashq 5
''', modelName: 'gemini-1.5-pro');

      final text = _extractTextFromCandidates(response);
      return text
          .split('\n')
          .where((line) => line.trim().startsWith('- '))
          .map((line) => line.substring(2).trim())
          .toList();
    } catch (e) {
      throw Exception('Mashq tavsiyalarini olishda xato: $e');
    }
  }

  String _extractTextFromCandidates(Candidates? candidates) {
    if (candidates == null) return '';

    final content = candidates.content;
    if (content == null || content.parts == null || content.parts!.isEmpty)
      return '';

    return candidates.content!.parts!
        .map((part) {
          if (part is TextPart) {
            return part.text;
          } else {
            return ''; // rasmlar yoki boshqa formatlar uchun
          }
        })
        .join('\n')
        .trim();
  }

  Map<String, dynamic> _parseResponse(String response) {
    try {
      return jsonDecode(response);
    } catch (_) {
      final lines = response.split('\n');
      final result = <String, dynamic>{};
      for (var line in lines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            result[parts[0].trim().toLowerCase()] = parts[1].trim();
          }
        }
      }
      return result;
    }
  }
}
