class BmiCalculator {
  static double calculateBmi(double height, double weight) {
    return weight / ((height / 100) * (height / 100));
  }
}
