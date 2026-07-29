import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/calculator_provider.dart';
import 'providers/load_groups_provider.dart';
import 'providers/parts_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LoadCalculatorApp());
}

class LoadCalculatorApp extends StatelessWidget {
  const LoadCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PartsProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => LoadGroupsProvider()),
      ],
      child: MaterialApp(
        title: 'Load Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
