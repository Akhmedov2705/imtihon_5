import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imtihon_main/providers/app_provider.dart';
import 'package:imtihon_main/widgets/bmi_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../services/bmi_calculator.dart';

class UserInputScreen extends ConsumerStatefulWidget {
  @override
  _UserInputScreenState createState() => _UserInputScreenState();
}

class _UserInputScreenState extends ConsumerState<UserInputScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final height = prefs.getDouble('height') ?? 0.0;
    final weight = prefs.getDouble('weight') ?? 0.0;
    if (height > 0 && weight > 0) {
      final bmi = BmiCalculator.calculateBmi(height, weight);
      ref.read(userDataProvider.notifier).state = UserData(
        height: height,
        weight: weight,
        bmi: bmi,
      );
      _heightController.text = height.toString();
      _weightController.text = weight.toString();
    }
  }

  Future<void> _saveUserData() async {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        _errorMessage = 'Iltimos, to‘g‘ri bo‘y va vazn kiriting';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    final bmi = BmiCalculator.calculateBmi(height, weight);
    ref.read(userDataProvider.notifier).state = UserData(
      height: height,
      weight: weight,
      bmi: bmi,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('height', height);
    await prefs.setDouble('weight', weight);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ma\'lumotlar saqlandi')));
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foydalanuvchi ma\'lumotlari'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Bo\'y (sm)',
                  border: OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Vazn (kg)',
                  border: OutlineInputBorder(),
                  errorText: _errorMessage,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Saqlash'),
              ),
              SizedBox(height: 20),

              Consumer(
                builder: (context, ref, child) {
                  final userData = ref.watch(userDataProvider);
                  return userData != null
                      ? Text(
                          'BMI: ${userData.bmi.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final userData = ref.watch(userDataProvider);
                  return userData != null
                      ? Column(
                          children: [
                            Text(
                              'BMI: ${userData.bmi.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Flexible(child: BmiChart(bmi: userData.bmi)),
                              ],
                            ),
                          ],
                        )
                      : SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
