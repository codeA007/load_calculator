import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/part.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/load_groups_provider.dart';
import '../../providers/parts_provider.dart';
import '../../widgets/calc_line_item_tile.dart';
import '../../widgets/confirm_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartsProvider>().refreshCount();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _addToLoad() {
    final part = _selectedPart;
    if (part == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a part first')),
      );
      return;
    }

    final qtyText = _quantityController.text.trim().replaceAll(',', '');
    final quantity = double.tryParse(qtyText);
    if (quantity == null || quantity <= 0) {
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

    final nameController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Group'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Group name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true || !mounted) {
      nameController.dispose();
      return;
    }

    final name = nameController.text.trim();
    nameController.dispose();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name is required')),
      );
      return;
    }

    try {
      await context.read<LoadGroupsProvider>().saveGroup(
            name,
            calculator.lineItems,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved group "$name"')),
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

  @override
  Widget build(BuildContext context) {
    final partsCount = context.watch<PartsProvider>().partsCount;
    final calculator = context.watch<CalculatorProvider>();
    final theme = Theme.of(context);

    if (partsCount == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calculate Load')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No parts in library',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add parts before calculating load weight.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
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
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate Load'),
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
                    style: theme.textTheme.bodySmall,
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
                          border: OutlineInputBorder(),
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
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: calculator.lineItems.isEmpty
                ? Center(
                    child: Text(
                      'Add parts to see weight breakdown',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: calculator.lineItems.length,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand Total',
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    '${_weightFormat.format(calculator.grandTotal)} kg',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${calculator.lineItems.length} line item(s)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saveGroup,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Group'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
