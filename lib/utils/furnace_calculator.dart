class FurnaceCalculator {
  FurnaceCalculator._();

  static const capacityKg = 270.0;

  static double heatsRequired(double totalWeightKg) {
    if (totalWeightKg <= 0) {
      return 0;
    }
    return totalWeightKg / capacityKg;
  }
}
