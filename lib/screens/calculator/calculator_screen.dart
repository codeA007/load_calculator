import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/part.dart';
import '../../providers/settings_provider.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/load_groups_provider.dart';
import '../../providers/parts_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/furnace_calculator.dart';
import '../../widgets/calc_line_item_tile.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/furnace_summary_panel.dart';
import '../../widgets/part_search_field.dart';
import '../parts/parts_list_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  Part? _selectedPart;
  final _quantityController = TextEditingController(text: '1');
  static final _weightFormat = NumberFormat('#,##0.###');
  static final _heatFormat = NumberFormat('0.00');

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartsProvider>().refreshCount();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  double? get _pendingQuantity {
    final qtyText = _quantityController.text.trim().replaceAll(',', '');
    final quantity = double.tryParse(qtyText);
    if (quantity == null || quantity <= 0) {
      return null;
    }
    return quantity;
  }

  void _addToLoad() {
    final part = _selectedPart;
    if (part == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a part first')),
      );
      return;
    }

    final quantity = _pendingQuantity;
    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity greater than 0')),
      );
      return;
    }

    context.read<CalculatorProvider>().addLineItem(part, quantity);
    setState(() {
      _selectedPart = null;
      _quantityController.text = '1';
    });
  }

  Future<void> _saveGroup() async {
    final calculator = context.read<CalculatorProvider>();
    if (calculator.lineItems.isEmpty) {
      return;
    }

    try {
      final group = await context.read<LoadGroupsProvider>().saveGroup(
            calculator.lineItems,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved group "${group.name}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final calculator = context.read<CalculatorProvider>();
    if (calculator.lineItems.isEmpty) {
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Clear Load',
      message: 'Remove all items from this calculation?',
      confirmLabel: 'Clear',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      calculator.clearAll();
    }
  }

  Widget? _buildPreviewChip(
    CalculatorProvider calculator,
    double furnaceCapacityKg,
  ) {
    final part = _selectedPart;
    final quantity = _pendingQuantity;
    if (part == null || quantity == null) {
      return null;
    }

    final addedWeight = part.weightKg * quantity;
    final newTotal = calculator.grandTotal + addedWeight;
    final newHeats = FurnaceCalculator.heatsRequired(
      newTotal,
      capacityKg: furnaceCapacityKg,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.furnaceAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.furnaceAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.furnaceAmber.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Adds ${_weightFormat.format(addedWeight)} kg → '
              'total ${_weightFormat.format(newTotal)} kg → '
              '${_heatFormat.format(newHeats)} furnace heats',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.furnaceAmber.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partsCount = context.watch<PartsProvider>().partsCount;
    final calculator = context.watch<CalculatorProvider>();
    final furnaceCapacity =
        context.watch<SettingsProvider>().furnaceCapacityKg;

    if (partsCount == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Furnace Calculator')),
        body: EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: 'No parts in library',
          message: 'Add parts before calculating furnace load.',
          action: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const PartsListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Go to Parts Library'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Furnace Calculator'),
        actions: [
          if (calculator.lineItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PartSearchField(
                      onPartSelected: (part) {
                        setState(() => _selectedPart = part);
                      },
                    ),
                    if (_selectedPart != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Selected: ${_selectedPart!.partNo} '
                        '(${_weightFormat.format(_selectedPart!.weightKg)} kg)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _addToLoad,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    if (_buildPreviewChip(calculator, furnaceCapacity) !=
                        null) ...[
                      const SizedBox(height: 12),
                      _buildPreviewChip(calculator, furnaceCapacity)!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: calculator.lineItems.isEmpty
                ? const EmptyStateView(
                    icon: Icons.local_fire_department_outlined,
                    title: 'No items added',
                    message:
                        'Search for a part, enter quantity, and tap Add to see furnace heats required.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: calculator.lineItems.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = calculator.lineItems[index];
                      return CalcLineItemTile(
                        item: item,
                        index: index,
                        onRemove: () {
                          context
                              .read<CalculatorProvider>()
                              .removeLineItem(index);
                        },
                      );
                    },
                  ),
          ),
          if (calculator.lineItems.isNotEmpty)
            FurnaceSummaryPanel(
              totalWeightKg: calculator.grandTotal,
              furnaceCapacityKg: furnaceCapacity,
              lineItemCount: calculator.lineItems.length,
              showSaveButton: true,
              compact: true,
              onSave: _saveGroup,
            ),
        ],
      ),
    );
  }
}
