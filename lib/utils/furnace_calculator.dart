class FurnaceCalculator {
  FurnaceCalculator._();

  static const defaultCapacityKg = 270.0;

  static double heatsRequired(
    double totalWeightKg, {
    double capacityKg = defaultCapacityKg,
  }) {
    if (totalWeightKg <= 0 || capacityKg <= 0) {
      return 0;
    }
    return totalWeightKg / capacityKg;
  }
}
