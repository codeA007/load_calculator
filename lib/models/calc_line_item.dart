import 'part.dart';

class CalcLineItem {
  const CalcLineItem({
    required this.part,
    required this.quantity,
  });

  final Part part;
  final double quantity;

  double get lineWeight => part.weightKg * quantity;

  CalcLineItem copyWith({
    Part? part,
    double? quantity,
  }) {
    return CalcLineItem(
      part: part ?? this.part,
      quantity: quantity ?? this.quantity,
    );
  }
}
