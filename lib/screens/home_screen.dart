import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/load_groups_provider.dart';
import '../providers/parts_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_navigation_card.dart';
import 'calculator/calculator_screen.dart';
import 'groups/saved_groups_screen.dart';
import 'parts/parts_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const appVersion = '1.2.1';

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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primarySteel,
                    Color(0xFF2C5364),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      size: 36,
                      color: AppTheme.furnaceAmber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Furnace Load Calculator',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate melt weight and furnace heats required\n(270 kg per furnace)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(
                        icon: Icons.inventory_2_outlined,
                        label: '$partsCount parts',
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        icon: Icons.folder_open_outlined,
                        label: '$groupsCount groups',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppNavigationCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Parts Library',
                    subtitle: 'Add, edit, or import parts with weights',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PartsListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppNavigationCard(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Furnace Calculator',
                    subtitle: 'Build a load and see furnace heats required',
                    iconColor: AppTheme.furnaceAmber,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppNavigationCard(
                    icon: Icons.folder_open_outlined,
                    title: 'Saved Groups',
                    subtitle: 'View previously saved load calculations',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedGroupsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Version ${HomeScreen.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
