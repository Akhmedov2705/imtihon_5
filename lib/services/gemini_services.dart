import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:imtihon_main/models/food_model.dart';

class GeminiService {
  final Gemini _gemini = Gemini.instance;

  // Retry mexanizmi - barcha so'rovlar uchun (uzaytirilgan)
  Future<T> _retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 5,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } on GeminiException catch (e) {
        log(
          'Gemini xatosi: ${e.message}, Status: ${e.statusCode}, Urinish: ${i + 1}/$maxRetries',
        );

        if (i == maxRetries - 1) {
          // Oxirgi urinish bo'lsa, aniq xato berish
          switch (e.statusCode) {
            case 503:
              throw Exception(
                'Gemini serveri yuklanib ketgan. 5-10 daqiqa kutib qayta urinib ko\'ring.',
              );
            case 429:
              throw Exception('Juda ko\'p so\'rov yuborildi. Bir oz kuting.');
            case 400:
              throw Exception(
                'Noto\'g\'ri so\'rov. Ma\'lumotlarni tekshiring.',
              );
            default:
              throw Exception('Xato: ${e.message}');
          }
        }

        // Uzaytirilgan kutish vaqti - 503 xato uchun
        int waitTime = e.statusCode == 503 ? (i + 1) * 10 : (i + 1) * 2;
        await Future.delayed(Duration(seconds: waitTime));
        log('Qayta urinish: ${i + 1}/$maxRetries (${waitTime}s kutildi)');
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: (i + 1) * 5));
        log('Umumiy xato, qayta urinish: ${i + 1}/$maxRetries - $e');
      }
    }
    throw Exception('Maksimal urinishlar soni oshdi');
  }

  // Rasm hajmini kamaytirish funksiyasi
  Future<Uint8List> _compressImageIfNeeded(File image) async {
    final bytes = await image.readAsBytes();
    // Agar rasm 1MB dan katta bo'lsa, ogohlantirish
    if (bytes.length > 1024 * 1024) {
      log(
        'Rasm hajmi katta: ${bytes.length} bytes. Mumkin bo\'lgan muammolar.',
      );
    }
    return bytes;
  }

  // Asosiy funksiya - nomini o'zgartirmadik
  Future<FoodModel> analyzeFoodImage(File image) async {
    try {
      return await _retryOperation(() => _analyzeFoodImageInternal(image));
    } catch (e) {
      log('analyzeFoodImage xatosi: $e');
      throw Exception('Rasm tahlil qilinmadi: $e');
    }
  }

  // Ichki funksiya - asl ishni bajaradi
  Future<FoodModel> _analyzeFoodImageInternal(File image) async {
    final Uint8List imageBytes = await _compressImageIfNeeded(image);

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
      // Eng yengil model - kam yuklangan
    );

    final text = _extractTextFromCandidates(response);
    final parsed = _parseResponse(text);
    log('Parsed response: $parsed');
    print("****" * 20);
    print(parsed);
    print(parsed.keys);
    print("****" * 20);
    parsed["imagePath"] = image.path;

    return FoodModel.fromMap(parsed);
  }

  // Asosiy funksiya - nomini o'zgartirmadik
  Future<List<String>> getExerciseRecommendations(
    double height,
    double weight,
    String calories,
  ) async {
    try {
      return await _retryOperation(
        () => _getExerciseRecommendationsInternal(height, weight, calories),
      );
    } catch (e) {
      log('getExerciseRecommendations xatosi: $e');
      throw Exception('Mashq tavsiyalarini olishda xato: $e');
    }
  }

  // Ichki funksiya - asl ishni bajaradi
  Future<List<String>> _getExerciseRecommendationsInternal(
    double height,
    double weight,
    String calories,
  ) async {
    final response = await _gemini.text('''
Men $height sm bo'yli va $weight kg vazndaman. Endigina $calories ovqat iste'mol qildim. 
Uy sharoitida shu kaloriyani yo'qotish uchun qanday mashqlar qilishim mumkin? 
Iltimos, quyidagi formatda 4-5 ta mashq yozing:
- Mashq 1
- Mashq 2
- Mashq 3
- Mashq 4
- Mashq 5
'''); // Eng yengil model

    final text = _extractTextFromCandidates(response);
    return text
        .split('\n')
        .where((line) => line.trim().startsWith('- '))
        .map((line) => line.substring(2).trim())
        .toList();
  }

  // Yordamchi funksiyalar - nomlarini o'zgartirmadik
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
      // Avval JSON formatda parse qilishga harakat
      return jsonDecode(response);
    } catch (_) {
      // JSON bo'lmasa, qatorma-qator parse qilish
      final lines = response.split('\n');
      final result = <String, dynamic>{};

      for (var line in lines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim().toLowerCase();
            final value = parts.sublist(1).join(':').trim();
            result[key] = value;
          }
        }
      }

      // Agar hech narsa topilmasa, standart qiymatlar
      if (result.isEmpty) {
        log('Response parse qilinmadi, standart qiymatlar berilmoqda');
        return {
          'description': 'Nomaʼlum ovqat',
          'calories': '0',
          'protein': '0',
          'fat': '0',
          'carbs': '0',
        };
      }

      return result;
    }
  }

  // Qo'shimcha: Service holati tekshirish
  Future<bool> checkServiceHealth() async {
    try {
      final response = await _gemini.text('Test');
      return response != null;
    } catch (e) {
      log('Service health check failed: $e');
      return false;
    }
  }

  // Fallback funksiyasi - agar Gemini ishlamasa
  Future<FoodModel> analyzeFoodImageFallback(File image) async {
    log('Fallback: Gemini ishlamadi, standart ma\'lumotlar qaytarilmoqda');
    return FoodModel.fromMap({
      'description': 'Tahlil qilinmagan ovqat',
      'calories': '200',
      'protein': '10',
      'fat': '5',
      'carbs': '30',
      'imagePath': image.path,
    });
  }

  // Asosiy funksiya - fallback bilan
  Future<FoodModel> analyzeFoodImageWithFallback(File image) async {
    try {
      // Avval service holatini tekshirish
      final isHealthy = await checkServiceHealth();
      if (!isHealthy) {
        log('Service unhealthy, fallback ishlatilmoqda');
        return await analyzeFoodImageFallback(image);
      }

      return await _retryOperation(() => _analyzeFoodImageInternal(image));
    } catch (e) {
      log('analyzeFoodImage muvaffaqiyatsiz, fallback ishlatilmoqda: $e');
      return await analyzeFoodImageFallback(image);
    }
  }
}
