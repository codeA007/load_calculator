import 'package:flutter/foundation.dart';

import '../models/calc_line_item.dart';
import '../models/part.dart';
import '../utils/furnace_calculator.dart';

class CalculatorProvider extends ChangeNotifier {
  final List<CalcLineItem> _lineItems = [];

  List<CalcLineItem> get lineItems => List.unmodifiable(_lineItems);

  double get grandTotal =>
      _lineItems.fold(0, (sum, item) => sum + item.lineWeight);

  double get furnaceHeatsRequired =>
      FurnaceCalculator.heatsRequired(grandTotal);

  void addLineItem(Part part, double quantity) {
    _lineItems.add(CalcLineItem(part: part, quantity: quantity));
    notifyListeners();
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= _lineItems.length) {
      return;
    }
    _lineItems.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _lineItems.clear();
    notifyListeners();
  }
}
