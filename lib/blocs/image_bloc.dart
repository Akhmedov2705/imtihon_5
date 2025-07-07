// STEP 1: Bloc Event
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imtihon_main/models/food_entry.dart';
import 'package:imtihon_main/providers/app_provider.dart';
import 'package:imtihon_main/services/gemini_services.dart';

abstract class ImageEvent {}

class PickImageEvent extends ImageEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}

// STEP 2: Bloc State
abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageSuccess extends ImageState {
  final FoodEntry food;
  ImageSuccess(this.food);
}

class ImageFailure extends ImageState {
  final String message;
  ImageFailure(this.message);
}

// STEP 3: Bloc Logic
class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImagePicker _picker;
  final GeminiService _geminiService;
  final WidgetRef ref;

  ImageBloc(this._picker, this._geminiService, this.ref)
    : super(ImageInitial()) {
    on<PickImageEvent>((event, emit) async {
      try {
        emit(ImageLoading());

        final picked = await _picker.pickImage(
          source: event.source,
          maxHeight: 800,
          maxWidth: 800,
        );

        if (picked == null) {
          emit(ImageInitial());
          return;
        }

        final file = File(picked.path);
        final analysis = await _geminiService.analyzeFoodImage(file);

        final userData = ref.read(userDataProvider);
        if (userData == null) {
          emit(ImageFailure('Boʻy va vaznni kiriting'));
          return;
        }

        final exercises = await _geminiService.getExerciseRecommendations(
          userData.height,
          userData.weight,
          analysis.calories,
        );
        log(exercises.toString());

        final foodEntry = analysis.getFoofEntry(
          date: DateTime.now(),
          exercises: exercises,
        );

        final box = Hive.box<FoodEntry>('foodEntries');
        await box.add(foodEntry);

        final old = ref.read(foodEntriesProvider);
        ref.read(foodEntriesProvider.notifier).state = [foodEntry, ...old];

        emit(ImageSuccess(foodEntry));
      } catch (e) {
        emit(ImageFailure('Xatolik yuz berdi: \$e'));
      }
    });
  }
}
