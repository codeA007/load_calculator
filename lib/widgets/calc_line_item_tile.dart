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
                  item.part.partNo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.part.description != null &&
                    item.part.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.part.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${_weightFormat.format(item.part.weightKg)} kg × '
                  '${_weightFormat.format(item.quantity)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
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
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
