import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../utils/furnace_calculator.dart';
import 'summary_stat_card.dart';

class FurnaceSummaryPanel extends StatelessWidget {
  const FurnaceSummaryPanel({
    super.key,
    required this.totalWeightKg,
    this.lineItemCount,
    this.onSave,
    this.showSaveButton = false,
  });

  final double totalWeightKg;
  final int? lineItemCount;
  final VoidCallback? onSave;
  final bool showSaveButton;

  static final _weightFormat = NumberFormat('#,##0.###');
  static final _heatFormat = NumberFormat('0.00');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heats = FurnaceCalculator.heatsRequired(totalWeightKg);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SummaryStatCard(
                icon: Icons.scale_outlined,
                label: 'Total Weight',
                value: '${_weightFormat.format(totalWeightKg)} kg',
                accentColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              SummaryStatCard(
                icon: Icons.local_fire_department_outlined,
                label: 'Furnace Heats',
                value: _heatFormat.format(heats),
                subtitle: '${FurnaceCalculator.capacityKg.toInt()} kg per furnace',
                accentColor: AppTheme.furnaceAmber,
              ),
            ],
          ),
          if (lineItemCount != null) ...[
            const SizedBox(height: 12),
            Text(
              '$lineItemCount line item(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (showSaveButton && onSave != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Group'),
            ),
          ],
        ],
      ),
    );
  }
}
