import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/part.dart';
import 'part_search_field.dart';

class AddPartSection extends StatelessWidget {
  const AddPartSection({
    super.key,
    required this.selectedPart,
    required this.quantityController,
    required this.onPartSelected,
    required this.onAdd,
    this.preview,
  });

  final Part? selectedPart;
  final TextEditingController quantityController;
  final ValueChanged<Part> onPartSelected;
  final VoidCallback onAdd;
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Part',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            PartSearchField(
              onPartSelected: onPartSelected,
            ),
            if (selectedPart != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected: ${selectedPart!.partNo} (${selectedPart!.weightKg} kg)',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onAdd,
                  child: const Text('Add'),
                ),
              ],
            ),
            if (preview != null) ...[
              const SizedBox(height: 12),
              preview!,
            ],
          ],
        ),
      ),
    );
  }
}
