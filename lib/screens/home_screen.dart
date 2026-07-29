import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/load_groups_provider.dart';
import '../providers/parts_provider.dart';
import 'calculator/calculator_screen.dart';
import 'groups/saved_groups_screen.dart';
import 'parts/parts_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartsProvider>().refreshCount();
      context.read<LoadGroupsProvider>().refreshCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partsCount = context.watch<PartsProvider>().partsCount;
    final groupsCount = context.watch<LoadGroupsProvider>().groupsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Calculator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Offline Load Weight Calculator',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your parts catalog and calculate total load weights with quantity breakdowns.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$partsCount parts in library',
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$groupsCount saved groups',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PartsListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Parts Library'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CalculatorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calculate Load'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedGroupsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Saved Groups'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
