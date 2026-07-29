import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../utils/furnace_calculator.dart';

class FurnaceSummaryPanel extends StatelessWidget {
  const FurnaceSummaryPanel({
    super.key,
    required this.totalWeightKg,
    required this.furnaceCapacityKg,
    this.lineItemCount,
    this.onSave,
    this.showSaveButton = false,
    this.compact = false,
  });

  final double totalWeightKg;
  final double furnaceCapacityKg;
  final int? lineItemCount;
  final VoidCallback? onSave;
  final bool showSaveButton;
  final bool compact;

  static final _weightFormat = NumberFormat('#,##0.###');
  static final _heatFormat = NumberFormat('0.00');

  @override
  Widget build(BuildContext context) {
    final panel = compact
        ? _CompactPanel(
            totalWeightKg: totalWeightKg,
            furnaceCapacityKg: furnaceCapacityKg,
            lineItemCount: lineItemCount,
            onSave: onSave,
            showSaveButton: showSaveButton,
          )
        : _ExpandedPanel(
            totalWeightKg: totalWeightKg,
            furnaceCapacityKg: furnaceCapacityKg,
            lineItemCount: lineItemCount,
            onSave: onSave,
            showSaveButton: showSaveButton,
          );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: panel,
    );
  }
}

class _CompactPanel extends StatelessWidget {
  const _CompactPanel({
    required this.totalWeightKg,
    required this.furnaceCapacityKg,
    this.lineItemCount,
    this.onSave,
    this.showSaveButton = false,
  });

  final double totalWeightKg;
  final double furnaceCapacityKg;
  final int? lineItemCount;
  final VoidCallback? onSave;
  final bool showSaveButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heats = FurnaceCalculator.heatsRequired(
      totalWeightKg,
      capacityKg: furnaceCapacityKg,
    );
    final capacityLabel = '${furnaceCapacityKg.toStringAsFixed(
      furnaceCapacityKg == furnaceCapacityKg.roundToDouble() ? 0 : 1,
    )} kg each';

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _CompactStat(
                  icon: Icons.scale_outlined,
                  label: 'Weight',
                  value:
                      '${FurnaceSummaryPanel._weightFormat.format(totalWeightKg)} kg',
                  color: theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: theme.dividerColor,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                _CompactStat(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Furnace Heats',
                  value: FurnaceSummaryPanel._heatFormat.format(heats),
                  subtitle: capacityLabel,
                  color: AppTheme.furnaceAmber,
                ),
              ],
            ),
            if (lineItemCount != null) ...[
              const SizedBox(height: 4),
              Text(
                '$lineItemCount line item(s)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (showSaveButton && onSave != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Group'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({
    required this.totalWeightKg,
    required this.furnaceCapacityKg,
    this.lineItemCount,
    this.onSave,
    this.showSaveButton = false,
  });

  final double totalWeightKg;
  final double furnaceCapacityKg;
  final int? lineItemCount;
  final VoidCallback? onSave;
  final bool showSaveButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heats = FurnaceCalculator.heatsRequired(
      totalWeightKg,
      capacityKg: furnaceCapacityKg,
    );
    final capacityLabel = '${furnaceCapacityKg.toStringAsFixed(
      furnaceCapacityKg == furnaceCapacityKg.roundToDouble() ? 0 : 1,
    )} kg per furnace';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactStat(
                  icon: Icons.scale_outlined,
                  label: 'Total Weight',
                  value:
                      '${FurnaceSummaryPanel._weightFormat.format(totalWeightKg)} kg',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactStat(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Furnace Heats',
                  value: FurnaceSummaryPanel._heatFormat.format(heats),
                  subtitle: capacityLabel,
                  color: AppTheme.furnaceAmber,
                ),
              ),
            ],
          ),
          if (lineItemCount != null) ...[
            const SizedBox(height: 8),
            Text(
              '$lineItemCount line item(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (showSaveButton && onSave != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Group'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
