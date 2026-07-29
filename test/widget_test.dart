import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:load_calculator/providers/calculator_provider.dart';
import 'package:load_calculator/providers/parts_provider.dart';
import 'package:load_calculator/screens/home_screen.dart';
import 'package:provider/provider.dart';

class _FakePartsProvider extends PartsProvider {
  @override
  int get partsCount => 0;

  @override
  Future<void> refreshCount() async {}
}

void main() {
  testWidgets('Home screen shows main actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PartsProvider>.value(
            value: _FakePartsProvider(),
          ),
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Load Calculator'), findsOneWidget);
    expect(find.text('Parts Library'), findsOneWidget);
    expect(find.text('Calculate Load'), findsOneWidget);
  });
}
