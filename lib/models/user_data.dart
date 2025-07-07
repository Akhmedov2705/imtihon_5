class UserData {
  final double height;
  final double weight;
  final double bmi;

  UserData({required this.height, required this.weight, required this.bmi});

  Map<String, dynamic> toJson() => {
    'height': height,
    'weight': weight,
    'bmi': bmi,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    height: json['height'],
    weight: json['weight'],
    bmi: json['bmi'],
  );
}
