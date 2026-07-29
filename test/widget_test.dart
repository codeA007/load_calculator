import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:load_calculator/providers/calculator_provider.dart';
import 'package:load_calculator/providers/load_groups_provider.dart';
import 'package:load_calculator/providers/parts_provider.dart';
import 'package:load_calculator/providers/settings_provider.dart';
import 'package:load_calculator/screens/home_screen.dart';
import 'package:provider/provider.dart';

class _FakePartsProvider extends PartsProvider {
  @override
  int get partsCount => 0;

  @override
  Future<void> refreshCount() async {}
}

class _FakeLoadGroupsProvider extends LoadGroupsProvider {
  @override
  int get groupsCount => 0;

  @override
  Future<void> refreshCount() async {}
}

class _FakeSettingsProvider extends SettingsProvider {
  @override
  double get furnaceCapacityKg => SettingsProvider.defaultFurnaceCapacityKg;

  @override
  bool get isLoaded => true;

  @override
  Future<void> load() async {}
}

void main() {
  testWidgets('Home screen shows main actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: _FakeSettingsProvider(),
          ),
          ChangeNotifierProvider<PartsProvider>.value(
            value: _FakePartsProvider(),
          ),
          ChangeNotifierProvider(create: (_) => CalculatorProvider()),
          ChangeNotifierProvider<LoadGroupsProvider>.value(
            value: _FakeLoadGroupsProvider(),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Furnace Load Calculator'), findsOneWidget);
    expect(find.text('Parts Library'), findsOneWidget);
    expect(find.text('Furnace Calculator'), findsOneWidget);
    expect(find.text('Saved Groups'), findsOneWidget);
    expect(find.text('Version 1.2.2'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Settings'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
