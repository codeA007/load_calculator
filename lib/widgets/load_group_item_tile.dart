import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/load_group.dart';
import '../../models/load_group_item.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          item.partNo,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(item.description!),
            const SizedBox(height: 4),
            Text(
              'Unit: ${_weightFormat.format(item.unitWeightKg)} kg  •  '
              'Qty: ${_weightFormat.format(item.quantity)}',
            ),
          ],
        ),
        trailing: Text(
          '${_weightFormat.format(item.lineWeightKg)} kg',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        isThreeLine:
            item.description != null && item.description!.isNotEmpty,
      ),
    );
  }
}

class LoadGroupHeader extends StatelessWidget {
  const LoadGroupHeader({
    super.key,
    required this.group,
  });

  final LoadGroup group;

  static final _weightFormat = NumberFormat('#,##0.###');
  static final _dateFormat = DateFormat('d MMM yyyy, h:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_dateFormat.format(group.createdAt)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total: ${_weightFormat.format(group.totalWeightKg)} kg',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${group.items.length} line item(s)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
