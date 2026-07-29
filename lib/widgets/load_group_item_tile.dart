import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/load_group.dart';
import '../../models/load_group_item.dart';
import '../../utils/furnace_calculator.dart';

class LoadGroupItemTile extends StatelessWidget {
  const LoadGroupItemTile({
    super.key,
    required this.item,
  });

  final LoadGroupItem item;

  static final _weightFormat = NumberFormat('#,##0.###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.partNo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${_weightFormat.format(item.unitWeightKg)} kg × '
                  '${_weightFormat.format(item.quantity)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_weightFormat.format(item.lineWeightKg)} kg',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

String formatGroupSubtitle(LoadGroup group, double furnaceCapacityKg) {
  final weightFormat = NumberFormat('#,##0.###');
  final heatFormat = NumberFormat('0.00');
  final dateFormat = DateFormat('d MMM yyyy, h:mm a');
  final heats = FurnaceCalculator.heatsRequired(
    group.totalWeightKg,
    capacityKg: furnaceCapacityKg,
  );

  return '${dateFormat.format(group.createdAt)}  •  '
      '${weightFormat.format(group.totalWeightKg)} kg  •  '
      '${heatFormat.format(heats)} heats';
}
