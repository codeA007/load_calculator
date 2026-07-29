import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calc_line_item.dart';

class CalcLineItemTile extends StatelessWidget {
  const CalcLineItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
  });

  final CalcLineItem item;
  final int index;
  final VoidCallback onRemove;

  static final _weightFormat = NumberFormat('#,##0.###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(
          item.part.partNo,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.part.description != null &&
                item.part.description!.isNotEmpty)
              Text(item.part.description!),
            const SizedBox(height: 4),
            Text(
              'Unit: ${_weightFormat.format(item.part.weightKg)} kg  •  '
              'Qty: ${_weightFormat.format(item.quantity)}',
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_weightFormat.format(item.lineWeight)} kg',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Remove',
              onPressed: onRemove,
            ),
          ],
        ),
        isThreeLine: item.part.description != null &&
            item.part.description!.isNotEmpty,
      ),
    );
  }
}
