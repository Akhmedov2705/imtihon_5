import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:imtihon_main/providers/app_provider.dart';
import 'package:imtihon_main/screens/food_screen.dart';

class HistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(foodEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ovqat va mashqlar tarixi'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: entries.isEmpty
          ? Center(child: Text('Hozircha tarix mavjud emas'))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
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
                    title: Text(
                      entry.description,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kaloriya: ${entry.calories} kcal'),
                        Text('Sana: ${entry.date.toString().substring(0, 16)}'),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
