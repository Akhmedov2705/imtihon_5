import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imtihon_main/models/food_entry.dart';

class FoodScreen extends StatelessWidget {
  final FoodEntry food;
  const FoodScreen({super.key, required this.food});

  Widget mianRow({required String text1, required String text2}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            text1,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Spacer(),
          Text(
            text2,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(food.imagePath),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 1 / 3,
              fit: BoxFit.cover,
            ),

            Center(
              child: Text(food.description, style: TextStyle(fontSize: 20)),
            ),
            mianRow(text1: "Kaloriya", text2: food.calories),
            mianRow(text1: "Protein", text2: food.protein),
            mianRow(text1: "Yog`", text2: food.fat),
            mianRow(text1: "Uglevodlar", text2: food.carbs),

            Text("Mashg'ulotlar:"),

            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => Text(food.exercises[index]),
              separatorBuilder: (context, index) => Divider(),
              itemCount: food.exercises.length,
            ),
          ],
        ),
      ),
    );
  }
}
