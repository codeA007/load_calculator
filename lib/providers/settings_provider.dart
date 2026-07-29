import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider();

  static const defaultFurnaceCapacityKg = 270.0;
  static const _capacityKey = 'furnace_capacity_kg';

  double _furnaceCapacityKg = defaultFurnaceCapacityKg;
  bool _isLoaded = false;

  double get furnaceCapacityKg => _furnaceCapacityKg;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _furnaceCapacityKg =
        prefs.getDouble(_capacityKey) ?? defaultFurnaceCapacityKg;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setFurnaceCapacityKg(double value) async {
    if (value <= 0) {
      throw ArgumentError('Furnace capacity must be greater than 0');
    }

    _furnaceCapacityKg = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_capacityKey, value);
  }
}
