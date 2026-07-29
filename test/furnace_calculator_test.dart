import 'package:flutter_test/flutter_test.dart';
import 'package:load_calculator/utils/furnace_calculator.dart';

void main() {
  test('heatsRequired returns 0 for zero or negative weight', () {
    expect(FurnaceCalculator.heatsRequired(0), 0);
    expect(FurnaceCalculator.heatsRequired(-10), 0);
  });

  test('heatsRequired calculates decimal furnace heats', () {
    expect(FurnaceCalculator.heatsRequired(270), 1);
    expect(FurnaceCalculator.heatsRequired(135), 0.5);
    expect(FurnaceCalculator.heatsRequired(450), closeTo(1.67, 0.01));
  });
}
